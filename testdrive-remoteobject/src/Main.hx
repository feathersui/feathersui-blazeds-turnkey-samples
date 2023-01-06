import openfl.Lib;
import feathers.controls.Alert;
import feathers.controls.Application;
import feathers.controls.Button;
import feathers.controls.GridView;
import feathers.controls.GridViewColumn;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import feathers.messaging.config.LoaderConfig;
import feathers.rpc.events.FaultEvent;
import feathers.rpc.events.ResultEvent;
import feathers.rpc.remoting.RemoteObject;

class Main extends Application {
	public function new() {
		super();

		LoaderConfig.init(this);
		Lib.registerClassAlias("flex.samples.product.Product", Product);
	}

	private var srv:RemoteObject;
	private var gridView:GridView;

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

		var viewLayout = new VerticalLayout();
		layout = viewLayout;

		gridView = new GridView();
		gridView.layoutData = VerticalLayoutData.fill();
		gridView.columns = new ArrayCollection([
			new GridViewColumn("Name", item -> Std.string(item.name)),
			new GridViewColumn("Description", item -> Std.string(item.description)),
			new GridViewColumn("Price", item -> Std.string(item.price)),
			new GridViewColumn("In Stock", item -> Std.string(item.qtyInStock)),
		]);
		addChild(gridView);

		var button = new Button("Get Data");
		button.addEventListener(TriggerEvent.TRIGGER, button_onTrigger);
		addChild(button);
	}

	private function button_onTrigger(event:TriggerEvent):Void {
		srv.getOperation("getProducts").send();
	}

	private function handleResult(event:ResultEvent):Void {
		var collection = cast(event.result, ArrayCollection<Dynamic>);
		gridView.dataProvider = collection;
	}

	private function handleFault(event:FaultEvent):Void {
		Alert.show(Std.string(event.fault), "Fault", ["OK"]);
	}
}
