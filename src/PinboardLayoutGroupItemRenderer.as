package 
{
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.renderers.LayoutGroupListItemRenderer;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.core.ITextRenderer;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class PinboardLayoutGroupItemRenderer extends LayoutGroupListItemRenderer
	{
		public static const 
			STATE_UP:String = "up",
			STATE_DOWN:String = "down",
			STATE_HOVER:String = "hover";
			
		private var
			_label:Label,
			_href:Label,
			_accessory:LayoutGroup,
			_padding:Number = 0,
			_currentState:String = STATE_UP,
			_backgroundSkin:DisplayObject,
			touchID:int = -1;
		
		public function PinboardLayoutGroupItemRenderer() { }
		
		override protected function initialize():void
		{
			this.layout = new AnchorLayout();
			this.backgroundSkin = new Quad(2, 2, 0x333333);
			this._label = new Label();
			this._href = new Label();
			
			var labelLayoutData:AnchorLayoutData = new AnchorLayoutData();
			labelLayoutData.top = this._padding;
			labelLayoutData.bottom = this._padding;
			labelLayoutData.left = this._padding;
			
			var hrefLayoutData:AnchorLayoutData = new AnchorLayoutData();
			hrefLayoutData.topAnchorDisplayObject = this._label;
			hrefLayoutData.bottom = this._padding;
			hrefLayoutData.left = this._padding;
			
			
			this._label.layoutData = labelLayoutData;
			this._label.nameList.add(Label.ALTERNATE_NAME_HEADING);
				
			this._label.textRendererFactory = function():ITextRenderer
			{
				var textRenderer:TextFieldTextRenderer = new TextFieldTextRenderer();
				textRenderer.textFormat = new TextFormat("Arial", 24, 0xFF0000, true);
				textRenderer.embedFonts = true;
				textRenderer.isHTML = true;
				return textRenderer;
			}
			
			this._href.layoutData = hrefLayoutData;
			
			this._href.textRendererFactory = function():ITextRenderer
			{
				var textRenderer:TextFieldTextRenderer = new TextFieldTextRenderer();
				textRenderer.textFormat = new TextFormat("Arial", 16, 0x0000FF, false, false, true);
				textRenderer.embedFonts = true;
				textRenderer.isHTML = true;
				return textRenderer;
			}
			
			this.addChild(this._label);
			this.addChild(this._href);
			
			this.addEventListener(TouchEvent.TOUCH, touchHandler);
		}
		
		private function touchHandler(event:TouchEvent):void
		{
			if(!this._isEnabled)
			{
				// if we were disabled while tracking touches, clear the touch id.
				this.touchID = -1;
				
				// the button should return to the up state, if it is disabled.
				// you may also use a separate disabled state, if you prefer.
				this.currentState = STATE_UP;
				return;
			}
			
			if( this.touchID >= 0 )
			{
				// a touch has begun, so we'll ignore all other touches.
				
				var touch:Touch = event.getTouch( this, null, this.touchID );
				if( !touch )
				{
					// this should not happen.
					return;
				}
				
				if( touch.phase == TouchPhase.ENDED )
				{
					this.currentState = STATE_UP;
					
					// the touch has ended, so now we can start watching for a new one.
					this.touchID = -1;
				}
				return;
			}
			else
			{
				// we aren't tracking another touch, so let's look for a new one.
				
				touch = event.getTouch( this, TouchPhase.BEGAN );
				if( !touch )
				{
					// we only care about the began phase. ignore all other phases.
					return;
				}
				
				this.currentState = STATE_DOWN;
				
				// save the touch ID so that we can track this touch's phases.
				this.touchID = touch.id;
			}
		}
		
		public function get padding():Number
		{
			return this._padding;
		}
		
		public function set padding(value:Number):void
		{
			if(this._padding == value)
			{
				return;
			}
			this._padding = value;
			this.invalidate(INVALIDATION_FLAG_LAYOUT);
		}
		
		override protected function preLayout():void
		{
			if( this._backgroundSkin )
			{
				this._backgroundSkin.width = 0;
				this._backgroundSkin.height = 0;
			}
		}
		
		public function get currentState():String
		{
			return this._currentState;
		}
		
		public function set currentState( value:String ):void
		{
			if( this._currentState == value )
			{
				return;
			}
			this._currentState = value;
			this.invalidate( INVALIDATION_FLAG_STATE );
		}
		
		override protected function commitData():void
		{
			if(this._data)
			{
				if(this._data.hasOwnProperty("extended") && String(this._data.extended).length > 0)
					this._label.text = this._data.extended;
				else
					this._label.text = '[ no extended description ]';
				
				if(this._data.hasOwnProperty("href") && String(this._data.href).length > 0)
					this._href.text = this._data.href;
				else
					this._href.text = '[ no link ]';
				
				if(this._data.hasOwnProperty("accessory"))
					this.accessory = this._data.accessory;	
			}
		}
		
		public function get backgroundSkin():DisplayObject
		{
			return this._backgroundSkin;
		}
		
		override protected function postLayout():void
		{
			if( this._backgroundSkin )
			{
				this._backgroundSkin.width = this.actualWidth;
				this._backgroundSkin.height = this.actualHeight;
			}
			
			// color rows depending on even or uneven index
			if(this.index % 2 == 0) {
				// item has even index
				Quad(this.backgroundSkin).setVertexColor(0, 0x333333);
				Quad(this.backgroundSkin).setVertexColor(1, 0x333333);
				Quad(this.backgroundSkin).setVertexColor(2, 0x333333);
				Quad(this.backgroundSkin).setVertexColor(3, 0x333333);
			} else {
				// item has uneven index
				Quad(this.backgroundSkin).setVertexColor(0, 0x2D2D2D);
				Quad(this.backgroundSkin).setVertexColor(1, 0x2D2D2D);
				Quad(this.backgroundSkin).setVertexColor(2, 0x2D2D2D);
				Quad(this.backgroundSkin).setVertexColor(3, 0x2D2D2D);
			}
			
			this._label.maxWidth = this.actualWidth - ((this.padding * 6) + this.accessory.width);
			this._href.maxWidth = this.actualWidth - ((this.padding * 6) + this.accessory.width);
		}
		
		public function set backgroundSkin(value:DisplayObject):void
		{
			if(this._backgroundSkin == value)
			{
				return;
			}
			
			if(this._backgroundSkin)
			{
				this.removeChild(this._backgroundSkin, true);
			}
			
			this._backgroundSkin = value;
			
			if(this._backgroundSkin)
			{
				this.addChildAt(this._backgroundSkin, 0);
			}
			
			this.invalidate(INVALIDATION_FLAG_SKIN);
		}
		
		public function get accessory():LayoutGroup
		{
			return _accessory;
		}

		public function set accessory(value:LayoutGroup):void
		{
			if(this._accessory == value)
			{
				return;
			}
			
			if(this._accessory)
			{
				this.removeChild(this._accessory, true);
			}
			
			this._accessory = value;
			
			if(this._accessory)
			{
				var accessoryLayoutData:AnchorLayoutData = new AnchorLayoutData();
				accessoryLayoutData.top = this._padding;
				accessoryLayoutData.right = this._padding * 3;
				accessoryLayoutData.bottom = this._padding;
				
				this._accessory.layoutData = accessoryLayoutData;
					
				this.addChild(this._accessory);
			}
			
			this.invalidate( INVALIDATION_FLAG_STATE );
		}

	}
}