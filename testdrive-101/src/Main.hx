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
import feathers.controls.Application;
import feathers.controls.Form;
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
	private var productsListView:ListView;
	private var productView:ProductView;

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

		productsListView = new ListView();
		productsListView.itemRendererRecycler = Thumb;
		productsListView.layoutData = AnchorLayoutData.fill();
		productsListView.addEventListener(Event.CHANGE, onProductChange);
		catalog.addChild(productsListView);

		productView = new ProductView();
		productView.layoutData = HorizontalLayoutData.fill();
		addChild(productView);
	}

	private function onCreationComplete(event:FeathersEvent):Void {
		srv.getOperation("getProducts").send();
	}

	private function onProductChange(event:Event):Void {
		productView.product = cast(productsListView.selectedItem, Product);
	}

	private function handleResult(event:ResultEvent):Void {
		var collection = cast(event.result, ArrayCollection<Dynamic>);
		productsListView.dataProvider = collection;
	}

	private function handleFault(event:FaultEvent):Void {
		Alert.show(Std.string(event.fault), "Fault", ["OK"]);
	}
}
