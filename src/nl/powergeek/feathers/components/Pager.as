package nl.powergeek.feathers.components
{
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
			_leftFiller:DisplayObject,
			_rightFiller:DisplayObject;
			
	
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
			var layout:HorizontalLayout = new HorizontalLayout()
			layout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_TOP;
			layout.horizontalAlign= HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
			layout.paddingBottom = 1;
			layout.paddingTop = 0;
			this.layout = layout;
			
			// create fillers
			_leftFiller = _leftFillerBackgroundFactory();
			_rightFiller = _rightFillerBackgroundFactory();
			
			// add left filler
			addChild(_leftFiller);
			
			// add buttoncontainer
			_buttonContainer = new ScrollContainer();
			var buttonContainerLayout:HorizontalLayout = new HorizontalLayout();
			buttonContainerLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_TOP;
			buttonContainerLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
			buttonContainerLayout.gap = 0;
			this._buttonContainer.layout = buttonContainerLayout;
			this._buttonContainer.scrollBarDisplayMode = ScrollContainer.SCROLL_BAR_DISPLAY_MODE_NONE;
			addChild(_buttonContainer);
			
			// add right filler
			addChild(_rightFiller);
		}
		
		protected function defaultFillerBackground():DisplayObject
		{
			var filler:Quad = new Quad(10, 10, 0x000000);
			filler.alpha = 0.5;
			return filler;
		}
		
		public function activate(resultPages:Number):void
		{
			//trace('pager ACTIVATE called..');
			
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
		}
		
		private function createResultPageButtons(totalResultPages:Number, currentPage:Number = 1):void
		{
			// first remove old buttons
			if(_buttons && _buttons.length > 0) {
				trace('removing previous pager buttons...' + _buttons.length);
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
			//trace('rangeStart: ' + rangeStart, 'rangeEnd:', rangeEnd);
			
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
			if(this.visible && _buttonContainer.height > 0) {
				this.height = _buttonContainer.height + HorizontalLayout(this.layout).paddingTop + HorizontalLayout(this.layout).paddingBottom;
			} else {
				this.height = 0;
			}
			
			var fillerSpace:Number = 0;
			
			// calc filler Space around buttonContainer ONLY when there is positive extra space
			if(_buttonContainer.width < this.width) {
				fillerSpace = this.width - _buttonContainer.width;
			}
			
			// update left and right filler background
			_leftFiller.width = _rightFiller.width = fillerSpace / 2;
			_leftFiller.height = _rightFiller.height = _buttonContainer.height;
			
			super.draw();
		}
	}
}