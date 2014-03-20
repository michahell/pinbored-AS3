package nl.powergeek.pinbored.model
{
	import feathers.controls.Button;
	import feathers.controls.LayoutGroup;
	import feathers.data.ListCollection;
	import feathers.layout.HorizontalLayout;
	
	import nl.powergeek.feathers.themes.PinboredDesktopTheme;
	import nl.powergeek.pinbored.components.InteractiveIcon;
	import nl.powergeek.pinbored.services.UrlChecker;
	import nl.powergeek.pinbored.services.UrlCheckerFactory;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Image;
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
			description:String,
			extended:String,
			tags:Vector.<String>,
			accessory: LayoutGroup;
			
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
			this.description = bookmarkData.description;
			this.extended = bookmarkData.extended;
			this.tags = Vector.<String>(String(bookmarkData.tags).split(" "));
			
			this._icons.layout = new HorizontalLayout();
			
			accessory = new LayoutGroup();
			var layout:HorizontalLayout = new HorizontalLayout();
			layout.gap = 5;
			layout.padding = 5;
			accessory.layout = layout;
			
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
		}
		
		private function editTriggeredHandler(event:Event):void
		{
			const button:Button = Button(event.currentTarget);
			button.isEnabled = false;
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
			button.isEnabled = false;
			deleteTapped.dispatch(this);
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