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

import feathers.controls.Alert;
import feathers.controls.Button;
import feathers.controls.Form;
import feathers.controls.FormItem;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.controls.TextArea;
import feathers.controls.TextInput;
import feathers.events.FormEvent;
import feathers.events.TriggerEvent;
import feathers.layout.VerticalLayout;
import feathers.rpc.events.FaultEvent;
import feathers.rpc.events.ResultEvent;
import feathers.rpc.remoting.RemoteObject;

class ProductForm extends Panel {
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

	private var srv:RemoteObject;
	private var form:Form;
	private var nameInput:TextInput;
	private var categoryInput:TextInput;
	private var imageInput:TextInput;
	private var priceInput:TextInput;
	private var descriptionInput:TextArea;

	override private function initialize():Void {
		super.initialize();

		srv = new RemoteObject();
		srv.destination = "product";
		#if (html5 || (flash && !air))
		srv.endpoint = 'http://{server.name}:{server.port}/samples/messagebroker/amf';
		#else
		srv.endpoint = 'http://localhost:8080/samples/messagebroker/amf';
		#end
		srv.addEventListener(FaultEvent.FAULT, handleFault);

		var viewHeader = new Header("Details");
		header = viewHeader;

		var viewLayout = new VerticalLayout();
		viewLayout.setPadding(10.0);
		viewLayout.horizontalAlign = JUSTIFY;
		layout = viewLayout;

		form = new Form();
		form.addEventListener(FormEvent.SUBMIT, form_onSubmit);
		addChild(form);

		nameInput = new TextInput();
		var nameFormItem = new FormItem("Name", nameInput);
		nameFormItem.horizontalAlign = JUSTIFY;
		form.addChild(nameFormItem);

		categoryInput = new TextInput();
		var categoryFormItem = new FormItem("Category", categoryInput);
		categoryFormItem.horizontalAlign = JUSTIFY;
		form.addChild(categoryFormItem);

		imageInput = new TextInput();
		var imageFormItem = new FormItem("Image", imageInput);
		imageFormItem.horizontalAlign = JUSTIFY;
		form.addChild(imageFormItem);

		priceInput = new TextInput();
		priceInput.restrict = "0-9\\.";
		var priceFormItem = new FormItem("Price", priceInput);
		priceFormItem.horizontalAlign = JUSTIFY;
		form.addChild(priceFormItem);

		descriptionInput = new TextArea();
		var descriptionFormItem = new FormItem("Description", descriptionInput);
		descriptionFormItem.horizontalAlign = JUSTIFY;
		form.addChild(descriptionFormItem);

		var updateButton = new Button("Update");
		updateButton.addEventListener(TriggerEvent.TRIGGER, updateButton_onTrigger);
		addChild(updateButton);
	}

	override private function update():Void {
		var dataInvalid = isInvalid(DATA);

		if (dataInvalid) {
			if (product != null) {
				nameInput.text = product.name;
				categoryInput.text = product.category;
				imageInput.text = product.image;
				priceInput.text = Std.string(product.price);
				descriptionInput.text = product.description;
			} else {
				nameInput.text = null;
				categoryInput.text = null;
				imageInput.text = null;
				priceInput.text = null;
				descriptionInput.text = null;
			}
		}
		super.update();
	}

	private function updateButton_onTrigger(event:TriggerEvent):Void {
		form.submit();
	}

	private function form_onSubmit(event:FormEvent):Void {
		product.name = nameInput.text;
		product.category = categoryInput.text;
		product.image = imageInput.text;
		product.price = Std.parseFloat(priceInput.text);
		product.description = descriptionInput.text;
		setInvalid(DATA);
		srv.getOperation("update").send(product);
	}

	private function handleFault(event:FaultEvent):Void {
		Alert.show(Std.string(event.fault), "Fault", ["OK"]);
	}
}
