package nl.powergeek.pinbored.model
{
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.ScrollContainer;
	import feathers.controls.TextInput;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalLayout;
	
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
		
		private var
			_icons:LayoutGroup = new LayoutGroup(),
			_iconCheckmark:InteractiveIcon,
			_iconTags:InteractiveIcon,
			_iconHeart:InteractiveIcon,
			_iconCross:InteractiveIcon,
			_urlChecker:UrlChecker,
			_revertButton:Button,
			_modifyButton:Button;
			
		public var
			bookmarkData: Object,
			href:String,
			link:String,
			description:String,
			extended:String,
			tags:Vector.<String>,
			accessory: LayoutGroup,
			hiddenContent: LayoutGroup,
			isChanged:Boolean = false;
			
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
			
		private var 
			isLinkChanged:Boolean = false,
			isDescriptionChanged:Boolean = false,
			isExtendedChanged:Boolean = false;
			
			
		public function BookMark(bookmarkData:Object)
		{
			this.bookmarkData = bookmarkData;
			this.href = bookmarkData.href;
			this.link = bookmarkData.link;
			this.description = bookmarkData.description;
			this.extended = bookmarkData.extended;
			this.tags = Vector.<String>(String(bookmarkData.tags).split(" "));
			
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
			var descriptionInput:TextInput = new TextInput();
			descriptionInput.textEditorProperties.multiline = true;
			descriptionInput.padding = 5;
			
			if(this.description.length > 0) {
				descriptionInput.text = description;
				descriptionInput.prompt = description;
			} else {
//				descriptionInput.text = '[no description]';
				descriptionInput.prompt = '[ enter description ]';
			}
			
//			descriptionInput.nameList.add(PinboredDesktopTheme.TEXTINPUT_TRANSPARENT_BACKGROUND);
			descriptionInput.addEventListener(Event.CHANGE, descriptionInputHandler);
			var descriptionInputLd:AnchorLayoutData = new AnchorLayoutData(0, 10, NaN, 0);
			descriptionInput.layoutData = descriptionInputLd;
			hiddenContent.addChild(descriptionInput);
			
			// add link editor
			var linkInput:TextInput = new TextInput();
			linkInput.textEditorProperties.multiline = true;
			linkInput.padding = 5;
			
			if(this.href.length > 0) {
				linkInput.text = href;
				linkInput.prompt = href;
			} else {
//				linkInput.text = '[no link]';
				linkInput.prompt = '[ enter link ]';
			}
			
//			linkInput.nameList.add(PinboredDesktopTheme.TEXTINPUT_TRANSPARENT_BACKGROUND);
			linkInput.addEventListener(Event.CHANGE, linkInputHandler);
			var lild:AnchorLayoutData = new AnchorLayoutData();
			lild.topAnchorDisplayObject = descriptionInput;
			lild.top = 5;
			lild.left = 0;
			lild.right = 10;
			linkInput.layoutData = lild;
			hiddenContent.addChild(linkInput);
			
			// add the extended / description label
			var extendedInput:TextInput = new TextInput();
			extendedInput.textEditorProperties.multiline = true;
			extendedInput.padding = 5;
			
			if(this.extended.length > 0) {
				extendedInput.text = this.extended;
				extendedInput.prompt = this.extended;
			} else {
//				extendedInput.text = '[no extended description]';
				extendedInput.prompt = '[ enter extended description ]';
			}
			
//			extendedInput.nameList.add(PinboredDesktopTheme.TEXTINPUT_TRANSPARENT_BACKGROUND);
			extendedInput.addEventListener(Event.CHANGE, extendedInputHandler);
			var extendedInputLd:AnchorLayoutData = new AnchorLayoutData();
			extendedInputLd.topAnchorDisplayObject = linkInput;
			extendedInputLd.top = 5;
			extendedInputLd.left = 0;
			extendedInputLd.right = 10;
			extendedInput.layoutData = extendedInputLd;
			
			
			hiddenContent.addChild(extendedInput);
			
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
			var tagEditor:TagTextInput2 = new TagTextInput2(AppSettings.SCREEN_DPI_SCALE, tagTextOptions);
			var teld:AnchorLayoutData = new AnchorLayoutData();
			teld.topAnchorDisplayObject = extendedInput;
			teld.left = 0;
			teld.right = 10;
			teld.top = 5;
			tagEditor.layoutData = teld;
			// add tags to tag component
			this.tags.forEach(function(tag:String, index:uint, vector:Vector.<String>):void {
				tagEditor.addTag(tag);
			});
			hiddenContent.addChild(tagEditor);
			
			// add the 'accept changes' button
			_modifyButton = new Button();
			_modifyButton.label = 'save changes';
//			_modifyButton.paddingBottom = 10;
			_modifyButton.isEnabled = false;
			_modifyButton.nameList.add(PinboredDesktopTheme.BUTTON_QUAD_CONTEXT_PRIMARY);
			_modifyButton.addEventListener(Event.TRIGGERED, modifyButtonTriggeredHandler);
			var modifyButtonLd:AnchorLayoutData = new AnchorLayoutData();
			modifyButtonLd.topAnchorDisplayObject = tagEditor;
			modifyButtonLd.top = 10;
			modifyButtonLd.right = 10;
			modifyButtonLd.bottom = 5;
			_modifyButton.layoutData = modifyButtonLd;
			hiddenContent.addChild(_modifyButton);
			
			// add the 'revert changes' button
			_revertButton = new Button();
			_revertButton.label = 'revert changes';
//			_revertButton.paddingBottom = 10;
			_revertButton.isEnabled = false;
			_revertButton.nameList.add(PinboredDesktopTheme.BUTTON_QUAD_CONTEXT_DELETE);
			_revertButton.addEventListener(Event.TRIGGERED, revertButtonTriggeredHandler);
			var rbld:AnchorLayoutData = new AnchorLayoutData();
			rbld.topAnchorDisplayObject = tagEditor;
			rbld.top = 10;
			rbld.rightAnchorDisplayObject = _modifyButton;
			rbld.right = 5;
			rbld.bottom = 5;
			_revertButton.layoutData = rbld;
			hiddenContent.addChild(_revertButton);
			
			// add signals to Xor Signal
			dataChanged.addSignal(descriptionChanged);
			dataChanged.addSignal(hrefChanged);
			dataChanged.addSignal(extendedChanged);
			dataChanged.addSignal(tagsChanged);
			
			dataChanged.add(function():void {
				trace('data changed called.');
				if(isLinkChanged == true || isDescriptionChanged == true || isExtendedChanged == true) {
					trace('data changed - enabling buttons...');
					isChanged = true;
					_revertButton.isEnabled = true;
					_modifyButton.isEnabled = true;
				} else {
					trace('data changed - disabling buttons...');
					isChanged = false;
					_revertButton.isEnabled = false;
					_modifyButton.isEnabled = false;
				}
			});
		}
		
		private function revertButtonTriggeredHandler(event:Event):void
		{
			isChanged = false;
			//TODO revert
		}
		
		private function modifyButtonTriggeredHandler(event:Event):void
		{
			isChanged = false;
			//TODO save
		}
		
		private function descriptionInputHandler(event:Event):void
		{
			var text:String = TextInput(event.target).text;
			trace('description changed: ' + text);
			
			if(description != text)
				isDescriptionChanged = true;
			else
				isDescriptionChanged = false;
			
			descriptionChanged.dispatch(text);
		}
		
		private function linkInputHandler(event:Event):void
		{
			var text:String = TextInput(event.target).text;
			trace('href changed: ' + text);
			
			if(href != text)
				isLinkChanged = true;
			else
				isLinkChanged = false;
				
			linkChanged.dispatch(text);
		}
		
		private function extendedInputHandler(event:Event):void
		{
			var text:String = TextInput(event.target).text;
			trace('extended description changed: ' + text);
			
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
					_icons.addChild(_iconCross);
					_iconCross.setActive();
				} else {
					bookmark.notStaleConfirmed.dispatch();
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
				button.label = 'CONFIRM';
				setTimeout(function():void {
					button.label = 'delete';
				}, 2000);
			} else {
				button.isEnabled = false;
				deleteTapped.dispatch(this);
			}
		}
		
		public function removeUrlChecker():void
		{
			this._urlChecker = null;
		}
		
		public function toString():String {
			return '' + this.href + ', ' + this.extended + ', ' + this.tags.toString();
		}
	}
}