package nl.powergeek.feathers.components
{
	import feathers.controls.Button;
	
	import flash.errors.InvalidSWFError;
	
	import starling.display.Shape;
	import starling.display.Sprite;
	
	public class RoundedStrokeButtonSkin extends Shape
	{
		// GETTERS and SETTERS
		private var
			_cornerRadius:Number = 0,
			_strokeWidth:Number = 0,
			_strokeColor:uint = 0xFFFFFF,
			_strokeAlpha:Number = 1,
			_bgColor:uint = 0x000000,
			_bgAlpha:Number = 0;
		
		public function RoundedStrokeButtonSkin(width:int, height:int, cornerRadius:int, strokeWidth:int, strokeColor:Number = 0xFFFFFF, strokeAlpha:Number = 1, bgColor:Number = 0x000000, bgAlpha:Number = 0)
		{
			super();
			
			// avoid setters for avoid of redraw, directly set private vars
			this._cornerRadius = cornerRadius;
			this._strokeWidth = _strokeWidth;
			this._strokeColor = strokeColor;
			this._strokeAlpha = strokeAlpha;
			this._bgColor = bgColor;
			this._bgAlpha = bgAlpha;
			
			// these setters invoke redraw...
			this.width = width;
			this.height = height;
		}
		
		public function redraw():void
		{
			trace('redraw called!');
			this.graphics.clear();
			
			this.graphics.lineStyle(_strokeWidth, _strokeColor, _strokeAlpha);
			this.graphics.beginFill(_bgColor, _bgAlpha);
			this.graphics.drawRoundRect(0, 0, width, height, _cornerRadius);
			this.graphics.endFill();
		}
		
		// GETTER AND SETTERS
		
		override public function set width(value:Number):void
		{
			trace('width set called! ' + value);
			super.width = value;
			redraw();
		}
		
		override public function set height(value:Number):void
		{
			trace('height set called! ' + value);
			super.height = value;
			redraw();
		}

		public function get cornerRadius():Number
		{
			return _cornerRadius;
		}

		public function set cornerRadius(value:Number):void
		{
			_cornerRadius = value;
			redraw();
		}

		public function get strokeWidth():Number
		{
			return _strokeWidth;
		}

		public function set strokeWidth(value:Number):void
		{
			_strokeWidth = value;
			redraw();
		}

		public function get strokeColor():uint
		{
			return _strokeColor;
		}

		public function set strokeColor(value:uint):void
		{
			_strokeColor = value;
			redraw();
		}

		public function get bgColor():uint
		{
			return _bgColor;
		}
	
		public function set bgColor(value:uint):void
		{
			_bgColor = value;
			redraw();
		}
	
		public function get strokeAlpha():Number
		{
			return _strokeAlpha;
		}
	
		public function set strokeAlpha(value:Number):void
		{
			_strokeAlpha = value;
			redraw();
		}
	
		public function get bgAlpha():Number
		{
			return _bgAlpha;
		}
	
		public function set bgAlpha(value:Number):void
		{
			_bgAlpha = value;
			redraw();
		}
	}
}