import feathers.controls.Alert;
import feathers.controls.Application;
import feathers.controls.GridView;
import feathers.controls.GridViewColumn;
import feathers.controls.Header;
import feathers.controls.ListView;
import feathers.controls.Panel;
import feathers.data.ArrayCollection;
import feathers.events.FeathersEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.messaging.config.LoaderConfig;
import feathers.rpc.events.FaultEvent;
import feathers.rpc.events.ResultEvent;
import feathers.rpc.remoting.RemoteObject;
import openfl.Lib;
import openfl.events.Event;

class Main extends Application {
	public function new() {
		super();

		LoaderConfig.init(this);
		Lib.registerClassAlias("flex.samples.product.Product", Product);

		addEventListener(FeathersEvent.CREATION_COMPLETE, onCreationComplete);
	}

	private var srv:RemoteObject;
	private var gridView:GridView;
	private var productForm:ProductForm;

	override private function initialize():Void {
		super.initialize();

		srv = new RemoteObject();
		srv.destination = "product";
		#if (html5 || (flash && !air))
		srv.endpoint = 'http://{server.name}:{server.port}/samples/messagebroker/amf';
		#else
		srv.endpoint = 'http://localhost:8080/samples/messagebroker/amf';
		#end
		srv.addEventListener(ResultEvent.RESULT, handleResult);
		srv.addEventListener(FaultEvent.FAULT, handleFault);

		var viewLayout = new HorizontalLayout();
		layout = viewLayout;

		var catalog = new Panel();
		catalog.header = new Header("Catalog");
		catalog.layoutData = HorizontalLayoutData.fill();
		catalog.layout = new AnchorLayout();
		addChild(catalog);

		gridView = new GridView();
		gridView.columns = new ArrayCollection([
			new GridViewColumn("Name", item -> item.name),
			new GridViewColumn("Category", item -> item.category),
			new GridViewColumn("Image", item -> item.image),
			new GridViewColumn("Price", item -> Std.string(item.price)),
			new GridViewColumn("Description", item -> item.description),
		]);
		gridView.layoutData = AnchorLayoutData.fill();
		gridView.addEventListener(Event.CHANGE, onProductChange);
		catalog.addChild(gridView);

		productForm = new ProductForm();
		productForm.layoutData = HorizontalLayoutData.fill();
		addChild(productForm);
	}

	private function onCreationComplete(event:FeathersEvent):Void {
		srv.getOperation("getProducts").send();
	}

	private function onProductChange(event:Event):Void {
		productForm.product = cast(gridView.selectedItem, Product);
	}

	private function handleResult(event:ResultEvent):Void {
		var collection = cast(event.result, ArrayCollection<Dynamic>);
		gridView.dataProvider = collection;
	}

	private function handleFault(event:FaultEvent):Void {
		Alert.show(Std.string(event.fault), "Fault", ["OK"]);
	}
}
