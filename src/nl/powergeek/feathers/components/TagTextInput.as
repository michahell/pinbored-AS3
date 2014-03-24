package nl.powergeek.feathers.components
{
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.LayoutGroup;
	import feathers.controls.TextInput;
	import feathers.core.FeathersControl;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalLayout;
	
	import flash.ui.Keyboard;
	
	import nl.powergeek.feathers.themes.PinboredDesktopTheme;
	
	import org.osflash.signals.Signal;
	
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.textures.Texture;
	
	public class TagTextInput extends FeathersControl
	{
		public static const
			MAX_TAGS:uint = 3,
			SEPARATOR_HEIGHT:uint = 1,
			SEPARATOR_COLOR:uint = 0x000000,
			SEPARATOR_ALPHA:Number = 0,
			TAG_HEIGHT:uint = 28,
			SEARCHBUTTON_HEIGHT:uint = TAG_HEIGHT + 6;
		
		private var
			_tagCount:Number = 0,
			_tagContainer:LayoutGroup = new LayoutGroup(),
			_tagsArray:Array = [],
			_componentLayoutGroup:LayoutGroup = new LayoutGroup(),
			_textInput:TextInput = new TextInput(),
			_backgroundFactory:Function = defaultBackgroundFactory,
			_tagFactory:Function = defaultTagFactory,
			_background:DisplayObject,
			_separatorFactoryTop:Function = defaultSeparatorFactoryTop,
			_separatorFactoryBottom:Function = defaultSeparatorFactoryBottom,
			separatorTop:DisplayObject,
			separatorBottom:DisplayObject,
			_searchButton:Button,
			_screenDPIscale:Number,
			_padding:Number = 10,
			_tagNames:Vector.<String> = new Vector.<String>,
			_disAllowedStartChars:Array = [' ', ',', ', '];
			
		
		public const
			tagsChanged:Signal = new Signal(Vector.<String>),
			searchTagsTriggered:Signal = new Signal(Vector.<String>);
		

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
			
			// create separators
			separatorTop = _separatorFactoryTop();
			separatorBottom = _separatorFactoryBottom();
			this.addChild(separatorTop);
			this.addChild(separatorBottom);
			
			// add component layout
			var componentLayoutData:AnchorLayout = new AnchorLayout();
			_componentLayoutGroup.layout = componentLayoutData;
			this.addChild(this._componentLayoutGroup);
			
			// create tags layoutgroup
			var tagLayout:HorizontalLayout = new HorizontalLayout();
			tagLayout.padding = this._padding;
			tagLayout.gap = this._padding;
			tagLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_LEFT;
			tagLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_JUSTIFY;
			
			// assign layout type and add the tags layoutGroup
			_tagContainer.layout = tagLayout;
			
			// create and add textinput
			this._textInput.prompt = "add tags for filtering";
			this._textInput.nameList.add(PinboredDesktopTheme.TEXTINPUT_TRANSPARENT_BACKGROUND);
			this._textInput.padding = this._padding / 2;
			
			// add tag icon in front of tag text input
			var tagIcon:ImageLoader = new ImageLoader();
			tagIcon.source = Texture.fromBitmap(new PinboredDesktopTheme.ICON_TAG_WHITE(), true);
			tagIcon.snapToPixels = true;
			tagIcon.padding = 0;
			tagIcon.paddingTop = 4;
			tagIcon.paddingLeft = 0;
			tagIcon.paddingRight = 20;
			tagIcon.scaleX = tagIcon.scaleY = 0.16;
			this._textInput.defaultIcon = tagIcon;
			
			// add listeners
			this._textInput.addEventListener(Event.CHANGE, textInputHandler);
			this._tagContainer.addEventListener(KeyboardEvent.KEY_DOWN, keyInputHandler);
			this._tagContainer.addChild(this._textInput);
			
			// add tag layout group
			this._componentLayoutGroup.addChild(_tagContainer);
			this._tagContainer.validate();
			
			// create searchbutton
			_searchButton = new Button();
			_searchButton.label = 'search & filter';
			_searchButton.height = SEARCHBUTTON_HEIGHT;
			_searchButton.nameList.add(PinboredDesktopTheme.BUTTON_QUAD_CONTEXT_PRIMARY);
			_searchButton.addEventListener(Event.TRIGGERED, searchButtonTriggeredHandler); 
				
			var buttonLayoutData:AnchorLayoutData = new AnchorLayoutData();
			buttonLayoutData.verticalCenter = 0;
			buttonLayoutData.right = this._padding;
			_searchButton.layoutData = buttonLayoutData;
			this._componentLayoutGroup.addChild(this._searchButton);
		}
		
		private function searchButtonTriggeredHandler():void
		{
			searchTagsTriggered.dispatch(this._tagNames);
		}
		
		private function keyInputHandler(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.BACKSPACE) {
				if(_textInput.text.length == 0) {
					if(_tagNames.length > 0)
						removeTag(_tagsArray[_tagsArray.length - 1]);
				}
			}
			
			if(event.keyCode == Keyboard.ENTER) {
//				searchTagsTriggered.dispatch(this._tagNames);
			}
		}
		
		private function textInputHandler(event:Event):void
		{
			// get TextInput
			var textInput:TextInput = TextInput(event.target);
			var text:String = textInput.text;
			
			// check for disallowed start characters
			if(_disAllowedStartChars.indexOf(text) >= 0)
				textInput.text = text = '';
			
			// if we have text input at all
			if(text.length > 0) {
				
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
							tagText = text.substr(0, commaIndex + 1);	// + 1 because we need to skip the ',' character!
						}
						
						addTag(tagText);
						
						// set focus back to textinput after removing and adding it to display list
						_textInput.setFocus();
						
						// clear the text
						textInput.text = '';
						
						// and invalidate, need to redraw this thing
						invalidate(FeathersControl.INVALIDATION_FLAG_ALL);
					}
				}
			}
		}
		
		private function addTag(tagText:String):void
		{
			// create the tag and add it to the list o tags
			var tag:Tag = _tagFactory(tagText);
			
			// add listener to tag removed signal
			tag.removed.addOnce(function():void {
				removeTag(tag);
			});
			
			// quickly remove the textInput, then add the tag, then re-add the textInput!
			_tagContainer.removeChild(this._textInput);
			_tagContainer.addChild(tag);
			_tagContainer.addChild(this._textInput);
			
			// add tag text to tagText array for quick access
			_tagNames.push(tag.text);
			_tagsArray.push(tag);
			
			// fire tagsChanged signal
			tagsChanged.dispatch(_tagNames);
			
			// increment tagCount
			_tagCount++;
		}
		
		private function removeTag(tag:Tag):void {
			// remove from display list
			_tagContainer.removeChild(tag);
			// remove from tags array
			_tagsArray.splice(_tagsArray.indexOf(tag), 1);
			// remove from tagNames
			_tagNames.splice(_tagNames.indexOf(tag.text), 1);
			// decrement tagCount
			_tagCount--;
			// update component
			invalidate(FeathersControl.INVALIDATION_FLAG_ALL);
			// fire tagsChanged signal
			tagsChanged.dispatch(_tagNames);
		}
		
		override protected function draw():void
		{
			// phase 1 commit
			_tagContainer.validate();
			
			// enable or disable tag input
			if(this._tagCount < MAX_TAGS) {
				this._textInput.isEnabled = true;
			} else {
				// disable tag input
				this._textInput.text = '';
				this._textInput.isEnabled = false;
			}
			this._textInput.validate();
			
			// phase 2 measurements
			_componentLayoutGroup.width = this.width;
			_componentLayoutGroup.height = this._tagContainer.height;
			
			_background.width = _componentLayoutGroup.width;
			_background.height = _componentLayoutGroup.height;
			
			// resize textinput to remaining width between tags and search button
			this._textInput.width = _componentLayoutGroup.width - (_tagContainer.width - _textInput.width) - _searchButton.width;
			
			// separators need to be on top and bottom
			separatorTop.y = this.y;
			separatorTop.width = _background.width;
			
			// content in between
			_componentLayoutGroup.y = separatorTop.y + separatorTop.height;
			_background.y = _componentLayoutGroup.y;
			
			// and bottom separator at the bottom
			separatorBottom.y = _componentLayoutGroup.y + _componentLayoutGroup.height;
			separatorBottom.width = _background.width;
			
			this.width = Math.max(this.actualWidth, this.width);
			this.height = this.separatorTop.height + this._componentLayoutGroup.height + this.separatorBottom.height;
			
			// phase 3 layout
			_searchButton.validate();
			
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
//			return new Quad(100, 100, 0x464646);
			
			var bg:Quad = new Quad(10, 10, 0x000000);
			bg.alpha = 0.2;
			return bg;
		}
		
		public function get backgroundFactory():Function
		{
			return _backgroundFactory;
		}

		public function set backgroundFactory(value:Function):void
		{
			_backgroundFactory = value;
		}
		
		private function defaultSeparatorFactoryTop():DisplayObject
		{
			var line:Quad = new Quad(5, SEPARATOR_HEIGHT, SEPARATOR_COLOR);
			line.alpha = 0.9;
			return line;
		}

		public function get separatorFactoryTop():Function
		{
			return _separatorFactoryTop;
		}

		public function set separatorFactoryTop(value:Function):void
		{
			_separatorFactoryTop = value;
		}
		
		private function defaultSeparatorFactoryBottom():DisplayObject
		{
			var line:Quad = new Quad(5, SEPARATOR_HEIGHT, SEPARATOR_COLOR);
			line.alpha = SEPARATOR_ALPHA;
			return line;
		}

		public function get separatorFactoryBottom():Function
		{
			return _separatorFactoryBottom;
		}

		public function set separatorFactoryBottom(value:Function):void
		{
			_separatorFactoryBottom = value;
		}


	}
}