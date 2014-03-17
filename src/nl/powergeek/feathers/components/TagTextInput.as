package nl.powergeek.feathers.components
{
	import feathers.controls.LayoutGroup;
	import feathers.controls.TextInput;
	import feathers.core.FeathersControl;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalLayout;
	
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Event;
	
	public class TagTextInput extends FeathersControl
	{
		public static const
			MAX_TAGS:Number = 3;
		
		private var
			_tagCount:Number = 0,
			_tags:LayoutGroup = new LayoutGroup(),
			_textInput:TextInput = new TextInput(),
			_backgroundFactory:Function = defaultBackgroundFactory,
			_tagFactory:Function = defaultTagFactory,
			_background:DisplayObject,
			_screenDPIscale:Number,
			_padding:Number = 10;

		public function TagTextInput(screenDPIscale:Number)
		{
			super();
			this._screenDPIscale = screenDPIscale;
		}
		
		override protected function initialize():void 
		{
			super.initialize();
			
			// first create background
			this._background = _backgroundFactory();
			this.addChild(this._background);
			
			// create tags layoutgroup
			var tagLayout:HorizontalLayout = new HorizontalLayout();
			tagLayout.padding = 10;
			tagLayout.gap = 10;
			tagLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_LEFT;
			tagLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
			
			// assign layout type and add the tags layoutGroup
			_tags.layout = tagLayout;
			this.addChild(_tags);
			
			// create and add textinput
			this._textInput.prompt = "add tags for filtering";
			this._textInput.width = 200;
			
			this._textInput.addEventListener(Event.CHANGE, textInputHandler);
			this._tags.addChild(this._textInput);
			this._tags.validate();
		}
		
		private function textInputHandler(event:Event):void
		{
			// get TextInput
			var textInput:TextInput = TextInput(event.target);
			var text:String = textInput.text;
			
			// if text contains space or comma
			var spaceIndex:Number = text.indexOf(' ');
			var commaIndex:Number = text.indexOf(', ');
			
			// if we do not yet have reached the max. number of tags
			if(this._tagCount < MAX_TAGS) {
				if(spaceIndex > -1 || commaIndex > -1) {
					
					// remove the word from this text input
					var tagText:String = '';
					
					if(spaceIndex > -1) {
						tagText = text.substr(0, spaceIndex);
					} else if(commaIndex > -1) {
						tagText = text.substr(0, commaIndex);
					}
					
					// create the tag and add it to the list o tags
					var tag:Tag = _tagFactory(tagText);
					
					// quickly remove the textInput, then add the tag, then re-add the textInput!
					this._tags.removeChild(this._textInput);
					this._tags.addChild(tag);
					this._tags.addChild(this._textInput);
					
					// set focus back to textinput after removing and adding it to display list
					this._textInput.setFocus();
					
					// clear the text
					textInput.text = '';
					
					// increment tagCount
					this._tagCount++;
					
					// and invalidate, need to redraw this thing
					this.invalidate(FeathersControl.INVALIDATION_FLAG_ALL);
				}
			}
		}
		
		override protected function draw():void
		{
			trace('tag text input component draw called!');
			
			// phase 1 commit
			_tags.validate();
			
			// phase 2 measurements
			this.actualWidth = this._tags.width;
			this.actualHeight = this._tags.height;
			
			this.width = Math.max(this.actualWidth, this.width);
			this.height = Math.max(this.actualHeight, this.height);
			
			_background.width = this.width;
			_background.height = this.height;
			
			// phase 3 layout
		}
		
		private function defaultTagFactory(text:String):Tag
		{
			return new Tag(_screenDPIscale, text);
		}
		
		public function get tagFactory():Function
		{
			return _tagFactory;
		}

		public function set tagFactory(value:Function):void
		{
			_tagFactory = value;
		}
		
		private function defaultBackgroundFactory():DisplayObject
		{
			return new Quad(100, 100, 0x000000);
		}
		
		public function get backgroundFactory():Function
		{
			return _backgroundFactory;
		}

		public function set backgroundFactory(value:Function):void
		{
			_backgroundFactory = value;
		}

	}
}