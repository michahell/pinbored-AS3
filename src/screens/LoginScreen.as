package screens
{
	import feathers.controls.Button;
	import feathers.controls.Callout;
	import feathers.controls.Header;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.Screen;
	import feathers.controls.ScrollContainer;
	import feathers.controls.TextInput;
	import feathers.core.FeathersControl;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.VerticalLayout;
	
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.textures.Texture;
	
	public class LoginScreen extends Screen
	{
		[Embed(source="assets/images/pinbored/pinbored-background.jpg")]
		public static const BACKGROUND:Class;
		
		private var 
			mainContainer:LayoutGroup,
			loginBoxOuter:LayoutGroup,
			loginBoxInner:LayoutGroup,
			loginboxBackground:Quad,
			loginHeader:Label,
			infoLabel:Label,
			tokenInput:TextInput,
			loginButton:Button,
			_backgroundImage:Image = new Image(Texture.fromBitmap(new BACKGROUND(), false));
			
		private var
			_onListScreenRequest:Signal = new Signal( LoginScreen );
		
		public function LoginScreen()
		{
			super()
		}
		
		override protected function initialize():void
		{
			// create GUI
			createGUI();
			
			// listen for transition complete
			owner.addEventListener(FeathersEventType.TRANSITION_COMPLETE, onTransitionComplete);
		}
		
		private function onTransitionComplete(event:Event):void
		{
			// remove listener
			owner.removeEventListener(FeathersEventType.TRANSITION_COMPLETE, onTransitionComplete);
		}
		
		private function createGUI():void
		{
			// create nice background
			this.addChild(_backgroundImage);
			
			// create center aligned layout
			mainContainer = new LayoutGroup();
			mainContainer.layout = new AnchorLayout();
			this.addChild(mainContainer);
			
			// create the outer loginbox container
			loginBoxOuter = new LayoutGroup();
			loginBoxOuter.width = 400;
			var al:AnchorLayoutData = new AnchorLayoutData();
			al.horizontalCenter = 0;
			al.verticalCenter = 0;
			loginBoxOuter.layoutData = al;
			this.mainContainer.addChild(this.loginBoxOuter);
			
			// create semi transparent quad inside loginbox
			loginboxBackground = new Quad(10, 10, 0x000000);
			loginboxBackground.alpha = 0.4;
			this.loginBoxOuter.addChild(loginboxBackground);
			
			// create inner loginbox container
			loginBoxInner = new LayoutGroup();
			loginBoxInner.width = 400;
			var loginBoxLayout:VerticalLayout = new VerticalLayout();
			loginBoxLayout.padding = 10;
			loginBoxLayout.gap = 10;
			loginBoxLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			loginBoxLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			loginBoxInner.layout = loginBoxLayout;
			var al2:AnchorLayoutData = new AnchorLayoutData();
			al2.horizontalCenter = 0;
			al2.verticalCenter = 0;
			loginBoxInner.layoutData = al2;
			this.mainContainer.addChild(this.loginBoxInner);
			
			// create a login label text
			loginHeader = new Label();
			loginHeader.nameList.add(Label.ALTERNATE_NAME_HEADING);
			loginHeader.text = 'login to use Pinbored';
			this.loginBoxInner.addChild(loginHeader);
			
			// create a sub login info label text
			infoLabel = new Label();
			infoLabel.text = 'with your Pinboard API token';
			this.loginBoxInner.addChild(infoLabel);
			
			// create a pinboard token input
			tokenInput = new TextInput();
			tokenInput.width = 250;
			tokenInput.prompt = 'pinboard token';
			this.loginBoxInner.addChild(tokenInput);
			
			// login button
			this.loginButton = new Button();
			this.loginButton.label = "Login";
			this.loginButton.nameList.add(Button.ALTERNATE_NAME_DANGER_BUTTON);
			this.loginButton.addEventListener( Event.TRIGGERED, loginTriggeredHandler );
			this.loginBoxInner.addChild( loginButton );
			
			draw();
		}
		
		override protected function draw():void
		{
			//runs every time invalidate() is called
			//a good place for measurement and layout
			
			// commit
			
			// measurement
			_backgroundImage.width = this.width;
			_backgroundImage.height = this.height;
			
			mainContainer.width = this.width;
			mainContainer.height = this.height;
			
			loginBoxOuter.width = loginBoxInner.width;
			loginBoxOuter.height = loginBoxInner.height;
			
			loginboxBackground.width = loginBoxOuter.width;
			loginboxBackground.height = loginBoxOuter.height;
			
			// layout
		}
		
		protected function loginTriggeredHandler( event:Event ):void
		{	
//			this.onListScreenRequest.dispatch( this );
		}

		public function get onListScreenRequest():ISignal
		{
			return _onListScreenRequest;
		}		
	}
}