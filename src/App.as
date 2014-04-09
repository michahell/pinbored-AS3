package
{
	import feathers.controls.Button;
	import feathers.controls.Callout;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.Screen;
	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	import feathers.core.FocusManager;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	import feathers.motion.transitions.ScreenFadeTransitionManager;
	import feathers.motion.transitions.ScreenSlidingStackTransitionManager;
	import feathers.system.DeviceCapabilities;
	import feathers.themes.MetalWorksMobileTheme;
	
	import nl.powergeek.REST.RESTClient;
	import nl.powergeek.feathers.themes.PinboredDesktopTheme;
	import nl.powergeek.pinbored.model.AppModel;
	import nl.powergeek.pinbored.screens.ListScreen;
	import nl.powergeek.pinbored.screens.LoginScreen;
	
	import starling.animation.Transitions;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.ResizeEvent;
	import starling.text.TextField;
	
	public class App extends Sprite
	{
		private static const LOGIN_SCREEN:String = "LoginScreen";
		private static const LIST_SCREEN:String = "ListScreen";
		
		private var 
			_navigator:ScreenNavigator,
			_transitionManager:ScreenFadeTransitionManager;
//			_transitionManager:ScreenSlidingStackTransitionManager;
		
		public function App()
		{	
			this.addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );
		}
		
		private function addedToStageHandler( event:Event ):void
		{
			// initialize theme
			new PinboredDesktopTheme();
			
			// initialize REST client
			RESTClient.initialize(AppModel.PINBOARD_BASE_API_URL);
			
			// enable FocusManager
			FocusManager.isEnabled = true;
			
			// add navigator (screens)
			this._navigator = new ScreenNavigator();
			this.addChild(this._navigator);
			
//			this._transitionManager = new ScreenSlidingStackTransitionManager( this._navigator );
			this._transitionManager = new ScreenFadeTransitionManager( this._navigator );
			this._transitionManager.duration = 0.75;
			this._transitionManager.ease = Transitions.EASE_IN_OUT;
			
			AppModel.navigator = this._navigator;
			
			AppModel.resized.add(function():void {
				var activeScreen:Screen = Screen(AppModel.navigator.activeScreen);
				activeScreen.invalidate();
			});
			
			// add screens to the navigator
			this._navigator.addScreen( LOGIN_SCREEN, new ScreenNavigatorItem(LoginScreen, { onListScreenRequest: LIST_SCREEN }) );
			this._navigator.addScreen( LIST_SCREEN, new ScreenNavigatorItem(ListScreen, { onLoginScreenRequest: LOGIN_SCREEN }) );
			
			// show login screen
			this._navigator.showScreen( LOGIN_SCREEN );
			
			//TODO update XML manifest for nice AIR package description etc.
			//TODO put all trace statements inside conditional compile
		}
	}
}