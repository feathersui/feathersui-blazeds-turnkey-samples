/*
	Licensed to the Apache Software Foundation (ASF) under one or more
	contributor license agreements.  See the NOTICE file distributed with
	this work for additional information regarding copyright ownership.
	The ASF licenses this file to You under the Apache License, Version 2.0
	(the "License"); you may not use this file except in compliance with
	the License.  You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
 */

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
