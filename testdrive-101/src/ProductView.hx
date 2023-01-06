import feathers.controls.AssetLoader;
import feathers.controls.Header;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.formatters.CurrencyFormatter;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;

class ProductView extends Panel {
	public function new() {
		super();
	}

	public var product(default, set):Product;

	private function set_product(value:Product):Product {
		if (product == value) {
			return product;
		}
		product = value;
		setInvalid(DATA);
		return product;
	}

	private var imgLoader:AssetLoader;
	private var nameLabel:Label;
	private var priceLabel:Label;
	private var descriptionLabel:Label;
	private var cf:CurrencyFormatter;

	override private function initialize():Void {
		super.initialize();

		var viewHeader = new Header("Product Details");
		header = viewHeader;

		var viewLayout = new HorizontalLayout();
		viewLayout.setPadding(12.0);
		layout = viewLayout;

		imgLoader = new AssetLoader();
		imgLoader.width = 40.0;
		imgLoader.height = 80.0;
		addChild(imgLoader);

		var vbox = new LayoutGroup();
		vbox.layout = new VerticalLayout();
		vbox.layoutData = HorizontalLayoutData.fillHorizontal();
		addChild(vbox);

		nameLabel = new Label();
		vbox.addChild(nameLabel);

		priceLabel = new Label();
		vbox.addChild(priceLabel);

		descriptionLabel = new Label();
		descriptionLabel.wordWrap = true;
		descriptionLabel.layoutData = VerticalLayoutData.fillHorizontal();
		vbox.addChild(descriptionLabel);

		cf = new CurrencyFormatter();
	}

	override private function update():Void {
		var dataInvalid = isInvalid(DATA);

		if (dataInvalid) {
			if (product != null) {
				#if (html5 || (flash && !air))
				imgLoader.source = '../images/${product.image}';
				#else
				imgLoader.source = 'http://localhost:8080/samples/images/${product.image}';
				#end
				nameLabel.text = product.name;
				priceLabel.text = 'Price: ${cf.format(product.price)}';
				descriptionLabel.text = product.description;
			} else {
				imgLoader.source = null;
				nameLabel.text = null;
				priceLabel.text = null;
				descriptionLabel.text = null;
			}
		}
		super.update();
	}
}
