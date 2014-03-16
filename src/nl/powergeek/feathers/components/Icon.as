package nl.powergeek.feathers.components
{
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	
	public class Icon extends Sprite
	{
		private var
			normalState:Image = null,
			activeState:Image = null,
			inactiveState:Image = null,
			hoverState:Image = null;
			
		/**
		 * @param params normal, active are required states and so these should be set at least. inactive and hoverstate are optional. example: 
		 * var params:Object = { normal:someImage, active:someImage, inactive:someImage, hover:someImage };
		 * @param enableHover set this to true if you want to activate the hoverstate (mouse over or hover or touch tap! important difference). 
		 * And of course you need to pass a hover image in the params.
		 */		
		public function Icon(params:Object, enableHover:Boolean = false, scaleFix:Number = 1)
		{
			super();
			
			if(params) {
				if(params.hasOwnProperty('normal'))
					this.normalState = params.normal;
				
				if(params.hasOwnProperty('active'))
					this.activeState = params.active;
				
				if(params.hasOwnProperty('inactive'))
					this.inactiveState = params.inactive;
					
				if(params.hasOwnProperty('hover'))
					this.hoverState = params.hover;
			} else {
				throw new Error('hold the fucking fun bus i need some icons to initialize!');
			}
			
			// if hover is enabled, add a listener to detect hovers
			if(enableHover == true && this.hoverState != null) {
				this.addEventListener(TouchEvent.TOUCH, onTouch);
			}
			
			// set the normal and invisible state by default
			this.setNormal();
//			this.setInvisible();
			
			// scale icon back a bit
			this.scaleX = this.scaleY = scaleFix;
		}
		
		private function onTouch(event:TouchEvent):void
		{
			this.setActive();
		}
		
		private function removeAll():void {
			if(this.normalState && this.contains(this.normalState))
				this.removeChild(this.normalState);
			
			if(this.activeState && this.contains(this.activeState))
				this.removeChild(this.activeState);
			
			if(this.inactiveState && this.contains(this.inactiveState))
				this.removeChild(this.inactiveState);
			
			if(this.hoverState && this.contains(this.hoverState))
				this.removeChild(this.hoverState);
		}
		
		private function setInvisible():void
		{
			if(this.normalState && this.contains(this.normalState))
				this.normalState.visible = false;
			
			if(this.activeState && this.contains(this.activeState))
				this.activeState.visible = false;
			
			if(this.inactiveState && this.contains(this.inactiveState))
				this.inactiveState.visible = false;
			
			if(this.hoverState && this.contains(this.hoverState))
				this.hoverState.visible = false;
		}
		
		public function setNormal():void {
			this.removeAll();
			this.alpha = 0.1;
			this.normalState.visible = true;
			this.addChild(this.normalState);
		}
		
		public function setActive():void {
			this.removeAll();
			this.alpha = 1;
			this.activeState.visible = true;
			this.addChild(this.activeState);
		}
		
		public function setInactive():void {
			this.removeAll();
			this.alpha = 1;
			this.inactiveState.visible = true;
			this.addChild(this.inactiveState);
		}
		
		public function setHover():void {
			this.removeAll();
			this.alpha = 1;
			this.hoverState.visible = true;
			this.addChild(this.hoverState);
		}
		
	}
}