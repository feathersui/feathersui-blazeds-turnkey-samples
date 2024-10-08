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

import feathers.controls.Application;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.events.TriggerEvent;
import feathers.layout.VerticalLayout;
import feathers.messaging.Channel;
import feathers.messaging.ChannelSet;
import feathers.messaging.Consumer;
import feathers.messaging.channels.AMFChannel;
import feathers.messaging.channels.SecureAMFChannel;
import feathers.messaging.config.LoaderConfig;
import feathers.messaging.events.MessageEvent;

class Main extends Application {
	public function new() {
		super();

		LoaderConfig.init(this);
	}

	private var consumer:Consumer;
	private var subscribeButton:Button;
	private var unsubscribeButton:Button;
	private var pushedValue:Label;

	override private function initialize():Void {
		super.initialize();

		#if (html5 || (flash && !air))
		var endpoint = 'http://{server.name}:{server.port}/samples/messagebroker/amf';
		#else
		var endpoint = 'http://localhost:8080/samples/messagebroker/amf';
		#end

		consumer = new Consumer();
		consumer.destination = "feed";
		consumer.channelSet = createChannelSet(endpoint);
		consumer.addEventListener(MessageEvent.MESSAGE, messageHandler);

		var viewLayout = new VerticalLayout();
		viewLayout.setPadding(10.0);
		viewLayout.gap = 10.0;
		layout = viewLayout;

		subscribeButton = new Button("Subscribe to 'feed' destination");
		subscribeButton.addEventListener(TriggerEvent.TRIGGER, subscribeButton_triggerHandler);
		addChild(subscribeButton);

		unsubscribeButton = new Button("Unubscribe from 'feed' destination");
		unsubscribeButton.enabled = false;
		unsubscribeButton.addEventListener(TriggerEvent.TRIGGER, unsubscribeButton_triggerHandler);
		addChild(unsubscribeButton);

		pushedValue = new Label();
		addChild(pushedValue);
	}

	private function createChannelSet(endpoint:String):ChannelSet {
		var chan:Channel;
		if (endpoint.indexOf("https") == 0) {
			chan = new SecureAMFChannel(null, endpoint);
		} else {
			chan = new AMFChannel(null, endpoint);
		}

		var channelSet = new ChannelSet();
		channelSet.addChannel(chan);
		return channelSet;
	}

	private function messageHandler(event:MessageEvent):Void {
		var message = event.message;
		pushedValue.text = Std.string(message.body);
	}

	private function subscribeButton_triggerHandler(event:TriggerEvent):Void {
		consumer.subscribe();
		subscribeButton.enabled = false;
		unsubscribeButton.enabled = true;
	}

	private function unsubscribeButton_triggerHandler(event:TriggerEvent):Void {
		consumer.unsubscribe();
		subscribeButton.enabled = true;
		unsubscribeButton.enabled = false;
	}
}
