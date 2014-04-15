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
	
	public class FilterBar extends FeathersControl
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
			_searchButton:Button,
			_filterToggleButton:Button;
		
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
			filterToggleTriggered:Signal = new Signal(),
			searchTagsTriggered:Signal = new Signal(Vector.<String>);
			
		// setttings / options through params object in constructor
		private var 
			useBackground:Boolean = true,
			useSeparators:Boolean = true,
			useKeys:Boolean = true,
			maxTags:uint = 3,
			textInputPrompt:String = 'add tags for filtering';

			
		public function FilterBar(screenDPIscale:Number, tagTextOptions:Object)
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
			
			// create and add textinput
			this._textInput.prompt = this.textInputPrompt;
			this._textInput.nameList.add(PinboredDesktopTheme.TEXTINPUT_TRANSPARENT_BACKGROUND);
			this._textInput.padding = (this._padding / 2) - (this._padding / 5);
			
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
			
			this._tagContainer.addChild(this._textInput);
			
			// add tag layout group
			this._componentLayoutGroup.addChild(_tagContainer);
			this._tagContainer.validate();
			
			// test create filter button
			_filterToggleButton = new Button();
			_filterToggleButton.isToggle = true;
			_filterToggleButton.label = 'More';
			_filterToggleButton.height = SEARCHBUTTON_HEIGHT;
			_filterToggleButton.nameList.add(PinboredDesktopTheme.BUTTON_QUAD_HOTKEYABLE);
			_filterToggleButton.addEventListener( Event.CHANGE, toggleButtonTriggeredHandler );
			
			var filterButtonLayoutData:AnchorLayoutData = new AnchorLayoutData();
			filterButtonLayoutData.verticalCenter = 0;
			filterButtonLayoutData.right = this._padding;
			_filterToggleButton.layoutData = filterButtonLayoutData;
			this._componentLayoutGroup.addChild(_filterToggleButton);
			
			// create searchbutton
			_searchButton = new Button();
			_searchButton.label = 'Filter';
			_searchButton.height = SEARCHBUTTON_HEIGHT;
			_searchButton.nameList.add(PinboredDesktopTheme.BUTTON_QUAD_HOTKEYABLE);
			_searchButton.addEventListener(Event.TRIGGERED, searchButtonTriggeredHandler); 
				
			var buttonLayoutData:AnchorLayoutData = new AnchorLayoutData();
			buttonLayoutData.verticalCenter = 0;
			buttonLayoutData.right = this._padding;
			buttonLayoutData.rightAnchorDisplayObject = this._filterToggleButton;
			_searchButton.layoutData = buttonLayoutData;
			this._componentLayoutGroup.addChild(this._searchButton);
		}
		
		private function toggleButtonTriggeredHandler():void
		{
			toggleMoreSection();
		}
		
		private function toggleMoreSection():void
		{
			trace('toggling more section...');
			
			//TODO FEAT: collapse or expand more section!
			
			filterToggleTriggered.dispatch();
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
			
			// filter button hotkey
			if(event.keyCode == Keyboard.F) {
				searchTagsTriggered.dispatch(this._tagNames);
			}
			
			// more button hotkey
			if(event.keyCode == Keyboard.M) {
				// trigger CHANGE event on filterToggleButton
				if(!_filterToggleButton.isSelected)
					_filterToggleButton.isSelected = true;
				else
					_filterToggleButton.isSelected = false;
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
				if(this._tagCount < maxTags) {
					
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
						//invalidate(FeathersControl.INVALIDATION_FLAG_ALL);
					}
				}
			}
		}
		
		public function addTag(tagText:String):void
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
			invalidate(FeathersControl.INVALIDATION_FLAG_ALL);
			
			// add tag text to tagText array for quick access
			_tagNames.push(tag.text);
			_tagsArray.push(tag);
			
			// fire tagsChanged signal
			tagsChanged.dispatch(_tagNames);
			
			// increment tagCount
			_tagCount++;
		}
		
		public function removeTag(tag:Tag):void {
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
			CONFIG::TESTING {
				trace('tag text input draw called');
			}
			
			// phase 1 commit
			_tagContainer.validate();
			
			// enable or disable tag input
			if(this.maxTags > 0) {
				if(this._tagCount < maxTags) {
					this._textInput.isEnabled = true;
				} else {
					// disable tag input
					this._textInput.text = '';
					this._textInput.isEnabled = false;
				}
			} else {
				this._textInput.isEnabled = true;
			}
			this._textInput.validate();
			
			// phase 2 measurements
			_componentLayoutGroup.width = this.width;
			_componentLayoutGroup.height = this._tagContainer.height;
			
			if(this.useBackground == true) {
				_background.width = _componentLayoutGroup.width;
				_background.height = _componentLayoutGroup.height;
			}
			
			// resize textinput to remaining width between tags and search button
			this._textInput.width = _componentLayoutGroup.width - (_tagContainer.width - _textInput.width) - _searchButton.width;
			
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
			
//			this.width = Math.max(this.actualWidth, this.width);
			
			if(this.useSeparators == true) {
				this.height = this._separatorTop.height + this._componentLayoutGroup.height + this._separatorBottom.height;
			} else {
				this.height = this._componentLayoutGroup.height;
			}
			
			// phase 3 layout
			_searchButton.validate();
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