package nl.powergeek.feathers.components
{
	import feathers.controls.Button;
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.core.ITextRenderer;
	import feathers.text.BitmapFontTextFormat;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import nl.powergeek.feathers.themes.PinboredDesktopTheme;
	
	import starling.display.DisplayObject;
	import starling.display.Shape;
	
	public class DrawnButton extends Button
	{
		public var
			isDrawn:Boolean = false;
		
		public var
			BUTTON_COLOR:uint = 0x000000,
			BUTTON_ALPHA:Number = 0.2,
			BUTTON_CORNER_RADIUS:Number = 5,
			BUTTON_LINE_THICKNESS:Number = 2,
			BUTTON_LINE_COLOR:uint = 0xEEEEEE,
			BUTTON_LINE_ALPHA:Number = 0.95;
			
		public const
			BUTTON_TEXTFORMAT_DEFAULT:TextFormat = new TextFormat(PinboredDesktopTheme.OpenSansBoldFont.fontName, 12, 0xEEEEEE, true),
			BUTTON_TEXTFORMAT_HOVER:TextFormat = new TextFormat(PinboredDesktopTheme.OpenSansBoldFont.fontName, 12, 0xEEEEEE, true),
			BUTTON_TEXTFORMAT_DISABLED:TextFormat = new TextFormat(PinboredDesktopTheme.OpenSansBoldFont.fontName, 12, 0xEEEEEE, true);
		
		public function DrawnButton()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			this.padding = 5;
			this.paddingLeft = this.paddingRight = 10;
			
			this.defaultLabelProperties.textFormat = BUTTON_TEXTFORMAT_DEFAULT;
			this.hoverLabelProperties.textFormat = BUTTON_TEXTFORMAT_HOVER;
			this.disabledLabelProperties.textFormat = BUTTON_TEXTFORMAT_DISABLED;
			this.selectedDisabledLabelProperties.textFormat = BUTTON_TEXTFORMAT_DISABLED;
			
			redrawButton();
		}
		
		override protected function draw():void
		{
			super.draw();
			redrawButton();
		}
		
		protected function redrawButton():void
		{
			if(this.defaultSkin && this.width != this.defaultSkin.width && this.height != this.defaultSkin.height || isDrawn == false) {
				trace('DrawnButton w/h: ' + this.width, this.height);
				isDrawn = true;
				var buttonShape:Shape = new Shape();
				buttonShape.graphics.beginFill(BUTTON_COLOR, BUTTON_ALPHA);
				buttonShape.graphics.lineStyle(BUTTON_LINE_THICKNESS, BUTTON_LINE_COLOR, BUTTON_LINE_ALPHA);
				buttonShape.graphics.drawRoundRect(0, 0, this.width, this.height, BUTTON_CORNER_RADIUS);
				this.defaultSkin = buttonShape;
				this.invalidate(INVALIDATION_FLAG_STYLES);
			}
		}
		
		override public function set defaultSkin(value:DisplayObject):void
		{
			if(this._skinSelector.defaultValue == value)
			{
				return;
			}
			this._skinSelector.defaultValue = value;
			//this.invalidate(INVALIDATION_FLAG_STYLES);
		}
	}
}