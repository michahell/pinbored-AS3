package nl.powergeek.pinbored.model
{
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.ScrollContainer;
	import feathers.controls.TextInput;
	import feathers.core.FeathersControl;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalLayout;
	
	import flash.errors.InvalidSWFError;
	import flash.utils.setTimeout;
	
	import nl.powergeek.feathers.components.Tag;
	import nl.powergeek.feathers.components.TagTextInput;
	import nl.powergeek.feathers.components.TagTextInput2;
	import nl.powergeek.feathers.themes.PinboredDesktopTheme;
	import nl.powergeek.pinbored.components.InteractiveIcon;
	import nl.powergeek.pinbored.services.UrlChecker;
	import nl.powergeek.pinbored.services.UrlCheckerFactory;
	import nl.powergeek.utils.XorSignal;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.textures.Texture;

	public class BookMark
	{
		// UI related
		private var
			_icons:LayoutGroup = new LayoutGroup(),
			_iconCheckmark:InteractiveIcon,
			_iconTags:InteractiveIcon,
			_iconHeart:InteractiveIcon,
			_iconCross:InteractiveIcon,
			_urlChecker:UrlChecker,
			_revertButton:Button,
			_modifyButton:Button,
			_tagEditor:TagTextInput2,
			_extendedInput:TextInput,
			_hrefInput:TextInput,
			_descriptionInput:TextInput;
			
		// data related
		public var
			// raw data object
			bookmarkData: Object,
			bookmarkData_new:Object,
			// data
			href:String,
			description:String,
			extended:String,
			tags:Vector.<String>,
			shared:String,
			toread:String,
			// new data (when modifying)
			href_new:String,
			description_new:String,
			extended_new:String,
			tags_new:Vector.<String>,
			shared_new:String,
			toread_new:String,
			// generated from data
			link:String,
			// these 2 layoutgroups have to be public for the item renderer.
			accessory: LayoutGroup,
			hiddenContent: LayoutGroup;
			
		public const
			staleConfirmed:Signal = new Signal(),
			notStaleConfirmed:Signal = new Signal(),
			editTapped:Signal = new Signal(),
			deleteTapped:Signal = new Signal(),
			deleteConfirmed:Signal = new Signal(),
			editConfirmed:Signal = new Signal();
			
		// editing specific signals
		public const
			dataChanged:XorSignal = new XorSignal(),
			descriptionChanged:Signal = new Signal(String),
			hrefChanged:Signal = new Signal(String),
			linkChanged:Signal = new Signal(String),
			extendedChanged:Signal = new Signal(String),
			tagsChanged:Signal = new Signal(Vector.<String>);
		
		// state related
		private var 
			isChanged:Boolean = false,
			isHrefChanged:Boolean = false,
			isLinkChanged:Boolean = false,
			isTagsChanged:Boolean = false,
			isDescriptionChanged:Boolean = false,
			isExtendedChanged:Boolean = false;
			
			
		public function BookMark(bookmarkData:Object)
		{
			this.bookmarkData = bookmarkData;
			this.href = bookmarkData.href;
			this.description = bookmarkData.description;
			this.extended = bookmarkData.extended;
			this.tags = Vector.<String>(String(bookmarkData.tags).split(" "));
			this.shared = bookmarkData.shared;
			this.toread = bookmarkData.toread;
			
			// automagically populate the link field
			setLink(this.href);
			
			this._icons.layout = new HorizontalLayout();
			
			accessory = new LayoutGroup();
			var accessoryLayout:HorizontalLayout = new HorizontalLayout();
			accessoryLayout.gap = 5;
			accessoryLayout.padding = 5;
			accessory.layout = accessoryLayout;
			
			// create icons from textures
			var checkmarkParams:Object = {
				normal:new Image(Texture.fromBitmap(new PinboredDesktopTheme.ICON_CHECKMARK_WHITE())),
				active:new Image(Texture.fromBitmap(new PinboredDesktopTheme.ICON_CHECKMARK_ACTIVE()))
			};
			_iconCheckmark = new InteractiveIcon(checkmarkParams, true, 0.27);
			
			var crossParams:Object = {
				normal:new Image(Texture.fromBitmap(new PinboredDesktopTheme.ICON_CROSS_WHITE())),
				active:new Image(Texture.fromBitmap(new PinboredDesktopTheme.ICON_CROSS_ACTIVE()))
			};
			_iconCross = new InteractiveIcon(crossParams, true, 0.27);
			
			
			accessory.addChild(_icons);
				
			var editButton:Button = new Button();
			editButton.nameList.add(PinboredDesktopTheme.BUTTON_QUAD_CONTEXT_ALTERNATIVE);
			editButton.label = "edit";
			editButton.addEventListener( Event.TRIGGERED, editTriggeredHandler );
			accessory.addChild(editButton);
			
			var staleButton:Button = new Button();
			staleButton.nameList.add(PinboredDesktopTheme.BUTTON_QUAD_CONTEXT_ALTERNATIVE);
			staleButton.label = "stale check";
			staleButton.addEventListener( Event.TRIGGERED, staleTriggeredHandler );
			accessory.addChild(staleButton);
			
			var deleteButton:Button = new Button();
			deleteButton.nameList.add(PinboredDesktopTheme.BUTTON_QUAD_CONTEXT_DELETE);
			deleteButton.label = "delete";
			deleteButton.addEventListener( Event.TRIGGERED, deleteTriggeredHandler );
			accessory.addChild(deleteButton);
			
			// create hidden content
			hiddenContent = new LayoutGroup();
			hiddenContent.touchable = true;
			
			// hidden content layout group
			var hiddenContentLayout:AnchorLayout = new AnchorLayout();
			hiddenContent.layout = hiddenContentLayout;
			
			// add description editor
			_descriptionInput = new TextInput();
			_descriptionInput.textEditorProperties.multiline = true;
			_descriptionInput.padding = 5;
			
			if(this.description.length > 0) {
				_descriptionInput.text = description;
				_descriptionInput.prompt = description;
			} else {
				_descriptionInput.prompt = '[ enter description ]';
			}
			
			_descriptionInput.nameList.add(PinboredDesktopTheme.TEXTINPUT_TRANSLUCENT_BOX);
			_descriptionInput.addEventListener(Event.CHANGE, descriptionInputHandler);
			_descriptionInput.addEventListener(FeathersEventType.FOCUS_IN, descriptionFocusInHandler);
			var descriptionInputLd:AnchorLayoutData = new AnchorLayoutData(0, 10, NaN, 0);
			_descriptionInput.layoutData = descriptionInputLd;
			hiddenContent.addChild(_descriptionInput);
			
			// add link editor
			_hrefInput = new TextInput();
			_hrefInput.textEditorProperties.multiline = true;
			_hrefInput.padding = 5;
			
			if(this.href.length > 0) {
				_hrefInput.text = href;
				_hrefInput.prompt = href;
			} else {
				_hrefInput.prompt = '[ enter link ]';
			}
			
//			_hrefInput.nameList.add(PinboredDesktopTheme.TEXTINPUT_TRANSLUCENT_BOX);
			_hrefInput.addEventListener(Event.CHANGE, hrefInputHandler);
			var hild:AnchorLayoutData = new AnchorLayoutData();
			hild.topAnchorDisplayObject = _descriptionInput;
			hild.top = 5;
			hild.left = 0;
			hild.right = 10;
			_hrefInput.layoutData = hild;
			hiddenContent.addChild(_hrefInput);
			
			// add the extended / description label
			_extendedInput = new TextInput();
			_extendedInput.textEditorProperties.multiline = true;
			_extendedInput.padding = 5;
			
			if(this.extended.length > 0) {
				_extendedInput.text = this.extended;
				_extendedInput.prompt = this.extended;
			} else {
				_extendedInput.prompt = '[ enter extended description ]';
			}
			
//			_extendedInput.nameList.add(PinboredDesktopTheme.TEXTINPUT_TRANSLUCENT_BOX);
			_extendedInput.addEventListener(Event.CHANGE, extendedInputHandler);
			var extendedInputLd:AnchorLayoutData = new AnchorLayoutData();
			extendedInputLd.topAnchorDisplayObject = _hrefInput;
			extendedInputLd.top = 5;
			extendedInputLd.left = 0;
			extendedInputLd.right = 10;
			_extendedInput.layoutData = extendedInputLd;
			
			
			hiddenContent.addChild(_extendedInput);
			
			// tag editor options
			var tagTextOptions:Object = {
				separators : false,
				background : true,
				padding : 0,
				tagPadding : 20,
				keys : false,
				prompt : 'add tag',
				maxTags : 0
			};
			
			// add the tag editor
			_tagEditor = new TagTextInput2(AppSettings.SCREEN_DPI_SCALE, tagTextOptions);
			_tagEditor.tagsChanged.add(tagEditorHandler);
			var teld:AnchorLayoutData = new AnchorLayoutData();
			teld.topAnchorDisplayObject = _extendedInput;
			teld.left = 0;
			teld.right = 10;
			teld.top = 5;
			_tagEditor.layoutData = teld;
			// add tags to tag component
			this.tags.forEach(function(tag:String, index:uint, vector:Vector.<String>):void {
				_tagEditor.addTag(tag, false);
			});
			hiddenContent.addChild(_tagEditor);
			
			// add the 'accept changes' button
			_modifyButton = new Button();
			_modifyButton.label = 'save changes';
			_modifyButton.isEnabled = false;
			_modifyButton.nameList.add(PinboredDesktopTheme.BUTTON_QUAD_CONTEXT_PRIMARY);
			_modifyButton.addEventListener(Event.TRIGGERED, modifyButtonTriggeredHandler);
			var modifyButtonLd:AnchorLayoutData = new AnchorLayoutData();
			modifyButtonLd.topAnchorDisplayObject = _tagEditor;
			modifyButtonLd.top = 10;
			modifyButtonLd.right = 10;
			modifyButtonLd.bottom = 10;
			_modifyButton.layoutData = modifyButtonLd;
			hiddenContent.addChild(_modifyButton);
			
			// add the 'revert changes' button
			_revertButton = new Button();
			_revertButton.label = 'revert changes';
			_revertButton.isEnabled = false;
			_revertButton.nameList.add(PinboredDesktopTheme.BUTTON_QUAD_CONTEXT_DELETE);
			_revertButton.addEventListener(Event.TRIGGERED, revertButtonTriggeredHandler);
			var rbld:AnchorLayoutData = new AnchorLayoutData();
			rbld.topAnchorDisplayObject = _tagEditor;
			rbld.top = 10;
			rbld.rightAnchorDisplayObject = _modifyButton;
			rbld.right = 5;
			rbld.bottom = 10;
			_revertButton.layoutData = rbld;
			hiddenContent.addChild(_revertButton);
			
			// add signals to Xor Signal
			dataChanged.addSignal(descriptionChanged);
			dataChanged.addSignal(hrefChanged);
			dataChanged.addSignal(linkChanged);
			dataChanged.addSignal(extendedChanged);
			dataChanged.addSignal(tagsChanged);
			
			// add data changed general handler
			dataChanged.add(dataChangedHandler);
		}
		
		private function descriptionFocusInHandler(event:Event):void
		{
			trace('description focused!');
			_descriptionInput.isEditable = true;
			_descriptionInput.isEnabled = true;
			_descriptionInput.invalidate(FeathersControl.INVALIDATION_FLAG_ALL);
			_descriptionInput.validate();
		}		
		
		public function removeUrlChecker():void
		{
			this._urlChecker = null;
		}
		
		public function toString():String {
			return '' + this.href + ', ' + this.extended + ', ' + this.tags.toString();
		}
		
		private function setLink(href:String):void
		{
			link = '<a href=\"' + href + '\">' + href + '</a>';
		}
		
		private function dataChangedHandler():void 
		{
			trace('data changed called.');
			//trace('changed: ', isLinkChanged, isHrefChanged, isDescriptionChanged, isExtendedChanged, isTagsChanged);
			
			if(isLinkChanged == true || isHrefChanged == true || isDescriptionChanged == true || isExtendedChanged == true || isTagsChanged == true) {
				isChanged = true;
				_revertButton.isEnabled = true;
				_modifyButton.isEnabled = true;
			} else {
				isChanged = false;
				_revertButton.isEnabled = false;
				_modifyButton.isEnabled = false;
			}
		}
		
		private function tagEditorHandler(changedTags:Vector.<String>):void
		{
			// store new value
			tags_new = changedTags;
			
			if(tags.toString() != changedTags.toString())
				isTagsChanged = true;
			else
				isTagsChanged = false;
			
			tagsChanged.dispatch(tags);
		}
		
		private function descriptionInputHandler(event:Event):void
		{
			var text:String = TextInput(event.target).text;
			
			// store new value
			description_new = text;
			
			if(description != text)
				isDescriptionChanged = true;
			else
				isDescriptionChanged = false;
			
			descriptionChanged.dispatch(text);
		}
		
		private function hrefInputHandler(event:Event):void
		{
			var text:String = TextInput(event.target).text;
			
			// store new value
			href_new = text;
			
			if(href != text)
				isHrefChanged = true;
			else
				isHrefChanged = false;
				
			hrefChanged.dispatch(text);
		}
		
		private function extendedInputHandler(event:Event):void
		{
			var text:String = TextInput(event.target).text;
			
			// store new value
			extended_new = text;
			
			if(extended != text)
				isExtendedChanged = true;
			else 
				isExtendedChanged = false;
			
			extendedChanged.dispatch(text);
		}
		
		private function editTriggeredHandler(event:Event):void
		{
			const button:Button = Button(event.currentTarget);
			editTapped.dispatch(this);
		}
		
		private function staleTriggeredHandler(event:Event):void
		{
			const button:Button = Button(event.currentTarget);
						
			_urlChecker = UrlCheckerFactory.get();
			var bookmark:BookMark = this;
			
			_urlChecker.check(this.href, function(stale:Boolean):void{
				
				if(stale) {
					bookmark.staleConfirmed.dispatch();
					
					// remove icon if exists
					if(_icons.contains(_iconCross))
						_icons.removeChild(_icons);
					
					// add icon
					_icons.addChild(_iconCross);
					_iconCross.setActive();
					
				} else {
					bookmark.notStaleConfirmed.dispatch();
					
					// remove icon if exists
					if(_icons.contains(_iconCheckmark))
						_icons.removeChild(_iconCheckmark);
					
					// add icon
					_icons.addChild(_iconCheckmark);
					_iconCheckmark.setActive();
				}
				
				button.isEnabled = false;
				bookmark.removeUrlChecker();
			});
		}
		
		private function deleteTriggeredHandler(event:Event):void
		{
			const button:Button = Button(event.currentTarget);
			if(button.label == 'delete') {
				button.label = 'confirm';
				setTimeout(function():void {
					button.label = 'delete';
				}, 2000);
			} else {
				button.isEnabled = false;
				deleteTapped.dispatch(this);
			}
		}
		
		private function revertButtonTriggeredHandler(event:Event):void
		{
			_hrefInput.text = href;
			_extendedInput.text = extended;
			_descriptionInput.text = description;
			
			_tagEditor.removeAllTags();
			
			this.tags.forEach(function(tag:String, index:uint, vector:Vector.<String>):void {
				_tagEditor.addTag(tag);
			});
		}
		
		private function modifyButtonTriggeredHandler(event:Event):void
		{
			isChanged = false;
			
			// check for modifications
			href_new = (href_new == null) ? href : href_new;
			description_new = (description_new == null) ? description : description_new;
			extended_new = (extended_new == null) ? extended : extended_new;
			tags_new = (tags_new == null) ? tags : tags_new;
			
			// temp workaround because shared and toread are not yet modifiable
			shared_new = (shared_new == null) ? shared : shared_new;
			toread_new = (toread_new == null) ? toread : toread_new;
			
			// notify that edit request should be performed
			editConfirmed.dispatch(this);
			
			// collapse item renderer
			editTapped.dispatch(this);
		}
	}
}