package nl.powergeek.pinbored.screens
{
	import feathers.controls.Screen;
	import feathers.core.PopUpManager;
	
	import flash.utils.setTimeout;
	
	import nl.powergeek.feathers.themes.PinboredDesktopTheme;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.utils.deg2rad;
	
	public class AppScreen extends Screen
	{
		private var
			loadingIcon:Image = new Image(Texture.fromBitmap(new PinboredDesktopTheme.ICON_LOADING()));
			
			
		public function AppScreen()
		{
			super();
		}
		
		override protected function initialize():void {
			
			loadingIcon.visible = false;
			
		}
		
		public function showLoading():void {
			
			loadingIcon.alignPivot();
			loadingIcon.alpha = 0;
			loadingIcon.y = -30;
			loadingIcon.visible = true;
			
			PopUpManager.addPopUp(loadingIcon, true, true);
			
			loadingIcon.x = loadingIcon.x + loadingIcon.width / 2;
			
			this.addEventListener(Event.ENTER_FRAME, function(event:Event):void {
				if(loadingIcon.visible == true)
					loadingIcon.rotation += deg2rad(2);
				else
					removeEventListener(event.type, arguments.callee);
			});
			
			var tween:Tween = new Tween(loadingIcon, PinboredDesktopTheme.ANIMATION_TIME, Transitions.EASE_OUT);
			tween.animate("y", loadingIcon.y + 30);
			tween.animate("alpha", 1);
			
			Starling.current.juggler.add(tween);
		}
		
		public function hideLoading():void {
			
			if(loadingIcon.alpha > 0) {
				
				var tween:Tween = new Tween(loadingIcon, PinboredDesktopTheme.ANIMATION_TIME, Transitions.EASE_OUT);
				//tween.animate("y", loadingIcon.y - 30);
				tween.animate("alpha", 0);
				tween.onComplete = function():void {
					loadingIcon.visible = false;
					PopUpManager.removePopUp(loadingIcon, false);
				};
				
				Starling.current.juggler.add(tween);
			}
		}
	}
}