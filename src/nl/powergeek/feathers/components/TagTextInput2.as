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
	
	public class TagTextInput2 extends FeathersControl
	{
		// static consts
		public static const
			SEPARATOR_HEIGHT:uint = 1,
			SEPARATOR_COLOR:uint = 0x000000,
			SEPARATOR_ALPHA:Number = 0,
			TAG_HEIGHT:uint = 28,
			SEARCHBUTTON_HEIGHT:uint = TAG_HEIGHT + 6;
		
		// Factories
		private var
			_backgroundFactory:Function = defaultBackgroundFactory,
			_tagFactory:Function = defaultTagFactory,
			_separatorFactoryTop:Function = defaultSeparatorFactoryTop,
			_separatorFactoryBottom:Function = defaultSeparatorFactoryBottom;
			
		// UI
		private var
			_tagContainer:LayoutGroup = new LayoutGroup(),
			_componentLayoutGroup:LayoutGroup = new LayoutGroup(),
			_textInput:TextInput = new TextInput(),
			_background:DisplayObject,
			_separatorTop:DisplayObject,
			_separatorBottom:DisplayObject,
			_revertButton:Button;
		
		// internal state
		private var
			_tagCount:Number = 0,
			_tagsArray:Array = [],
			_screenDPIscale:Number,
			_padding:Number = 10,
			_tagNames:Vector.<String> = new Vector.<String>,
			_disAllowedStartChars:Array = [' ', ',', ', '];
		
		public const
			tagsChanged:Signal = new Signal(Vector.<String>),
			searchTagsTriggered:Signal = new Signal(Vector.<String>);
			
		// settings / options through params object in constructor
		private var 
			useBackground:Boolean = true,
			useSeparators:Boolean = true,
			useKeys:Boolean = true,
			maxTags:uint = 3,
			textInputPrompt:String = 'add tags for filtering',
			tagPadding:Number = 20;

			
		public function TagTextInput2(screenDPIscale:Number, tagTextOptions:Object)
		{
			super();
			this._screenDPIscale = screenDPIscale;
			
			if(tagTextOptions != null) {
				
				if(tagTextOptions.background == false) {
					this.useBackground = false;
				}
				
				if(tagTextOptions.separators == false) {
					this.useSeparators = false;
				}
				
				if(tagTextOptions.padding) {
					this._padding = tagTextOptions.padding;
				}
				
				if(tagTextOptions.tagPadding) {
					this.tagPadding = tagTextOptions.tagPadding;
				}
				
				if(tagTextOptions.maxTags != 3)
					this.maxTags = tagTextOptions.maxTags;
				
				if(tagTextOptions.prompt && tagTextOptions.prompt.length > 0)
					this.textInputPrompt = tagTextOptions.prompt;
				
				if(tagTextOptions.keys == false)
					this.useKeys = false;
			}
		}
		
		override protected function initialize():void 
		{
			super.initialize();
			
			// first create background
			if(this.useBackground == true) {
				this._background = _backgroundFactory();
				this.addChild(this._background);
			}
			
			// create separators
			if(this.useSeparators == true) {
				_separatorTop = _separatorFactoryTop();
				_separatorBottom = _separatorFactoryBottom();
				this.addChild(_separatorTop);
				this.addChild(_separatorBottom);
			}
			
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
			
			// add tag layout group
			this._componentLayoutGroup.addChild(_tagContainer);
//			this._tagContainer.validate();
			
			// create and add textinput
//			trace('tagEditor _textInput is editable? ' + _textInput.isEditable);
//			trace('tagEditor _textInput is enabled? ' + _textInput.isEnabled);
			this._textInput.prompt = this.textInputPrompt;
//			this._textInput.nameList.add(PinboredDesktopTheme.TEXTINPUT_TRANSPARENT_BACKGROUND);
			this._textInput.padding = this._padding / 2;
			var layoutData:AnchorLayoutData = new AnchorLayoutData();
			layoutData.leftAnchorDisplayObject = _tagContainer;
			layoutData.left = 5;
			layoutData.verticalCenter = 0;
			this._textInput.layoutData = layoutData;
			
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
			
			// add keyboard listeners
			if(this.useKeys == true) {
				this._tagContainer.addEventListener(KeyboardEvent.KEY_DOWN, keyInputHandler);
			}
			
			this._componentLayoutGroup.addChild(this._textInput);
			
			// create searchbutton
			_revertButton = new Button();
			_revertButton.label = 'revert';
			_revertButton.height = SEARCHBUTTON_HEIGHT;
			_revertButton.nameList.add(PinboredDesktopTheme.BUTTON_QUAD_CONTEXT_PRIMARY);
			_revertButton.addEventListener(Event.TRIGGERED, searchButtonTriggeredHandler); 
				
			var buttonLayoutData:AnchorLayoutData = new AnchorLayoutData();
			buttonLayoutData.verticalCenter = 0;
			buttonLayoutData.right = this._padding;
			_revertButton.layoutData = buttonLayoutData;
			this._componentLayoutGroup.addChild(this._revertButton);
			
			// and invalidate, need to redraw this thing
			invalidate(FeathersControl.INVALIDATION_FLAG_ALL);
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
				if(this._tagCount < maxTags || maxTags == 0) {
					
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
		
		public function addTag(tagText:String, notify:Boolean = true):void
		{
			// create the tag and add it to the list o tags
			var tag:Tag = _tagFactory(tagText);
			tag.padding = tagPadding;
			
			// add listener to tag removed signal
			tag.removed.addOnce(function():void {
				removeTag(tag);
			});
			
			// quickly remove the textInput, then add the tag, then re-add the textInput!
			_tagContainer.addChild(tag);
			
			// add tag text to tagText array for quick access
			_tagNames.push(tag.text);
			_tagsArray.push(tag);
			
			// fire tagsChanged signal
			if(notify == true)
				tagsChanged.dispatch(_tagNames);
			
			// increment tagCount
			_tagCount++;
			
			// and invalidate, need to redraw this thing
			invalidate(FeathersControl.INVALIDATION_FLAG_ALL);
		}
		
		public function removeTag(tag:Tag, notify:Boolean = true):void
		{
			// remove from display list
			_tagContainer.removeChild(tag);
			
			// remove from tags array
			_tagsArray.splice(_tagsArray.indexOf(tag), 1);
			
			// remove from tagNames
			_tagNames.splice(_tagNames.indexOf(tag.text), 1);
			
			// decrement tagCount
			_tagCount--;
			
			// fire tagsChanged signal
			if(notify == true)
				tagsChanged.dispatch(_tagNames);
			
			// update component
			invalidate(FeathersControl.INVALIDATION_FLAG_ALL);
		}
		
		public function removeAllTags():void
		{
			if(_tagsArray && _tagsArray.length > 0) {
				_tagsArray.forEach(function(tag:Tag, index:uint, array:Array):void{
					removeTag(tag, false);
				});
			}
		}
		
		override protected function draw():void
		{
//			trace('tag text input 2 draw called');
			
			// phase 1 commit
			_tagContainer.validate();
			this._textInput.validate();
			
			// phase 2 measurements
			_componentLayoutGroup.width = this.width;
			_componentLayoutGroup.height = Math.max(this._tagContainer.height, TAG_HEIGHT + this._padding + this.tagPadding / 2);
			
			if(this.useBackground == true) {
				_background.width = _componentLayoutGroup.width;
				_background.height = _componentLayoutGroup.height;
			}
			
			// resize textinput to remaining width between tags and search button
			var tfWidth:Number = _componentLayoutGroup.width - _tagContainer.width - _revertButton.width - this._padding * 3;
			if(this._textInput.width != tfWidth) {
				this._textInput.width = tfWidth; 
				this._textInput.invalidate(INVALIDATION_FLAG_SIZE);
				invalidate(INVALIDATION_FLAG_ALL);
			}
			
			// separators need to be on top and bottom
			if(this.useSeparators == true) {
				_separatorTop.y = this.y;
				_separatorTop.width = _background.width;
			}
			
			// content in between
			if(this.useSeparators == true) {
				_componentLayoutGroup.y = _separatorTop.y + _separatorTop.height;
			} else {
				_componentLayoutGroup.y = 0;
			}
			
			if(this.useBackground == true) {
				_background.y = _componentLayoutGroup.y;
			}
			
			// and bottom separator at the bottom
			if(this.useSeparators == true) {
				_separatorBottom.y = _componentLayoutGroup.y + _componentLayoutGroup.height;
				_separatorBottom.width = _background.width;
			}
			
			if(this.useSeparators == true) {
				this.height = this._separatorTop.height + this._componentLayoutGroup.height + this._separatorBottom.height;
			} else {
				this.height = this._componentLayoutGroup.height;
			}
			
			// phase 3 layout
//			_searchButton.validate();
		}
		
		private function defaultTagFactory(text:String):Tag
		{
			return new Tag(text, _screenDPIscale);
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