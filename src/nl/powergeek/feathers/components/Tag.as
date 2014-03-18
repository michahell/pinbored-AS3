package nl.powergeek.feathers.components
{
	import feathers.controls.Label;
	import feathers.core.FeathersControl;
	import feathers.display.Scale3Image;
	import feathers.layout.AnchorLayoutData;
	import feathers.textures.Scale3Textures;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Image;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	public class Tag extends FeathersControl
	{
		// tag scale 9 image
		[Embed(source="assets/images/pinbored/scale3tag.png")]
		private static const SCALE_3_TEXTURE:Class;
		
		// cross
		[Embed(source="assets/images/pinbored/icon_cross_active.png")]
		public static const CrossActive:Class;
		
		[Embed(source="assets/images/pinbored/icon_cross_white.png")]
		public static const CrossWhite:Class;
		
		[Embed(source="assets/images/pinbored/icon_cross_black.png")]
		public static const CrossBlack:Class;
		
		private var
			background:Scale3Image,
			_label:Label = new Label(),
			_closeIcon:Icon,
			_image:Scale3Image,
			_color:uint,
			_screenDPIscale:Number,
			_shape:String,
			_padding:Number = 20,
			_text:String;
			
		public const
			removed:Signal = new Signal();
			
			
		public function Tag(screenDPIscale:Number, text:String)
		{
//			trace('tag created: ' + text);
			this._screenDPIscale = screenDPIscale;
			this._text = text;
		}
		
		override protected function initialize():void {
			
			// add tag background (scale 3 image, pill shaped)
			const texture:Texture = Texture.fromBitmap(new SCALE_3_TEXTURE(), false);
			const textures:Scale3Textures = new Scale3Textures(texture, 60, 80, Scale3Textures.DIRECTION_HORIZONTAL);
			this._image = new Scale3Image(textures, this._screenDPIscale);
			this._image.height = 33;
			this.addChild(this._image);
			
			// add the label
			this.addChild(this._label);
			this._label.nameList.add(Label.ALTERNATE_NAME_HEADING);
			
			// add the delete icon
			var closeIconParams:Object = {
				normal: new Image(Texture.fromBitmap(new CrossWhite())),
				active: new Image(Texture.fromBitmap(new CrossActive())),
				hover: new Image(Texture.fromBitmap(new CrossBlack()))
			};
			_closeIcon = new Icon(closeIconParams, true, this._screenDPIscale, 0.3);
			_closeIcon.addEventListener(TouchEvent.TOUCH, onTouch);
			this.addChild(this._closeIcon);
		}
		
		private function onTouch(event:TouchEvent):void
		{
			if (event.getTouch(this, TouchPhase.ENDED))
			{
				this.removed.dispatch();
			}
		}
		
		override protected function draw():void {
			
			// phase 1. commit
			// we have no other data passed down to children except the label text, but this is all handled in the label component!
			_label.text = this._text;
			_label.validate();
			
			// phase 2. measurement
			// update the scale3 image to the label length. written 'verbosely' for clearness!
			this._image.width = (this._screenDPIscale * this.padding * 2) + this._label.width + (this._screenDPIscale * this.padding * 4);
			
			// update our width
			this.actualWidth = this._image.width;
			this.width = this.actualWidth;
			
			// update our height
			this.actualHeight = this._image.height;
			this.height = this.actualHeight;
			
			// phase 3. layout
			this._label.x = this._image.x + (this._screenDPIscale * this.padding  * 2);
			this._label.y = this._image.y + (this._image.height / 2) - (this._label.height / 2) - 1;
			
			this._closeIcon.x = this._image.x + this._image.width - this._closeIcon.width - this.padding;
			this._closeIcon.y = this._image.y + (this._image.height / 2) - (this._closeIcon.height / 2);
			
		}
		
		public function get text():String {
			return this._text;
		}
		
		public function set text(value:String):void {
			this._text = value;
			this.invalidate(FeathersControl.INVALIDATION_FLAG_ALL);
		}

		public function get color():uint
		{
			return _color;
		}

		public function set color(value:uint):void
		{
			_color = value;
			this.invalidate(FeathersControl.INVALIDATION_FLAG_ALL);
		}

		public function get shape():String
		{
			return _shape;
		}

		public function set shape(value:String):void
		{
			_shape = value;
			this.invalidate(FeathersControl.INVALIDATION_FLAG_ALL);
		}

		public function get padding():Number
		{
			return _padding;
		}

		public function set padding(value:Number):void
		{
			_padding = value;
		}
	}
}