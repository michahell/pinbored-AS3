package
{
	import feathers.controls.Button;
	import feathers.controls.LayoutGroup;
	import feathers.data.ListCollection;
	import feathers.layout.HorizontalLayout;
	
	import nl.powergeek.feathers.components.InteractiveIcon;
	import nl.powergeek.feathers.themes.PinboredMobileTheme;
	
	import org.osflash.signals.Signal;
	
	import services.UrlChecker;
	import services.UrlCheckerFactory;
	
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
			notStaleConfirmed:Signal = new Signal();
			
			
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
				normal:new Image(Texture.fromBitmap(new PinboredMobileTheme.ICON_CHECKMARK_WHITE())),
				active:new Image(Texture.fromBitmap(new PinboredMobileTheme.ICON_CHECKMARK_ACTIVE()))
			};
			iconCheckmark = new InteractiveIcon(checkmarkParams, true, 0.27);
			
			var tagsParams:Object = {
				normal:new Image(Texture.fromBitmap(new PinboredMobileTheme.ICON_TAG_WHITE())),
				active:new Image(Texture.fromBitmap(new PinboredMobileTheme.ICON_TAG_ACTIVE()))
			};
			iconTags = new InteractiveIcon(tagsParams, true, 0.27);
			
			var heartParams:Object = {
				normal:new Image(Texture.fromBitmap(new PinboredMobileTheme.ICON_HEART_WHITE())),
				active:new Image(Texture.fromBitmap(new PinboredMobileTheme.ICON_HEART_ACTIVE()))
			};
			iconHeart = new InteractiveIcon(heartParams, true, 0.27);
			
			var crossParams:Object = {
				normal:new Image(Texture.fromBitmap(new PinboredMobileTheme.ICON_CROSS_WHITE())),
				active:new Image(Texture.fromBitmap(new PinboredMobileTheme.ICON_CROSS_ACTIVE()))
			};
			iconCross = new InteractiveIcon(crossParams, true, 0.27);
			
			//		icons.addChild(iconTags);
			//		icons.addChild(iconHeart);
			
			accessory.addChild(icons);
				
			var editButton:Button = new Button();
			editButton.nameList.add(PinboredMobileTheme.BUTTON_QUAD_CONTEXT_SUCCESS);
			editButton.label = "edit";
			editButton.addEventListener( Event.TRIGGERED, editTriggeredHandler );
			accessory.addChild(editButton);
			
			var staleButton:Button = new Button();
			staleButton.nameList.add(PinboredMobileTheme.BUTTON_QUAD_CONTEXT_ALTERNATIVE);
			staleButton.label = "stale check";
			staleButton.addEventListener( Event.TRIGGERED, staleTriggeredHandler );
			accessory.addChild(staleButton);
			
			var deleteButton:Button = new Button();
			deleteButton.nameList.add(PinboredMobileTheme.BUTTON_QUAD_CONTEXT_DELETE);
			deleteButton.label = "delete";
			deleteButton.addEventListener( Event.TRIGGERED, removeTriggeredHandler );
			accessory.addChild(deleteButton);
		}
		
		private function editTriggeredHandler(event:Event):void
		{
			const button:Button = Button(event.currentTarget);
			trace(button.label + " triggered.");
			
			icons.addChild(iconTags);
			iconTags.setActive();
		}
		
		private function staleTriggeredHandler(event:Event):void
		{
			const button:Button = Button(event.currentTarget);
			trace(button.label + " triggered.");
			
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
		
		private function removeTriggeredHandler(event:Event):void
		{
			const button:Button = Button(event.currentTarget);
			trace(button.label + " triggered.");
			
			icons.addChild(iconHeart);
			iconHeart.setActive();
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