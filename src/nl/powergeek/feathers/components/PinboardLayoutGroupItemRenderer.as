package nl.powergeek.feathers.components 
{
	import com.greensock.TweenLite;
	
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.renderers.LayoutGroupListItemRenderer;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.core.ITextRenderer;
	import feathers.events.FeathersEventType;
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
			_description:Label,
			_link:Label,
			_accessory:LayoutGroup,
			_hiddenContent:LayoutGroup,
			_padding:Number = 0,
			_backgroundSkin:DisplayObject;
		
		// state
		private var
			_hiddenContentHeight:Number = 0,
			defaultBackgroundColor:Number = 0x000000,
			highlightBackgroundColor:Number = 0x4499FF;
			
		// bookmark signals
		private var
			_deleteConfirmed:Signal,
			_editTapped:Signal,
			_editConfirmed:Signal,
			_dataChanged:Signal;
			
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
			this._description = new Label();
			var labelLayoutData:AnchorLayoutData = new AnchorLayoutData();
			labelLayoutData.top = this._padding;
			labelLayoutData.left = this._padding;
			this._description.layoutData = labelLayoutData;
			this._description.nameList.add(PinboredDesktopTheme.LABEL_BOOKMARK_DESCRIPTION);
			this.addChild(this._description);
			
			// add bookmark url label
			this._link = new Label();
			var hrefLayoutData:AnchorLayoutData = new AnchorLayoutData();
			hrefLayoutData.topAnchorDisplayObject = this._description;
			hrefLayoutData.top = this._padding / 6;
			hrefLayoutData.left = this._padding;
			this._link.layoutData = hrefLayoutData;
			this._link.nameList.add(PinboredDesktopTheme.LABEL_BOOKMARK_HREF);
			this.addChild(this._link);
			
			// set quick hit enabled to false
			this.isQuickHitAreaEnabled = false;
		}

		override protected function commitData():void
		{
			//trace('commitData of item at index: ' + this.index);
			
			if(this._data)
			{
				if(this._data.hasOwnProperty("description") && String(this._data.description).length > 0)
					this._description.text = this._data.description;
				else
					this._description.text = '[ no description ]';
				
				if(this._data.hasOwnProperty("link") && String(this._data.link).length > 0)
					this._link.text = this._data.link;
				else
					this._link.text = '[ no link ]';
				
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
							deleteSelf(BookMark(_data));
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
								expandSelf();
							} else if(isBeingEdited == true) {
								isBeingEdited = false;
								collapseSelf();
							}
						});
					}
				}
				
				// add general data changed listener
				if(this._data.hasOwnProperty("dataChanged")) {
					this._dataChanged = this._data.dataChanged;
					this._dataChanged.add(function():void {
						//trace('IR firing!');
						invalidate(INVALIDATION_FLAG_ALL);
						validate();
					});
				}
			}
			
			// dispatch commitData event
			dispatchEventWith(BookmarkEvent.ITEM_RENDERER_COMMIT_DATA);
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
			
			if(this.accessory) {
				this._description.maxWidth = this.actualWidth - ((this.padding * 6) + this.accessory.width);
				this._link.maxWidth = this.actualWidth - ((this.padding * 6) + this.accessory.width);
			} else {
				this._description.maxWidth = this.actualWidth - ((this.padding * 6));
				this._link.maxWidth = this.actualWidth - ((this.padding * 6));
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
				hiddenContentLayoutData.topAnchorDisplayObject = this._link;
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
		
		
		public function instaCollapse():void
		{
			if( this.hiddenContent )
			{
				if (_hiddenContent.height > 0 && _hiddenContentHeight == 0){
					_hiddenContentHeight = _hiddenContent.height;
				}
				if( isBeingEdited == false ) {
					//trace('insta collapsing HC!');
					_hiddenContent.height = 0;
					hiddenContentFadeOut();
					_hiddenContent.visible = false;
				}
			}
		}
		
		private function collapseSelf():void
		{
			dispatchEventWith(BookmarkEvent.BOOKMARK_FOLDING, false);
			_hiddenContent.visible = true;
			
			// fade out hidden content children
			hiddenContentFadeOut();
			
			// tween background color back to default
			tweenBackgroundColor(highlightBackgroundColor, defaultBackgroundColor);
			
			// tween out hidden content
			setTimeout(function():void {
				
				var tween:Tween = new Tween(_hiddenContent, PinboredDesktopTheme.LIST_ANIMATION_TIME / 2, Transitions.EASE_OUT);
				tween.animate("height", 0);
				tween.animate("scaleY", 0);
				tween.onComplete = function():void {
					_hiddenContent.visible = false;
					dispatchEventWith(BookmarkEvent.BOOKMARK_FOLDED, false);
				};
				
				Starling.current.juggler.add(tween);
				
			}, (PinboredDesktopTheme.LIST_ANIMATION_TIME / 2) * 1000);
			
		}
		
		private function expandSelf():void
		{
			dispatchEventWith(BookmarkEvent.BOOKMARK_EXPANDING, false);
			this._hiddenContent.visible = true;
			
			// tween hiddenContent
			var tween:Tween = new Tween(_hiddenContent, PinboredDesktopTheme.LIST_ANIMATION_TIME / 2, Transitions.EASE_OUT);
			tween.animate("height", _hiddenContentHeight);
			tween.animate("scaleY", 1);
			tween.onComplete = function():void {
				
				// fade out hidden content children
				hiddenContentFadeIn();
				
				// tween background color back to default
				tweenBackgroundColor(Quad(backgroundSkin).color, highlightBackgroundColor);
			}
			
			Starling.current.juggler.add(tween);
			
			dispatchEventWith(BookmarkEvent.BOOKMARK_EXPANDED, false);
		}
		
		private function deleteSelf(bookmark:BookMark):void {
			
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
		
		public function addSelf():void
		{
			// get the item real sizes
			var realHeight:Number = this.height;
			var realScaleY:Number = this.scaleY;
			var realWidth:Number = this.width;
			var realScaleX:Number = this.scaleX;
			
//			trace('IR: real height/width: ' + realHeight, realWidth);
//			trace('IR: real height - _hiddenContentHeight: ', realHeight - _hiddenContentHeight, realWidth);
			
			var fakeRealHeight:Number = realHeight - _hiddenContentHeight;
			
			if(realHeight > 0 && realWidth > 0) {
				
				this.width = 0;
				this.scaleX = 0;
//				this.height = 0;
//				this.scaleY = 0;
				
				// tween params
				var tween:Tween = new Tween(this, PinboredDesktopTheme.LIST_ANIMATION_TIME, Transitions.EASE_IN);
				
				tween.animate("width",  realWidth);
				tween.animate("scaleX", realScaleX);
//				tween.animate("height",  realHeight);
//				tween.animate("scaleY", realScaleY);
//				tween.onComplete = function():void {
//					// reset scaleY children
//					for(var n:uint = 0; n < _hiddenContent.numChildren; n++) {
//						var child:DisplayObject = _hiddenContent.getChildAt(n);
//						child.scaleY = 1;
//						_hiddenContent.invalidate(INVALIDATION_FLAG_ALL);
//					}
//				};
				
				Starling.current.juggler.add(tween);
			}
		}
		
		public function removeSelf():void
		{
			trace('IR being removed...');
		}
		
		private function tweenBackgroundColor(fromColor:uint, toColor:uint):void
		{
			if(backgroundSkin && contains(backgroundSkin)) {
				
				var color:Object = {background:fromColor};
				
				var testFunc:Function = function():void {
					Quad(backgroundSkin).color = color.background;
				};
				
				TweenLite.to(color, PinboredDesktopTheme.LIST_ANIMATION_TIME, {hexColors:{background:toColor}, onUpdate:testFunc});
			}
		}
		
		private function hiddenContentFadeOut():void
		{
			hiddenContentFade(0);
		}
		
		private function hiddenContentFadeIn():void
		{
			hiddenContentFade(1);
		}
		
		private function hiddenContentFade(alpha:Number):void
		{
			// tween out all children
			for(var n:uint = 0; n < _hiddenContent.numChildren; n++) {
				var child:DisplayObject = _hiddenContent.getChildAt(n);
				var childTween:Tween = new Tween(child, PinboredDesktopTheme.LIST_ANIMATION_TIME / 2, Transitions.EASE_OUT);
				childTween.animate("alpha", alpha);
				Starling.current.juggler.add(childTween);
			}
		}
		
		public function collapseOn(signal:Signal):void
		{
			signal.addOnce(function():void {
				collapseSelf();
			});
		}
	}
}