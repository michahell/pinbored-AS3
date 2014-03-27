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
	import nl.powergeek.feathers.themes.PinboredDesktopTheme;
	import nl.powergeek.pinbored.components.InteractiveIcon;
	import nl.powergeek.pinbored.services.UrlChecker;
	import nl.powergeek.pinbored.services.UrlCheckerFactory;
	
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
			_urlChecker:UrlChecker;
			
		public var
			bookmarkData: Object,
			href:String,
			link:String,
			description:String,
			extended:String,
			tags:Vector.<String>,
			accessory: LayoutGroup,
			hiddenContent: LayoutGroup;
			
		public const
			staleConfirmed:Signal = new Signal(),
			notStaleConfirmed:Signal = new Signal(),
			editTapped:Signal = new Signal(),
			deleteTapped:Signal = new Signal(),
			deleteConfirmed:Signal = new Signal(),
			editConfirmed:Signal = new Signal();
			
			
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
			hiddenContent.scaleY = 0;
			hiddenContent.height = 0;
			hiddenContent.visible = false;
			
			// hidden content layout group
			var hiddenContentLayout:AnchorLayout = new AnchorLayout();
			hiddenContent.layout = hiddenContentLayout;
			
			var tagTextOptions:Object = {
				separators : false,
				background : true,
				padding : 0,
				keys : false,
				prompt : 'add tag',
				maxTags : Number.POSITIVE_INFINITY
			};
			
			// add the tag editor
			var tagEditor:TagTextInput = new TagTextInput(AppSettings.SCREEN_DPI_SCALE, tagTextOptions);
			tagEditor.layoutData = new AnchorLayoutData(0, -5, NaN, -5);
			hiddenContent.addChild(tagEditor);
			
			// add the extended / description label
			var extendedInput:TextInput = new TextInput();
			extendedInput.height = 25;
			extendedInput.nameList.add(PinboredDesktopTheme.TEXTINPUT_TRANSLUCENT_BOX);
			var extendedInputLd:AnchorLayoutData = new AnchorLayoutData();
			extendedInputLd.topAnchorDisplayObject = tagEditor;
			extendedInputLd.top = 5;
			extendedInputLd.left = -5;
			extendedInputLd.right = -5;
			extendedInput.layoutData = extendedInputLd;
			
			if(this.extended.length > 0) {
				extendedInput.text = this.extended;
				trace('Using extended description');
				trace('this.extended: ' + this.extended);
			} else {
				extendedInput.text = '[no extended description]';
			}
			
			hiddenContent.addChild(extendedInput);
			
			
			// add the 'accept changes' button
//			var modifyButton:Button = new Button();
//			modifyButton.label = 'save changes';
//			modifyButton.nameList.add(PinboredDesktopTheme.BUTTON_QUAD_CONTEXT_SUCCESS);
//			var modifyButtonLd:AnchorLayoutData = new AnchorLayoutData();
//			modifyButtonLd.topAnchorDisplayObject = tagEditor;
//			modifyButtonLd.right = 5;
//			modifyButton.layoutData = modifyButtonLd;
//			hiddenContent.addChild(modifyButton);
			
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