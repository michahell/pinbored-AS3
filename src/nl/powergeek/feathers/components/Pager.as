package nl.powergeek.feathers.components
{
	import feathers.controls.Button;
	import feathers.controls.LayoutGroup;
	import feathers.controls.ScrollContainer;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalLayout;
	
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
			_rightFiller:DisplayObject,
			_resultPages:Number = -1;
	
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
		
		public function update(pageNumber:Number):void
		{
			if (pageNumber > 0) {
				// enable all buttons
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
		
		private function createGUI():void
		{
			// component layout
			var layout:HorizontalLayout = new HorizontalLayout()
			layout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_TOP;
			layout.horizontalAlign= HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
			layout.paddingBottom = 1;
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
			// first store resultPages
			this.numResultPages = resultPages;
			
			// first remove any remaining buttons
			if(_buttons && _buttons.length > 0) {
				trace('removing previous pager buttons...' + _buttons.length);
				while(_buttons.length > 0) {
					var removedButton:Button = Button(_buttons.pop());
					removedButton.removeEventListeners();
					_buttonContainer.removeChild(removedButton, true);
				}
			}
			
			if(resultPages > 1) {
				// update internal resultPages
				_resultPages = resultPages;
				
				trace('recreating pager buttons... ' + resultPages);
				_buttons = new Array();
				
				// create first button
				first = new Button();
				first.label = '<< FIRST';
				first.nameList.add(PinboredDesktopTheme.BUTTON_PAGER_SMALL_DEFAULT);
				
				// add first listener ..haha <boring meta joke>
				first.addEventListener(Event.TRIGGERED, onFirstHandler);
				
				_buttons.push(first);
				_buttonContainer.addChild(first);
				
				// create previous button
				previous = new Button();
				previous.label = '< PREV';
				previous.nameList.add(PinboredDesktopTheme.BUTTON_PAGER_SMALL_DEFAULT);
				
				// add previous listener ..haha <boring meta joke>
				previous.addEventListener(Event.TRIGGERED, onPrevHandler);
				
				_buttons.push(previous);
				_buttonContainer.addChild(previous);
				
				// create n number of buttons for n result pages
				for (var i:uint = 1; i < resultPages + 1; i++) {
					var button:Button = new Button();
					button.label = i.toString();
					button.nameList.add(PinboredDesktopTheme.BUTTON_NUMBERED_PAGER_SMALL_DEFAULT);
					
					// add button listener
					button.addEventListener(Event.TRIGGERED, onNumberButtonHandler);
					
					_buttons.push(button);
					_buttonContainer.addChild(button);
				}
				
				// create next button
				next = new Button();
				next.label = 'NEXT >';
				next.nameList.add(PinboredDesktopTheme.BUTTON_PAGER_SMALL_DEFAULT);
				
				// add button listener
				next.addEventListener(Event.TRIGGERED, onNextHandler);
				
				_buttons.push(next);
				_buttonContainer.addChild(next);
				
				// create last button
				last = new Button();
				last.label = 'LAST >>';
				last.nameList.add(PinboredDesktopTheme.BUTTON_PAGER_SMALL_DEFAULT);
				
				// add button listener
				last.addEventListener(Event.TRIGGERED, onLastHandler);
				
				_buttons.push(last);
				_buttonContainer.addChild(last);
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