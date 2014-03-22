package nl.powergeek.feathers.components
{
	import feathers.controls.Button;
	import feathers.controls.LayoutGroup;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalLayout;
	
	import nl.powergeek.feathers.themes.PinboredDesktopTheme;
	
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.display.Sprite;
	
	public class Pager extends LayoutGroup
	{
		private var
			_buttonContainer:LayoutGroup,
			_buttons:Array = null,
			_leftFillerBackgroundFactory:Function = defaultFillerBackground,
			_rightFillerBackgroundFactory:Function = defaultFillerBackground,
			_leftFiller:DisplayObject,
			_rightFiller:DisplayObject,
			_resultPages:Number = -1;
			
		
		public function Pager()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			// component layout
			var layout:HorizontalLayout = new HorizontalLayout()
			layout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_TOP;
			layout.horizontalAlign= HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
			layout.paddingBottom = 1;
//			layout.paddingTop = 1;
			this.layout = layout;
			
			// create fillers
			_leftFiller = _leftFillerBackgroundFactory();
			_rightFiller = _rightFillerBackgroundFactory();
			
			// add left filler
			addChild(_leftFiller);
			
			// add buttoncontainer
			_buttonContainer = new LayoutGroup();
			var buttonContainerLayout:HorizontalLayout = new HorizontalLayout();
			buttonContainerLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_TOP;
			buttonContainerLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
			buttonContainerLayout.gap = 0;
			this._buttonContainer.layout = buttonContainerLayout;
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
			// first remove any remaining buttons
			if(_buttons && _buttons.length > 0) {
				trace('removing previous pager buttons...' + _buttons.length);
				while(_buttons.length > 0) {
					_buttonContainer.removeChild(Button(_buttons.pop()), true);
				}
			}
			
			if(resultPages > 1) {
				// update internal resultPages
				_resultPages = resultPages;
				
				trace('recreating pager buttons... ' + resultPages);
				_buttons = new Array();
				
				// create first button
				var first:Button = new Button();
				first.label = '<< FIRST';
				first.nameList.add(PinboredDesktopTheme.BUTTON_PAGER_SMALL_DEFAULT);
				// TODO add listener to each button and let it dispatch events with the NUMBER
				// as extra data?
				_buttons.push(first);
				_buttonContainer.addChild(first);
				
				// create previous button
				var previous:Button = new Button();
				previous.label = '< PREV';
				previous.nameList.add(PinboredDesktopTheme.BUTTON_PAGER_SMALL_DEFAULT);
				// TODO add listener to each button and let it dispatch events with the NUMBER
				// as extra data?
				_buttons.push(previous);
				_buttonContainer.addChild(previous);
				
				// create n number of buttons for n result pages
				for (var i:uint = 1; i < resultPages + 1; i++) {
					var button:Button = new Button();
					button.label = i.toString();
					button.nameList.add(PinboredDesktopTheme.BUTTON_PAGER_SMALL_DEFAULT);
					_buttons.push(button);
					_buttonContainer.addChild(button);
				}
				
				// create next button
				var next:Button = new Button();
				next.label = 'NEXT >';
				next.nameList.add(PinboredDesktopTheme.BUTTON_PAGER_SMALL_DEFAULT);
				// TODO add listener to each button and let it dispatch events with the NUMBER
				// as extra data?
				_buttons.push(next);
				_buttonContainer.addChild(next);
				
				// create last button
				var last:Button = new Button();
				last.label = 'LAST >>';
				last.nameList.add(PinboredDesktopTheme.BUTTON_PAGER_SMALL_DEFAULT);
				_buttons.push(last);
				_buttonContainer.addChild(last);
			}
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