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
import feathers.controls.GridView;
import feathers.controls.GridViewColumn;
import feathers.data.ArrayCollection;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import feathers.messaging.ChannelSet;
import feathers.messaging.channels.AMFChannel;
import feathers.messaging.config.LoaderConfig;
import feathers.rpc.events.FaultEvent;
import feathers.rpc.events.ResultEvent;
import feathers.rpc.remoting.RemoteObject;

class Main extends Application {
	public function new() {
		super();

		LoaderConfig.init(this);
	}

	private var srv:RemoteObject;
	private var gridView:GridView;

	override private function initialize():Void {
		super.initialize();

		#if (html5)
		var rootUrl:String = js.Lib.global.document.location.origin;
		var endpoint = '$rootUrl/samples/messagebroker/amf';
		#else
		var endpoint = 'http://localhost:8080/samples/messagebroker/amf';
		#end

		var channel:AMFChannel = new AMFChannel("my-amf", endpoint);
		var channelSet:ChannelSet = new ChannelSet();
		channelSet.addChannel(channel);

		srv = new RemoteObject();
		srv.destination = "runtime-employee-ro";
		srv.channelSet = channelSet;
		srv.addEventListener(ResultEvent.RESULT, handleResult);
		srv.addEventListener(FaultEvent.FAULT, handleFault);

		var viewLayout = new VerticalLayout();
		layout = viewLayout;

		gridView = new GridView();
		gridView.layoutData = VerticalLayoutData.fill();
		gridView.columns = new ArrayCollection([
			new GridViewColumn("First Name", item -> Std.string(item.firstName)),
			new GridViewColumn("Last Name", item -> Std.string(item.lastName)),
			new GridViewColumn("Title", item -> Std.string(item.title)),
			new GridViewColumn("Phone", item -> Std.string(item.phone)),
			new GridViewColumn("Email", item -> Std.string(item.email)),
		]);
		addChild(gridView);

		srv.getOperation("getEmployees").send();
	}

	private function handleResult(event:ResultEvent):Void {
		var collection = cast(event.result, ArrayCollection<Dynamic>);
		gridView.dataProvider = collection;
	}

	private function handleFault(event:FaultEvent):Void {
		Alert.show(Std.string(event.fault), "Fault", ["OK"]);
	}
}
