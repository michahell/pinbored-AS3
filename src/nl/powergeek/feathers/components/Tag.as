package nl.powergeek.feathers.components
{
	import feathers.controls.Label;
	import feathers.core.FeathersControl;
	import feathers.display.Scale3Image;
	import feathers.layout.AnchorLayoutData;
	import feathers.textures.Scale3Textures;
	
	import starling.textures.Texture;
	
	public class Tag extends FeathersControl
	{
		// tag scale 9 image
		[Embed(source="assets/images/pinbored/scale3tag.png")]
		private static const SCALE_3_TEXTURE:Class;
		
		private var
			background:Scale3Image,
			_label:Label = new Label(),
			_image:Scale3Image,
			_color:uint,
			_screenDPIscale:Number,
			_shape:String,
			_padding:Number = 20,
			_text:String;
			
		public function Tag(screenDPIscale:Number, text:String)
		{
			trace('tag created: ' + text);
			
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
		}
		
		override protected function draw():void {
			
			trace('tag draw called!');
			
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
			// update label position (who knows?)
			this._label.x = this._image.x + (this._screenDPIscale * this.padding  * 2);
			this._label.y = this._image.y + (this._image.height / 2) - (this._label.height / 2) - 1;
		}
		
		public function getText():String {
			return _label.text;
		}
		
		public function setText(value:String):void {
			_label.text = value;
			this.invalidate(FeathersControl.INVALIDATION_FLAG_ALL);
		}

		public function getColor():uint
		{
			return _color;
		}

		public function setColor(value:uint):void
		{
			_color = value;
			this.invalidate(FeathersControl.INVALIDATION_FLAG_ALL);
		}

		public function getShape():String
		{
			return _shape;
		}

		public function setShape(value:String):void
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