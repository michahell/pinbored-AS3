package
{
	import feathers.system.DeviceCapabilities;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.ui.ContextMenu;
	
	import starling.core.Starling;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	import nl.powergeek.pinbored.model.AppModel;
	import nl.powergeek.pinbored.model.AppSettings;
	
	[SWF(width="1024",height="768",frameRate="45",backgroundColor="#2f2f2f")]
	public class pinbored extends Sprite
	{
		private var _starling:Starling;
		
		public function pinbored()
		{
			var menu:ContextMenu = new ContextMenu();
			menu.hideBuiltInItems();
			this.contextMenu = menu;
			
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.mouseChildren = false;
			this.mouseEnabled = this.mouseChildren = false;
			
			// pretends to be an iPhone Retina screen
			DeviceCapabilities.dpi = Math.floor(326 / AppSettings.SCALE_DOWN_FACTOR);
			DeviceCapabilities.screenPixelWidth = 1024;
			DeviceCapabilities.screenPixelHeight = 768;
			
			// create starling instance
			this._starling = new Starling(App, stage);
			if(AppSettings.SHOW_STATS) {
				this._starling.showStats = true;
				this._starling.showStatsAt(HAlign.LEFT, VAlign.BOTTOM);
			}
			
			// set starling properties
			this._starling.antiAliasing = AppSettings.ANTI_ALIAS;
			
			// run starling
			this._starling.start();
			
			// pass starling reference to appmodel
			AppModel.starling = this._starling;
			
			// add stage listeners
			this.stage.addEventListener(Event.RESIZE, stage_resizeHandler, false, int.MAX_VALUE, true);
			this.stage.addEventListener(Event.DEACTIVATE, stage_deactivateHandler, false, 0, true);

		}
		
		private function stage_resizeHandler(event:Event):void
		{
			AppModel.resized.dispatch(event);
				
			this._starling.stage.stageWidth = this.stage.stageWidth;
			this._starling.stage.stageHeight = this.stage.stageHeight;
			
			const viewPort:Rectangle = this._starling.viewPort;
			viewPort.width = this.stage.stageWidth;
			viewPort.height = this.stage.stageHeight;
			
			try
			{
				this._starling.viewPort = viewPort;
			}
			catch(error:Error) {}
			
			this._starling.showStatsAt(HAlign.LEFT, VAlign.BOTTOM);
		}
		
		private function stage_deactivateHandler(event:Event):void
		{
			this._starling.stop();
			this.stage.addEventListener(Event.ACTIVATE, stage_activateHandler, false, 0, true);
		}
		
		private function stage_activateHandler(event:Event):void
		{
			this.stage.removeEventListener(Event.ACTIVATE, stage_activateHandler);
			this._starling.start();
		}
	}
}

