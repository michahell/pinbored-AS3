package
{
	import feathers.controls.Button;
	import feathers.controls.Callout;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.Screen;
	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	import feathers.motion.transitions.ScreenSlidingStackTransitionManager;
	import feathers.system.DeviceCapabilities;
	import feathers.themes.AeonDesktopTheme;
	import feathers.themes.MetalWorksMobileTheme;
	import feathers.themes.MinimalMobileTheme;
	
	import nl.powergeek.feathers.themes.PinboredMobileTheme;
	
	import screens.ListScreen;
	import screens.LoginScreen;
	
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
//			_mainContainer:LayoutGroup,
//			_navbar:LayoutGroup,
			_navigator:ScreenNavigator,
			_transitionManager:ScreenSlidingStackTransitionManager;
		
		public function App()
		{	
			this.addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );
		}
		
		private function addedToStageHandler( event:Event ):void
		{
			new PinboredMobileTheme();
			
			// first create main container
//			_mainContainer = new LayoutGroup();
//			var maincontainerLayout:VerticalLayout = new VerticalLayout();
//			maincontainerLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
//			maincontainerLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
//			maincontainerLayout.padding = 0;
//			maincontainerLayout.gap = 0;
//			_mainContainer.layout = maincontainerLayout;
//			this.addChild(_mainContainer);
//			
//			// add a simple navbar
//			_navbar = new LayoutGroup();
//			_navbar.layout = new AnchorLayout();
//			_navbar.layoutData = new AnchorLayoutData(0, 0, 0, 0);
//			this._mainContainer.addChild(_navbar);
//			
//			// add a horizontal button group to the layout
//			var _buttonbar:LayoutGroup = new LayoutGroup();
//			var _buttonbarLayout:HorizontalLayout = new HorizontalLayout();
//			_buttonbarLayout.padding = 5;
//			_buttonbarLayout.gap = 5;
//			_buttonbar.layout = _buttonbarLayout; 
//			_navbar.addChild(_buttonbar);
//			
//			// add some buttons to the buttongroup
//			var _bookmarksButton:Button = new Button();
//			_bookmarksButton.label = 'bookmarks';
//			_bookmarksButton.nameList.add(PinboredMobileTheme.ALTERNATE_NAME_NAVIGATION_BUTTON);
//			_buttonbar.addChild(_bookmarksButton);
			
			
			// add navigator (screens)
			this._navigator = new ScreenNavigator();
			this.addChild(this._navigator);
			
			this._transitionManager = new ScreenSlidingStackTransitionManager( this._navigator );
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
		}
	}
}