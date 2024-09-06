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

import openfl.events.Event;
import feathers.controls.Application;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.messaging.config.LoaderConfig;

class Main extends Application {
	public function new() {
		super();

		LoaderConfig.init(this);
	}

	private var roomsListPanel:RoomsListPanel;
	private var chatPanel:ChatPanel;

	override private function initialize():Void {
		super.initialize();

		var viewLayout = new HorizontalLayout();
		layout = viewLayout;

		roomsListPanel = new RoomsListPanel();
		roomsListPanel.addEventListener(Event.CHANGE, roomsListPanel_changeHandler);
		roomsListPanel.layoutData = HorizontalLayoutData.fill();
		addChild(roomsListPanel);

		chatPanel = new ChatPanel();
		chatPanel.layoutData = HorizontalLayoutData.fill();
		addChild(chatPanel);
	}

	private function roomsListPanel_changeHandler(event:Event):Void {
		var room = cast(roomsListPanel.selectedRoom, String);
		chatPanel.room = room;
	}
}
