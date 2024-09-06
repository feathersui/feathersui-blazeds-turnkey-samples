import feathers.controls.Alert;
import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.Panel;
import feathers.controls.TextInput;
import feathers.data.ArrayCollection;
import feathers.events.FeathersEvent;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalLayoutData;
import feathers.rpc.events.FaultEvent;
import feathers.rpc.events.ResultEvent;
import feathers.rpc.remoting.Operation;
import feathers.rpc.remoting.RemoteObject;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

class RoomsListPanel extends Panel {
	public function new() {
		super();

		addEventListener(FeathersEvent.CREATION_COMPLETE, creationCompleteHandler);
	}

	public var selectedRoom(default, null):String = null;

	private var srv:RemoteObject;
	private var getRoomList:Operation;
	private var createRoom:Operation;
	private var roomsListView:ListView;
	private var roomNameInput:TextInput;
	private var createButton:Button;
	private var refreshButton:Button;
	private var _ignoreListViewChange:Bool = false;

	override private function initialize():Void {
		super.initialize();

		srv = new RemoteObject();
		srv.destination = "chat-room-service";
		#if (html5 || (flash && !air))
		srv.endpoint = 'http://{server.name}:{server.port}/samples/messagebroker/amf';
		#else
		srv.endpoint = 'http://localhost:8080/samples/messagebroker/amf';
		#end
		getRoomList = new Operation(null, "getRoomList");
		getRoomList.addEventListener(ResultEvent.RESULT, getRoomList_handleResult);
		getRoomList.addEventListener(FaultEvent.FAULT, handleFault);
		createRoom = new Operation(null, "createRoom");
		createRoom.addEventListener(ResultEvent.RESULT, createRoom_handleResult);
		srv.operations = {getRoomList: getRoomList, createRoom: createRoom};

		layout = new AnchorLayout();

		var headerView = new Header("Room List");
		header = headerView;

		var footerView = new LayoutGroup();
		footerView.variant = LayoutGroup.VARIANT_TOOL_BAR;
		roomNameInput = new TextInput();
		roomNameInput.layoutData = HorizontalLayoutData.fillHorizontal();
		roomNameInput.addEventListener(KeyboardEvent.KEY_DOWN, roomNameInput_keyDownHandler);
		footerView.addChild(roomNameInput);
		createButton = new Button("Create");
		createButton.addEventListener(TriggerEvent.TRIGGER, createButton_triggerHandler);
		footerView.addChild(createButton);
		refreshButton = new Button("Refresh");
		refreshButton.addEventListener(TriggerEvent.TRIGGER, refreshButton_triggerHandler);
		footerView.addChild(refreshButton);
		footer = footerView;

		roomsListView = new ListView();
		roomsListView.layoutData = AnchorLayoutData.fill();
		roomsListView.addEventListener(Event.CHANGE, roomsListView_changeHandler);
		addChild(roomsListView);
	}

	private function createNewRoom():Void {
		var roomName:String = roomNameInput.text;
		if (roomName.length == 0) {
			return;
		}
		roomNameInput.text = "";
		createRoom.send(roomName);
	}

	private function creationCompleteHandler(event:FeathersEvent):Void {
		getRoomList.send();
	}

	private function createRoom_handleResult(event:ResultEvent):Void {
		getRoomList.send();
	}

	private function getRoomList_handleResult(event:ResultEvent):Void {
		var rooms = cast(event.result, ArrayCollection<Dynamic>);

		var selectedRoom = roomsListView.selectedItem;
		var roomStillExists = false;
		if (selectedRoom != null) {
			roomStillExists = rooms.contains(selectedRoom);
		}

		_ignoreListViewChange = roomStillExists;
		roomsListView.dataProvider = rooms;
		roomsListView.selectedItem = roomStillExists ? selectedRoom : null;
		_ignoreListViewChange = false;
	}

	private function handleFault(event:FaultEvent):Void {
		Alert.show(Std.string(event.fault), "Fault", ["OK"]);
	}

	private function roomNameInput_keyDownHandler(event:KeyboardEvent):Void {
		if (event.keyCode == Keyboard.ENTER) {
			createNewRoom();
		}
	}

	private function createButton_triggerHandler(event:TriggerEvent):Void {
		createNewRoom();
	}

	private function refreshButton_triggerHandler(event:TriggerEvent):Void {
		getRoomList.send();
	}

	private function roomsListView_changeHandler(event:Event):Void {
		if (_ignoreListViewChange) {
			return;
		}
		selectedRoom = roomsListView.selectedItem;
		dispatchEvent(new Event(Event.CHANGE));
	}
}
