import feathers.controls.AssetLoader;
import feathers.controls.Label;
import feathers.controls.dataRenderers.LayoutGroupItemRenderer;
import feathers.formatters.CurrencyFormatter;
import feathers.layout.VerticalLayout;

class Thumb extends LayoutGroupItemRenderer {
	public function new() {
		super();
	}

	private var nameLabel:Label;
	private var imgLoader:AssetLoader;
	private var priceLabel:Label;
	private var cf:CurrencyFormatter;

	override private function initialize():Void {
		super.initialize();

		layout = new VerticalLayout();

		nameLabel = new Label();
		addChild(nameLabel);

		imgLoader = new AssetLoader();
		imgLoader.width = 40.0;
		imgLoader.height = 80.0;
		addChild(imgLoader);

		priceLabel = new Label();
		addChild(priceLabel);

		cf = new CurrencyFormatter();
	}

	override private function update():Void {
		var dataInvalid = isInvalid(DATA);

		if (dataInvalid) {
			if (data != null) {
				var product = cast(data, Product);
				nameLabel.text = product.name;
				#if (html5 || (flash && !air))
				imgLoader.source = '../images/${product.image}';
				#else
				imgLoader.source = 'http://localhost:8080/samples/images/${product.image}';
				#end
				priceLabel.text = cf.format(product.price);
			} else {
				nameLabel.text = null;
				imgLoader.source = null;
				priceLabel.text = null;
			}
		}
		super.update();
	}
}
