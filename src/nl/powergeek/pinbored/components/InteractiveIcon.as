package nl.powergeek.pinbored.components
{
	import feathers.controls.LayoutGroup;
	import feathers.layout.HorizontalLayout;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class InteractiveIcon extends Sprite
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
		public function InteractiveIcon(params:Object, enableHover:Boolean = false, screenDPIscale:Number = 1, additionalScaleFix:Number = 0.5)
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
				this.useHandCursor = true;
				this.addEventListener(TouchEvent.TOUCH, onTouch);
			}
			
			// set the normal and invisible state by default
			this.setNormal();
			
			// scale icon back a bit
			this.scaleX = this.scaleY = (screenDPIscale * additionalScaleFix);
		}
		
		private function onTouch(event:TouchEvent):void
		{
			if (event.getTouch(this, TouchPhase.HOVER))
			{
				this.setHover();
			}
			else
			{
				this.setNormal();
			}
			
			if (event.getTouch(this, TouchPhase.ENDED))
			{
				this.setActive();
			}
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
		
		public function setNormal():void {
			this.removeAll();
			this.addChild(this.normalState);
		}
		
		public function setActive():void {
			this.removeAll();
			this.addChild(this.activeState);
		}
		
		public function setInactive():void {
			this.removeAll();
			this.addChild(this.inactiveState);
		}
		
		public function setHover():void {
			this.removeAll();
			this.addChild(this.hoverState);
		}
		
	}
}