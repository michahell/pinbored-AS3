package nl.powergeek.feathers.components 
{
	import com.greensock.TweenLite;
	
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.renderers.LayoutGroupListItemRenderer;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.core.ITextRenderer;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.setTimeout;
	
	import nl.powergeek.feathers.themes.PinboredDesktopTheme;
	import nl.powergeek.pinbored.model.BookMark;
	import nl.powergeek.pinbored.model.BookmarkEvent;
	
	import org.osflash.signals.Signal;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.filters.ColorMatrixFilter;
	
	public class PinboardLayoutGroupItemRenderer extends LayoutGroupListItemRenderer
	{
		// content
		private var
			_label:Label,
			_href:Label,
			_accessory:LayoutGroup,
			_hiddenContent:LayoutGroup,
//			_icons:LayoutGroup,
			_padding:Number = 0,
			_backgroundSkin:DisplayObject;
		
		// state
		private var
			_hiddenContentHeight:Number = 0,
//			_currentState:String = STATE_UP,
//			touchID:int = -1,
			defaultBackgroundColor:Number = 0x000000,
			highlightBackgroundColor:Number = 0x4499FF;
			
		// bookmark signals
		private var
			_deleteConfirmed:Signal,
			_editTapped:Signal,
			_editConfirmed:Signal;
			
		public var
			isBeingEdited:Boolean = false;

		
		public function PinboardLayoutGroupItemRenderer() { }
		
		override protected function initialize():void
		{
			// add main layout
			this.layout = new AnchorLayout();
			
			// add background
			var bg:Quad = new Quad(10, 10, defaultBackgroundColor);
			bg.alpha = 0.3;
			this.backgroundSkin = bg;
			
			// add bookmark label description
			this._label = new Label();
			var labelLayoutData:AnchorLayoutData = new AnchorLayoutData();
			labelLayoutData.top = this._padding;
			labelLayoutData.left = this._padding;
			this._label.layoutData = labelLayoutData;
			this._label.nameList.add(PinboredDesktopTheme.LABEL_BOOKMARK_DESCRIPTION);
			this.addChild(this._label);
			
			// add bookmark url label
			this._href = new Label();
			var hrefLayoutData:AnchorLayoutData = new AnchorLayoutData();
			hrefLayoutData.topAnchorDisplayObject = this._label;
			hrefLayoutData.top = this._padding / 6;
			hrefLayoutData.left = this._padding;
			this._href.layoutData = hrefLayoutData;
			this._href.nameList.add(PinboredDesktopTheme.LABEL_BOOKMARK_HREF);
			this.addChild(this._href);
			
			// add touch handling
//			this.addEventListener(TouchEvent.TOUCH, touchHandler);
			
			// set quick hit enabled to false
			this.isQuickHitAreaEnabled = false;
		}
		
//		private function touchHandler(event:TouchEvent):void
//		{
//			if(!this._isEnabled)
//			{
//				// if we were disabled while tracking touches, clear the touch id.
//				this.touchID = -1;
//				
//				// the button should return to the up state, if it is disabled.
//				// you may also use a separate disabled state, if you prefer.
//				this.currentState = STATE_UP;
//				return;
//			}
//			
//			if( this.touchID >= 0 )
//			{
//				// a touch has begun, so we'll ignore all other touches.
//				
//				var touch:Touch = event.getTouch( this, null, this.touchID );
//				if( !touch )
//				{
//					// this should not happen.
//					return;
//				}
//				
//				if( touch.phase == TouchPhase.ENDED )
//				{
//					this.currentState = STATE_UP;
//					
//					// the touch has ended, so now we can start watching for a new one.
//					this.touchID = -1;
//				}
//				return;
//			}
//			else
//			{
//				// we aren't tracking another touch, so let's look for a new one.
//				
//				touch = event.getTouch( this, TouchPhase.BEGAN );
//				if( !touch )
//				{
//					// we only care about the began phase. ignore all other phases.
//					return;
//				}
//				
//				this.currentState = STATE_DOWN;
//				
//				// save the touch ID so that we can track this touch's phases.
//				this.touchID = touch.id;
//			}
//		}
		
		override protected function commitData():void
		{
			// trace('commitData of item at index: ' + this.index);
			
			if(this._data)
			{
				if(this._data.hasOwnProperty("description") && String(this._data.description).length > 0)
					this._label.text = this._data.description;
				else
					this._label.text = '[ no description ]';
				
				if(this._data.hasOwnProperty("link") && String(this._data.link).length > 0)
					this._href.text = this._data.link;
				else
					this._href.text = '[ no link ]';
				
				if(this._data.hasOwnProperty("accessory")) {
					this.accessory = this._data.accessory;
				}
				
				if(this._data.hasOwnProperty("hiddenContent")) {
					this.hiddenContent = this._data.hiddenContent;
				}
				
				// add delete confirmed listener for delete animation
				if(this._data.hasOwnProperty("deleteConfirmed")) {
					this._deleteConfirmed = this._data.deleteConfirmed;
					
					// attach delete listener IF there are none yet
					if(this._deleteConfirmed.numListeners == 0) {
						this._deleteConfirmed.addOnce(function():void{
							removeSelf(BookMark(_data));
						});
					}
				}
				
				// add editbutton listener
				if(this._data.hasOwnProperty("editTapped")) {
					this._editTapped = this._data.editTapped;
					
					// attach edit listener IF there are none yet
					if(this._editTapped.numListeners == 0) {
						this._editTapped.add(function():void{
							// switch isBeingEdited property
							if(isBeingEdited == false) {
								isBeingEdited = true;
								expandSelf(BookMark(_data));
							} else if(isBeingEdited == true) {
								isBeingEdited = false;
								foldSelf(BookMark(_data));
							}
						});
					}
				}
			}
		}
		
		
		override protected function preLayout():void
		{
			super.preLayout();
			
			if( this._backgroundSkin )
			{
				this._backgroundSkin.width = 0;
				this._backgroundSkin.height = 0;
			}
		}

		override protected function draw():void
		{
			super.draw();
		}
		
		override protected function postLayout():void
		{
			super.postLayout();
			
			if( this._backgroundSkin )
			{
				this._backgroundSkin.width = this.actualWidth;
				this._backgroundSkin.height = this.actualHeight;
				
				// color rows depending on even or uneven index
				if(isBeingEdited == false) {
					if(this.index % 2 == 0) {
						// item has even index
						Quad(this.backgroundSkin).color = 0x333333;
					} else {
						// item has uneven index
						Quad(this.backgroundSkin).color = 0x222222;
					}
				// or if currently highlighted the highlight bg color
				} else {
					Quad(this.backgroundSkin).color = highlightBackgroundColor;
				}
			}
			
			if( this.hiddenContent )
			{
				if (_hiddenContent.height > 0 && _hiddenContentHeight == 0){
					trace('hidden content height: ' + _hiddenContent.height);
					_hiddenContentHeight = _hiddenContent.height;
					if( isBeingEdited == false ) {
//						_hiddenContent.scaleY = 0;
						_hiddenContent.height = 0;
						_hiddenContent.visible = false;
					}
				}
			}
			
			this._label.maxWidth = this.actualWidth - ((this.padding * 6) + this.accessory.width);
			this._href.maxWidth = this.actualWidth - ((this.padding * 6) + this.accessory.width);
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
		
//		public function get currentState():String
//		{
//			return this._currentState;
//		}
//		
//		public function set currentState( value:String ):void
//		{
//			if( this._currentState == value )
//			{
//				return;
//			}
//			this._currentState = value;
//			this.invalidate( INVALIDATION_FLAG_STATE );
//		}
		
		public function get backgroundSkin():DisplayObject
		{
			return this._backgroundSkin;
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
				accessoryLayoutData.right = this._padding * 2;
				
				this._accessory.layoutData = accessoryLayoutData;
					
				this.addChild(this._accessory);
			}
			
			this.invalidate( INVALIDATION_FLAG_LAYOUT );
			this.invalidate( INVALIDATION_FLAG_SIZE );
			this.invalidate( INVALIDATION_FLAG_DATA );
		}

		public function get hiddenContent():LayoutGroup
		{
			return _hiddenContent;
		}

		public function set hiddenContent(value:LayoutGroup):void
		{
			if(this._hiddenContent == value)
			{
				return;
			}
			
			if(this._hiddenContent)
			{
				this.removeChild(this._hiddenContent, true);
			}
			
			this._hiddenContent = value;
			
			if(this._hiddenContent)
			{
				var hiddenContentLayoutData:AnchorLayoutData = new AnchorLayoutData();
				hiddenContentLayoutData.topAnchorDisplayObject = this._href;
				hiddenContentLayoutData.top = this._padding;
				hiddenContentLayoutData.left = this._padding;
				hiddenContentLayoutData.right = this._padding;
				hiddenContentLayoutData.bottom = this._padding;
				
				this._hiddenContent.layoutData = hiddenContentLayoutData;
				
				this.addChild(this._hiddenContent);
			}
			
			this.invalidate( INVALIDATION_FLAG_LAYOUT );
			this.invalidate( INVALIDATION_FLAG_SIZE );
			this.invalidate( INVALIDATION_FLAG_DATA );
		}
		
		private function foldSelf(bookmark:BookMark):void
		{
			dispatchEventWith(BookmarkEvent.BOOKMARK_FOLDING, false, bookmark);
			_hiddenContent.visible = true;
			
			// tween out all children
			for(var n:uint = 0; n < _hiddenContent.numChildren; n++) {
				var child:DisplayObject = _hiddenContent.getChildAt(n);
				var childTween:Tween = new Tween(child, PinboredDesktopTheme.LIST_ANIMATION_TIME / 2, Transitions.EASE_OUT);
				childTween.animate("alpha", 0);
				Starling.current.juggler.add(childTween);
			}
			
			// tween background color back to default
			if(backgroundSkin && contains(backgroundSkin)) {
				var color:Object = {background:highlightBackgroundColor};
				var testFunc:Function = function():void {
					Quad(backgroundSkin).color = color.background;
				};
				TweenLite.to(color, PinboredDesktopTheme.LIST_ANIMATION_TIME, {hexColors:{background:defaultBackgroundColor}, onUpdate:testFunc});
			}
			
			// tween out hidden content
			setTimeout(function():void {
				
				var tween:Tween = new Tween(_hiddenContent, PinboredDesktopTheme.LIST_ANIMATION_TIME / 2, Transitions.EASE_OUT);
				tween.animate("height", 0);
				tween.animate("scaleY", 0);
				tween.onComplete = function():void {
					_hiddenContent.visible = false;
					dispatchEventWith(BookmarkEvent.BOOKMARK_FOLDED, false, bookmark);
				};
				
				Starling.current.juggler.add(tween);
				
			}, (PinboredDesktopTheme.LIST_ANIMATION_TIME / 2) * 1000);
			
		}
		
		private function expandSelf(bookmark:BookMark):void
		{
			dispatchEventWith(BookmarkEvent.BOOKMARK_EXPANDING, false, bookmark);
			this._hiddenContent.visible = true;
			
			// tween hiddenContent
			var tween:Tween = new Tween(_hiddenContent, PinboredDesktopTheme.LIST_ANIMATION_TIME / 2, Transitions.EASE_OUT);
			tween.animate("height", _hiddenContentHeight);
			tween.animate("scaleY", 1);
			tween.onComplete = function():void {
				
				// tween background color to highlight color
				if(backgroundSkin && contains(backgroundSkin)) {
					var color:Object = {background:Quad(backgroundSkin).color};
					var testFunc:Function = function():void {
						Quad(backgroundSkin).color = color.background;
					};
					TweenLite.to(color, PinboredDesktopTheme.LIST_ANIMATION_TIME / 2, {hexColors:{background:highlightBackgroundColor}, onUpdate:testFunc});
				}
				
				// tween in all children
				for(var n:uint = 0; n < _hiddenContent.numChildren; n++) {
					var child:DisplayObject = _hiddenContent.getChildAt(n);
					var childTween:Tween = new Tween(child, PinboredDesktopTheme.LIST_ANIMATION_TIME / 2, Transitions.EASE_OUT);
					childTween.animate("alpha", 1);
					Starling.current.juggler.add(childTween);
					_hiddenContent.invalidate(INVALIDATION_FLAG_ALL);
				}
			}
			
			Starling.current.juggler.add(tween);
			
			dispatchEventWith(BookmarkEvent.BOOKMARK_EXPANDED, false, bookmark);
		}
		
		private function removeSelf(bookmark:BookMark):void {
			
			// first flatten self
			flatten();
			
			// tween params
			var tween:Tween = new Tween(this, PinboredDesktopTheme.LIST_ANIMATION_TIME, Transitions.EASE_IN_BACK);
			
			tween.animate("height", 0);
			tween.animate("scaleY", 0);
			tween.animate("width",  0);
			tween.animate("scaleX", 0);
			tween.animate("x", this.width / 2);
			
			tween.onComplete = function():void {
				dispatchEventWith(BookmarkEvent.BOOKMARK_DELETED, false, bookmark);
			};
			
			Starling.current.juggler.add(tween);
		}
		
		public function addSelf():void {
			
			var realHeight:Number = this.height;
			var realScaleY:Number = this.scaleY;
			var realWidth:Number = this.width;
			var realScaleX:Number = this.scaleX;
			
			trace('IR: real height/width: ' + realHeight, realWidth);
			
			if(realHeight > 0 && realWidth > 0) {
				
//				this.height = this.scaleY = this.width = this.scaleX = 0;
//				this.height = this.width = 0;
//				this.height = this.scaleY = 0;
				this.width = 0;
				this.scaleX = 0;
//				this.x = realWidth / 2;
				
				// tween params
				var tween:Tween = new Tween(this, PinboredDesktopTheme.LIST_ANIMATION_TIME * 2, Transitions.EASE_IN);
				
//				tween.animate("height", realHeight);
//				tween.animate("scaleY", realScaleY);
				tween.animate("width",  realWidth);
				tween.animate("scaleX", realScaleX);
//				tween.animate("x", -realWidth / 2);
				
				Starling.current.juggler.add(tween);
			}
		}
	}
}