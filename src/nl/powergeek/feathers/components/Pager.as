package nl.powergeek.feathers.components
{
	import com.codecatalyst.promise.Deferred;
	import com.codecatalyst.promise.Promise;
	
	import feathers.controls.Button;
	import feathers.controls.LayoutGroup;
	import feathers.controls.ScrollContainer;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalLayout;
	
	import flashx.textLayout.container.ISandboxSupport;
	
	import nl.powergeek.feathers.themes.PinboredDesktopTheme;
	
	import org.osflash.signals.Signal;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class Pager extends LayoutGroup
	{
		private var
			_buttonContainer:ScrollContainer,
			_buttons:Array = null,
			_leftFillerBackgroundFactory:Function = defaultFillerBackground,
			_rightFillerBackgroundFactory:Function = defaultFillerBackground,
			_completeFillerBackgroundFactory:Function = defaultFillerBackground,
			_leftFiller:DisplayObject,
			_rightFiller:DisplayObject,
			_completeFiller:DisplayObject;
			
	
		public const
			firstPageRequested:Signal = new Signal(),
			previousPageRequested:Signal = new Signal(),
			numberedPageRequested:Signal = new Signal(Number),
			nextPageRequested:Signal = new Signal(),
			lastPageRequested:Signal = new Signal();

		private var 
			first:Button,
			previous:Button,
			next:Button,
			last:Button,
			isActivated:Boolean = false,
			_maxResultPages:Number = 20,
			numResultPages:Number = -1,
			numCurrentPage:Number = -1;

			private var _buttonGroup:LayoutGroup;

			private var _backgroundGroup:LayoutGroup;
			
		
		public function Pager()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			// create GUI
			createGUI();
		}
		
		private function createGUI():void
		{
			// component layout
			var layout:AnchorLayout = new AnchorLayout()
			this.layout = layout;
			
			// create backgroundContainer
			_backgroundGroup = new LayoutGroup();
			_backgroundGroup.layout = new AnchorLayout();
			var backgld:AnchorLayoutData = new AnchorLayoutData();
			backgld.top = backgld.bottom = backgld.left = backgld.right = 0;
			_backgroundGroup.layoutData = backgld;
			addChild(_backgroundGroup);
			
			// create buttonLayoutContainer
			_buttonGroup = new LayoutGroup();
			var bgl:HorizontalLayout = new HorizontalLayout();
			bgl.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_TOP;
			bgl.horizontalAlign= HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
			bgl.paddingBottom = 1;
			bgl.paddingTop = 0;
			var bgld:AnchorLayoutData = new AnchorLayoutData();
			bgld.top = bgld.bottom = bgld.left = bgld.right = 0;
			_buttonGroup.layout = bgl;
			_buttonGroup.layoutData = bgld;
			addChild(_buttonGroup);
			
			// add buttoncontainer
			_buttonContainer = new ScrollContainer();
			var buttonContainerLayout:HorizontalLayout = new HorizontalLayout();
			buttonContainerLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_TOP;
			buttonContainerLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
			buttonContainerLayout.gap = 0;
			this._buttonContainer.layout = buttonContainerLayout;
			this._buttonContainer.scrollBarDisplayMode = ScrollContainer.SCROLL_BAR_DISPLAY_MODE_NONE;
			_buttonGroup.addChild(_buttonContainer);
			
			// create filler bg.
			_completeFiller = _completeFillerBackgroundFactory();
			
			// add filler background
			_backgroundGroup.addChild(_completeFiller);
		}
		
		protected function defaultFillerBackground():DisplayObject
		{
			var filler:Quad = new Quad(50, 500, 0x000000);
			filler.alpha = 0.5;
			return filler;
		}
		
		public function activate(resultPages:Number):void
		{
			CONFIG::TESTING {
				trace('pager ACTIVATE called..');
			}
			
			// first store resultPages
			this.numResultPages = resultPages;
			
			// first remove the first, previous, next, last buttons
			if(first && _buttonContainer.contains(first))
				_buttonContainer.removeChild(first);
			
			if(previous && _buttonContainer.contains(previous))
				_buttonContainer.removeChild(previous);
			
			if(next && _buttonContainer.contains(next))
				_buttonContainer.removeChild(next);
			
			if(last && _buttonContainer.contains(last))
				_buttonContainer.removeChild(last);
			
			if(resultPages > 1) {
				
				// create first button
				first = new Button();
				first.label = '<< FIRST';
				first.nameList.add(PinboredDesktopTheme.BUTTON_PAGER_SMALL_DEFAULT);
				first.addEventListener(Event.TRIGGERED, onFirstHandler);
				_buttonContainer.addChild(first);
				
				// create previous button
				previous = new Button();
				previous.label = '< PREV';
				previous.nameList.add(PinboredDesktopTheme.BUTTON_PAGER_SMALL_DEFAULT);
				previous.addEventListener(Event.TRIGGERED, onPrevHandler);
				_buttonContainer.addChild(previous);
				
				// create n number of buttons for n result pages
				createResultPageButtons(resultPages);
				
				// create next button
				next = new Button();
				next.label = 'NEXT >';
				next.nameList.add(PinboredDesktopTheme.BUTTON_PAGER_SMALL_DEFAULT);
				next.addEventListener(Event.TRIGGERED, onNextHandler);
				_buttonContainer.addChild(next);
				
				// create last button
				last = new Button();
				last.label = 'LAST >>';
				last.nameList.add(PinboredDesktopTheme.BUTTON_PAGER_SMALL_DEFAULT);
				last.addEventListener(Event.TRIGGERED, onLastHandler);
				_buttonContainer.addChild(last);
				
				isActivated = true;
			}
			
			invalidate(INVALIDATION_FLAG_ALL);
			_buttonContainer.invalidate(INVALIDATION_FLAG_ALL);
			_buttonGroup.invalidate(INVALIDATION_FLAG_ALL);
			validate();
		}
		
		private function createResultPageButtons(totalResultPages:Number, currentPage:Number = 1):void
		{
			// first remove old buttons
			if(_buttons && _buttons.length > 0) {
				CONFIG::TESTING {
					trace('removing previous pager buttons...' + _buttons.length);
				}
				while(_buttons.length > 0) {
					var removedButton:Button = Button(_buttons.pop());
					removedButton.removeEventListeners();
					_buttonContainer.removeChild(removedButton, true);
				}
			}
			
			// truncate buttons array
			_buttons = new Array();
			
			// create range of _maxResultPages number of buttons for n result pages
			var numSideButtons:uint = _maxResultPages / 2;
			var rangeStart:Number;
			var rangeEnd:Number;
			
			// calculate how many extra buttons we need left or right, depending on how 'far' we are to the left
			// or to the right of the total amount of result pages.
			var moreRightButtons:uint = numSideButtons - Math.min(currentPage, numSideButtons);
			var moreLeftButtons:uint = numSideButtons - Math.min(totalResultPages - currentPage, numSideButtons); 
				
			// calculate the range start and end numbers
			rangeStart = Math.max(currentPage - numSideButtons - moreLeftButtons, 1);
			rangeEnd = Math.min(currentPage + numSideButtons + moreRightButtons, totalResultPages);
			
			CONFIG::TESTING {
				trace('rangeStart: ' + rangeStart, 'rangeEnd:', rangeEnd);
			}
			
			for (var i:uint = rangeStart; i <= rangeEnd; i++) {
				var button:Button = new Button();
				button.label = i.toString();
				button.nameList.add(PinboredDesktopTheme.BUTTON_NUMBERED_PAGER_SMALL_DEFAULT);
				button.addEventListener(Event.TRIGGERED, onNumberButtonHandler);
				_buttons.push(button);
				_buttonContainer.addChild(button);
			}
		}
		
		public function update(pageNumber:Number):void
		{
			if (isActivated && pageNumber > 0) {
				
				// recreate center buttons!
				createResultPageButtons(numResultPages, pageNumber);
				
				// re-add next and last buttons
				_buttonContainer.removeChild(last);
				_buttonContainer.removeChild(next);
				_buttonContainer.addChild(next);
				_buttonContainer.addChild(last);
				
				// enable all buttons
				first.isEnabled = true;
				previous.isEnabled = true;
				next.isEnabled = true;
				last.isEnabled = true;
				_buttons.forEach(function(button:Button, index:uint, array:Array):void {
					button.isEnabled = true;
				});
				
				// disable buttons based on current page number
				if(pageNumber == 1) {
					first.isEnabled = false;
					previous.isEnabled = false;
				} else if(pageNumber == numResultPages) {
					last.isEnabled = false;
					next.isEnabled = false;
				}
				
				// highlight current page number button
				_buttons.forEach(function(button:Button, index:uint, array:Array):void {
					if(button.label == pageNumber.toString()) {
						button.isEnabled = false;
					}
				});
				
			}
			
			invalidate(INVALIDATION_FLAG_ALL);
			_buttonContainer.invalidate(INVALIDATION_FLAG_ALL);
			_buttonGroup.invalidate(INVALIDATION_FLAG_ALL);
			validate();
		}
		
		private function fade(alpha:Number):Promise
		{
			var deferred:Deferred = new Deferred();
			
			var tween:Tween = new Tween(_buttonContainer, PinboredDesktopTheme.LIST_ANIMATION_TIME, Transitions.EASE_OUT);
			tween.animate("alpha", alpha);
			
			// completed
			tween.onComplete = function():void {
				deferred.resolve('yay!');
			};
			
			Starling.current.juggler.add(tween);
			
			return deferred.promise;
		}
		
		private function onFirstHandler(event:Event):void
		{
			firstPageRequested.dispatch();
		}
		
		private function onPrevHandler(event:Event):void
		{
			previousPageRequested.dispatch();
		}
		
		private function onNumberButtonHandler(event:Event):void
		{
			var number:Number = Number((event.target as Button).label);
			numberedPageRequested.dispatch(number);
		}
		
		private function onNextHandler(event:Event):void
		{
			nextPageRequested.dispatch();
		}
		
		private function onLastHandler(event:Event):void
		{
			lastPageRequested.dispatch();
		}
		
		override protected function draw():void
		{
			this._backgroundGroup.width = this.width;
			this._buttonGroup.width = this.width;
			
			if(this.visible && _buttonContainer.height > 0) {
				this.height = _buttonContainer.height + HorizontalLayout(_buttonGroup.layout).paddingTop + HorizontalLayout(_buttonGroup.layout).paddingBottom;
			} else {
				this.height = 0;
			}
			
			// update filler background
			_completeFiller.width = this._backgroundGroup.width;
			_completeFiller.height = _buttonContainer.height;
			
			super.draw();
		}
		
		public function fadeOut():void
		{
			fade(0);
		}
		
		public function fadeIn():void
		{
			fade(1);
		}
	}
}