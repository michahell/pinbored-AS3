package
{
	import feathers.controls.Button;
	import feathers.controls.Callout;
	import feathers.controls.Label;
	import feathers.controls.Screen;
	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	import feathers.system.DeviceCapabilities;
	import feathers.themes.AeonDesktopTheme;
	import feathers.themes.MetalWorksMobileTheme;
	import feathers.themes.MinimalMobileTheme;
	
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.ResizeEvent;
	import starling.text.TextField;
	import screens.ListScreen;
	import screens.LoginScreen;
	
	public class App extends Sprite
	{
		private static const LOGIN_SCREEN:String = "LoginScreen";
		private static const LIST_SCREEN:String = "ListScreen";
		
		private var 
			navigator:ScreenNavigator;
		
		public function App()
		{	
			this.addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );
		}
		
		private function addedToStageHandler( event:Event ):void
		{
			new MetalWorksMobileTheme();
			// new MinimalMobileTheme();
			// new AeonDesktopTheme();
			
			this.navigator = new ScreenNavigator();
			this.addChild(this.navigator);
			
			AppModel.navigator = this.navigator;
			
			AppModel.resized.add(function():void {
				var activeScreen:Screen = Screen(AppModel.navigator.activeScreen);
				activeScreen.invalidate();
			});
			
			// add screens to the navigator
			this.navigator.addScreen( LOGIN_SCREEN, new ScreenNavigatorItem(LoginScreen, { onListScreenRequest: LIST_SCREEN }) );
			this.navigator.addScreen( LIST_SCREEN, new ScreenNavigatorItem(ListScreen));
			
			// show login screen
			this.navigator.showScreen( LIST_SCREEN );
		}
	}
}