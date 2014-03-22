package nl.powergeek.pinbored.screens
{
	import com.codecatalyst.promise.Promise;
	
	import feathers.controls.Button;
	import feathers.controls.Callout;
	import feathers.controls.Header;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.Screen;
	import feathers.controls.ScrollContainer;
	import feathers.controls.TextInput;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.core.FeathersControl;
	import feathers.core.ITextRenderer;
	import feathers.core.PopUpManager;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.VerticalLayout;
	
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import nl.powergeek.REST.RESTClient;
	import nl.powergeek.feathers.themes.PinboredDesktopTheme;
	import nl.powergeek.pinbored.model.AppModel;
	import nl.powergeek.pinbored.model.AppSettings;
	import nl.powergeek.pinbored.services.PinboardService;
	
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.utils.deg2rad;
	
	public class LoginScreen extends Screen
	{
		// GUI related
		private var 
			mainContainer:LayoutGroup,
			loginBoxOuter:LayoutGroup,
			loginBoxInner:LayoutGroup,
			iconContainer:LayoutGroup,
			loginboxBackground:Quad,
			loginHeader:Label,
			infoLabel:Label,
			usernameInput:TextInput,
			passwordInput:TextInput,
			loginButton:Button,
			_backgroundImage:Image = new Image(Texture.fromBitmap(new PinboredDesktopTheme.BACKGROUND1(), false));
			
		// signals
		private var
			_screenReference:LoginScreen,
			_onListScreenRequest:Signal = new Signal( LoginScreen );
			
		public const
			LOGINBOX_WIDTH:Number = 500,
			LOGINBOX_HEIGHT:Number = 300;

		private var 
			loadingIcon:Image = new Image(Texture.fromBitmap(new PinboredDesktopTheme.ICON_LOADING())),
			checkIcon:Image = new Image(Texture.fromBitmap(new PinboredDesktopTheme.ICON_CHECKMARK_WHITE())),
			crossIcon:Image = new Image(Texture.fromBitmap(new PinboredDesktopTheme.ICON_CROSS_WHITE()));
			
		
		public function LoginScreen()
		{
			super()
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			// create GUI
			createGUI();
			
			// listen for transition complete
			owner.addEventListener(FeathersEventType.TRANSITION_COMPLETE, onTransitionComplete);
		}
		
		private function onTransitionComplete(event:starling.events.Event):void
		{
			// remove listener
			owner.removeEventListener(FeathersEventType.TRANSITION_COMPLETE, onTransitionComplete);
		}
		
		private function createGUI():void
		{
			// store screenReference 
			this._screenReference = this;
			
			// create nice background
			this.addChild(_backgroundImage);
			
			// create center aligned layout
			mainContainer = new LayoutGroup();
			mainContainer.layout = new AnchorLayout();
			this.addChild(mainContainer);
			
			// create the outer loginbox container
			loginBoxOuter = new LayoutGroup();
			loginBoxOuter.width = LOGINBOX_WIDTH;
			loginBoxOuter.height = LOGINBOX_HEIGHT;
			var al:AnchorLayoutData = new AnchorLayoutData();
			al.horizontalCenter = 0;
			al.verticalCenter = 0;
			loginBoxOuter.layoutData = al;
			this.mainContainer.addChild(this.loginBoxOuter);
			
			// create semi transparent quad inside loginbox
			loginboxBackground = new Quad(LOGINBOX_WIDTH, 10, 0x000000);
			loginboxBackground.alpha = 0.4;
			this.loginBoxOuter.addChild(loginboxBackground);
			
			// create inner loginbox container
			loginBoxInner = new LayoutGroup();
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
			
			// create icon container
			iconContainer = new LayoutGroup();
			var iconContainerLayoutData:AnchorLayoutData = new AnchorLayoutData();
			iconContainerLayoutData.verticalCenter = 0;
			iconContainerLayoutData.bottom = 160;
			iconContainerLayoutData.horizontalCenter = 0;
			iconContainer.layoutData = iconContainerLayoutData;
			this.mainContainer.addChild(iconContainer);
			
			// add icons to iconContainer
			loadingIcon.alignPivot();
			checkIcon.alignPivot();
			crossIcon.alignPivot();
			loadingIcon.x = checkIcon.x = crossIcon.x = loadingIcon.width;
			this.iconContainer.addChild(loadingIcon);
			this.iconContainer.addChild(checkIcon);
			this.iconContainer.addChild(crossIcon);
			
			resetIcons();
			
			// create a login label text
			loginHeader = new Label();
			loginHeader.text = 'login to use Pinbored';
			this.loginBoxInner.addChild(loginHeader);
			
			// create a sub login info label text
			infoLabel = new Label();
			infoLabel.text = 'with your Pinboard API token';
			this.loginBoxInner.addChild(infoLabel);
			
			// create a username input
			usernameInput = new TextInput();
			usernameInput.width = 170;
			usernameInput.prompt = 'pinboard username';
			usernameInput.nameList.add(PinboredDesktopTheme.TEXTINPUT_TRANSLUCENT_BOX);
			this.loginBoxInner.addChild(usernameInput);
			
			// create a password input
			passwordInput = new TextInput();
			passwordInput.width = 170;
			passwordInput.prompt = 'pinboard password';
			passwordInput.nameList.add(PinboredDesktopTheme.TEXTINPUT_TRANSLUCENT_BOX);
			this.loginBoxInner.addChild(passwordInput);
			
			// login button
			this.loginButton = new Button();
			this.loginButton.label = "Login";
			this.loginButton.nameList.add(PinboredDesktopTheme.BUTTON_QUAD_CONTEXT_PRIMARY);
			this.loginButton.addEventListener(starling.events.Event.TRIGGERED, loginTriggeredHandler);
			this.addEventListener(FeathersEventType.ENTER, loginTriggeredEnterHandler);
			this.loginBoxInner.addChild( loginButton );
		}
		
		protected function resetIcons():void {
			loadingIcon.visible = checkIcon.visible = crossIcon.visible = false;
			loadingIcon.y = checkIcon.y = crossIcon.y = -30;
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
			
			loginboxBackground.width = loginBoxOuter.width;
			loginboxBackground.height = loginBoxOuter.height;
			
			// layout
		}
		
		protected function loginTriggeredEnterHandler( event:starling.events.Event ):void
		{	
			trace('enter pressed..');
			this.login();
		}
		
		protected function loginTriggeredHandler( event:starling.events.Event ):void
		{	
			this.login();
		}
		
		protected function showLoadingIcon():void 
		{
			resetIcons();
			
			loadingIcon.visible = true;
			loadingIcon.alpha = 0;
			loadingIcon.y = -30;
			
			this.addEventListener(starling.events.Event.ENTER_FRAME, function(event:starling.events.Event):void {
				if(loadingIcon.visible == true)
					loadingIcon.rotation += deg2rad(2);
				else
					removeEventListener(event.type, arguments.callee);
			});
			
			var tween:Tween = new Tween(loadingIcon, PinboredDesktopTheme.ANIMATION_TIME, Transitions.EASE_OUT_BOUNCE);
			tween.animate("y", loadingIcon.y + 30);
			tween.animate("alpha", 1);
			
			Starling.current.juggler.add(tween);
		}
		
		protected function showCrossIcon():void
		{
			resetIcons();
			
			crossIcon.visible = true;
			crossIcon.alpha = 0;
			crossIcon.y = -30;
			
			var tween:Tween = new Tween(crossIcon, PinboredDesktopTheme.ANIMATION_TIME, Transitions.EASE_OUT_BOUNCE);
			tween.animate("y", crossIcon.y + 30);
			tween.animate("alpha", 1);
			
			Starling.current.juggler.add(tween);
		}
		
		protected function showCheckIcon():void
		{
			resetIcons();
			
			checkIcon.visible = true;
			checkIcon.alpha = 0;
			checkIcon.y = -30;
			
			var tween:Tween = new Tween(checkIcon, PinboredDesktopTheme.ANIMATION_TIME, Transitions.EASE_OUT_BOUNCE);
			tween.animate("y", checkIcon.y + 30);
			tween.animate("alpha", 1);
			
			Starling.current.juggler.add(tween);
		}
		
		protected function login():void {
			
			// first, get the username and password
			var username:String = usernameInput.text;
			var password:String = passwordInput.text;
			
			// if we have username + password input
			if(username && username.length > 0 && password && password.length > 0) {
				
				// show loading modal
				showLoadingIcon();
				
				var showFailed:Function = function():void {
					// add cross icon
					showCrossIcon();
					
					setTimeout(function():void {
						resetIcons();
					}, 1000);
				}
				
				var requestCompleted:Function = function(event:flash.events.Event):void {
					
					// retrieve token
					var usertoken:String = new XML(event.target.data as String).text();
					
					// update RESTClient and request list screen
					if(usertoken && usertoken.length > 0) {
						
						// add confirmation icon
						showCheckIcon();
						
						// update REST
						RESTClient.setToken('?auth_token=', username + ':' + usertoken);
						RESTClient.setReturnType('&format=', 'json');
						
						// go to list screen
						setTimeout(function():void{
							resetIcons();
							onListScreenRequest.dispatch( _screenReference );
						}, 500);
					} else {
						showFailed();
					}
				};
				
				var requestFailed:Function = function(event:flash.events.Event):void {
					showFailed();
				};
				
				// perform getusertoken request
				PinboardService.getUserToken(username, password).then(requestCompleted, requestFailed);
				
			} else {
				//TODO handle username / password error etc.
				trace('error: no username or password provided!');
			}
		}

		public function get onListScreenRequest():ISignal
		{
			return _onListScreenRequest;
		}		
	}
}