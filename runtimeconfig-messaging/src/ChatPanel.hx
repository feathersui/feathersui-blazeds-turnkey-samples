import feathers.controls.Alert;
import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.controls.TextArea;
import feathers.controls.TextInput;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalLayoutData;
import feathers.messaging.Channel;
import feathers.messaging.ChannelSet;
import feathers.messaging.Consumer;
import feathers.messaging.Producer;
import feathers.messaging.channels.AMFChannel;
import feathers.messaging.channels.SecureAMFChannel;
import feathers.messaging.events.MessageEvent;
import feathers.messaging.events.MessageFaultEvent;
import feathers.messaging.messages.AsyncMessage;
import feathers.messaging.messages.IMessage;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

class ChatPanel extends Panel {
	public function new() {
		super();
	}

	private var consumer:Consumer;
	private var producer:Producer;

	public var room(default, set):String;

	private function set_room(value:String):String {
		if (room == value) {
			return room;
		}
		room = value;

		if (consumer != null && consumer.subscribed) {
			log.text += "Leaving room " + consumer.destination + "\n";
			consumer.unsubscribe();
		}
		if (room == null || room.length == 0) {
			return room;
		}
		consumer.destination = room;
		producer.destination = room;
		consumer.subscribe();
		log.text += "Entering room " + room + "\n";

		return room;
	}

	private var msg:TextInput;
	private var sendButton:Button;
	private var log:TextArea;

	override private function initialize():Void {
		super.initialize();

		#if (html5)
		var rootUrl:String = js.Lib.global.document.location.origin;
		var endpoint = '$rootUrl/samples/messagebroker/amfpolling';
		#else
		var endpoint = 'http://localhost:8080/samples/messagebroker/amfpolling';
		#end

		producer = new Producer();
		producer.channelSet = createChannelSet(endpoint);

		consumer = new Consumer();
		consumer.channelSet = createChannelSet(endpoint);
		consumer.addEventListener(MessageEvent.MESSAGE, messageHandler);
		consumer.addEventListener(MessageFaultEvent.FAULT, faultHandler);

		layout = new AnchorLayout();

		var headerView = new Header("Chat");
		header = headerView;

		var footerView = new LayoutGroup();
		footerView.variant = LayoutGroup.VARIANT_TOOL_BAR;
		msg = new TextInput();
		msg.layoutData = HorizontalLayoutData.fillHorizontal();
		msg.addEventListener(KeyboardEvent.KEY_DOWN, msg_keyDownHandler);
		footerView.addChild(msg);
		sendButton = new Button("Send");
		sendButton.addEventListener(TriggerEvent.TRIGGER, sendButton_triggerHandler);
		footerView.addChild(sendButton);
		footer = footerView;

		log = new TextArea();
		log.editable = false;
		log.layoutData = AnchorLayoutData.fill();
		addChild(log);
	}

	private function createChannelSet(endpoint:String):ChannelSet {
		var chan:Channel;
		if (endpoint.indexOf("https") == 0) {
			chan = new SecureAMFChannel("my-polling-amf", endpoint);
		} else {
			chan = new AMFChannel("my-polling-amf", endpoint);
		}

		var channelSet = new ChannelSet();
		channelSet.addChannel(chan);
		return channelSet;
	}

	private function sendMessage():Void {
		if (consumer == null || !consumer.subscribed) {
			Alert.show("Select a room before sending a message", "Missing Room", ["OK"]);
			return;
		}
		var message:IMessage = new AsyncMessage();
		message.body = msg.text;
		producer.send(message);
		msg.text = "";
	}

	private function messageHandler(event:MessageEvent):Void {
		var message = event.message;
		log.text += '${message.body}\n';
	}

	private function faultHandler(event:MessageFaultEvent):Void {
		Alert.show(event.faultString, "Fault", ["OK"]);
	}

	private function msg_keyDownHandler(event:KeyboardEvent):Void {
		if (event.keyCode == Keyboard.ENTER) {
			sendMessage();
		}
	}

	private function sendButton_triggerHandler(event:TriggerEvent):Void {
		sendMessage();
	}
}
