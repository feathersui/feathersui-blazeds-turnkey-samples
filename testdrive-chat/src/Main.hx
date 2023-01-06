import feathers.controls.Application;
import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.controls.TextArea;
import feathers.controls.TextInput;
import feathers.events.FeathersEvent;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.messaging.Channel;
import feathers.messaging.ChannelSet;
import feathers.messaging.Consumer;
import feathers.messaging.Producer;
import feathers.messaging.channels.AMFChannel;
import feathers.messaging.channels.SecureAMFChannel;
import feathers.messaging.config.LoaderConfig;
import feathers.messaging.events.MessageEvent;
import feathers.messaging.messages.AsyncMessage;
import feathers.messaging.messages.IMessage;

class Main extends Application {
	public function new() {
		super();

		LoaderConfig.init(this);

		addEventListener(FeathersEvent.CREATION_COMPLETE, creationCompleteHandler);
	}

	private var producer:Producer;
	private var consumer:Consumer;
	private var log:TextArea;
	private var msg:TextInput;

	override private function initialize():Void {
		super.initialize();

		#if (html5 || (flash && !air))
		var endpoint = 'http://{server.name}:{server.port}/samples/messagebroker/amf';
		#else
		var endpoint = 'http://localhost:8080/samples/messagebroker/amf';
		#end

		producer = new Producer();
		producer.destination = "chat";
		producer.channelSet = createChannelSet(endpoint);

		consumer = new Consumer();
		consumer.destination = "chat";
		consumer.channelSet = createChannelSet(endpoint);
		consumer.addEventListener(MessageEvent.MESSAGE, messageHandler);

		var viewLayout = new AnchorLayout();
		layout = viewLayout;

		var footer = new LayoutGroup();
		footer.variant = LayoutGroup.VARIANT_TOOL_BAR;
		msg = new TextInput();
		footer.addChild(msg);
		var sendButton = new Button("Send");
		sendButton.addEventListener(TriggerEvent.TRIGGER, sendButton_triggerHandler);
		footer.addChild(sendButton);

		var chatPanel = new Panel();
		chatPanel.header = new Header("Chat");
		chatPanel.footer = footer;
		chatPanel.layoutData = AnchorLayoutData.fill();
		chatPanel.layout = new AnchorLayout();
		addChild(chatPanel);

		log = new TextArea();
		log.layoutData = AnchorLayoutData.fill();
		chatPanel.addChild(log);
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

	private function creationCompleteHandler(event:FeathersEvent):Void {
		consumer.subscribe();
	}

	private function messageHandler(event:MessageEvent):Void {
		var message = event.message;
		log.text += '${message.body.chatMessage}\n';
	}

	private function sendButton_triggerHandler(event:TriggerEvent):Void {
		var message = new AsyncMessage();
		message.body.chatMessage = msg.text;
		producer.send(message);
		msg.text = "";
	}
}
