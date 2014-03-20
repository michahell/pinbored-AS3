package nl.powergeek.pinbored.model
{
	import feathers.controls.Button;
	import feathers.controls.LayoutGroup;
	import feathers.data.ListCollection;
	import feathers.layout.HorizontalLayout;
	
	import nl.powergeek.pinbored.components.InteractiveIcon;
	import nl.powergeek.feathers.themes.PinboredDesktopTheme;
	
	import org.osflash.signals.Signal;
	
	import nl.powergeek.pinbored.services.UrlChecker;
	import nl.powergeek.pinbored.services.UrlCheckerFactory;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.Texture;

	public class BookMark
	{
		
		private var
			icons:LayoutGroup = new LayoutGroup(),
			iconCheckmark:InteractiveIcon,
			iconTags:InteractiveIcon,
			iconHeart:InteractiveIcon,
			iconCross:InteractiveIcon,
			urlChecker:UrlChecker;
			
		public var
			bookmarkData: Object,
			href:String,
			description:String,
			extended:String,
			tags:Vector.<String>,
			accessory: LayoutGroup,
			staleConfirmed:Signal = new Signal(),
			notStaleConfirmed:Signal = new Signal(),
			editTapped:Signal = new Signal(),
			deleteTapped:Signal = new Signal();
			
			
		public function BookMark(bookmarkData:Object)
		{
			this.bookmarkData = bookmarkData;
			this.href = bookmarkData.href;
			this.description = bookmarkData.description;
			this.extended = bookmarkData.extended;
			this.tags = Vector.<String>(String(bookmarkData.tags).split(" "));
			
			this.icons.layout = new HorizontalLayout();
			
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
			iconCheckmark = new InteractiveIcon(checkmarkParams, true, 0.27);
			
			var crossParams:Object = {
				normal:new Image(Texture.fromBitmap(new PinboredDesktopTheme.ICON_CROSS_WHITE())),
				active:new Image(Texture.fromBitmap(new PinboredDesktopTheme.ICON_CROSS_ACTIVE()))
			};
			iconCross = new InteractiveIcon(crossParams, true, 0.27);
			
			
			accessory.addChild(icons);
				
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
			editTapped.dispatch(this);
		}
		
		private function staleTriggeredHandler(event:Event):void
		{
			const button:Button = Button(event.currentTarget);
						
			urlChecker = UrlCheckerFactory.get();
			var bookmark:BookMark = this;
			
			urlChecker.check(this.href, function(stale:Boolean):void{
				
				if(stale) {
					bookmark.staleConfirmed.dispatch();
					icons.addChild(iconCross);
					iconCross.setActive();
				} else {
					bookmark.notStaleConfirmed.dispatch();
					icons.addChild(iconCheckmark);
					iconCheckmark.setActive();
				}
				
				button.isEnabled = false;
				bookmark.removeUrlChecker();
			});
		}
		
		private function deleteTriggeredHandler(event:Event):void
		{
			const button:Button = Button(event.currentTarget);
			deleteTapped.dispatch(this);
		}
		
		public function removeUrlChecker():void
		{
			this.urlChecker = null;
		}
		
		public function toString():String {
			return '' + this.href + ', ' + this.extended + ', ' + this.tags.toString();
		}
	}
}