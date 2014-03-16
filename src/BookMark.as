package
{
	import feathers.controls.Button;
	import feathers.controls.LayoutGroup;
	import feathers.data.ListCollection;
	import feathers.layout.HorizontalLayout;
	
	import nl.powergeek.feathers.components.Icon;
	
	import org.osflash.signals.Signal;
	
	import services.UrlCheckerFactory;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.Texture;

	public class BookMark
	{
		
		// checkmark
		[Embed(source="assets/images/pinbored/icon_checkmark_active.png")]
		public static const CheckmarkActive:Class;
		
		[Embed(source="assets/images/pinbored/icon_checkmark_white.png")]
		public static const CheckmarkWhite:Class;
		
		// cross
		[Embed(source="assets/images/pinbored/icon_cross_active.png")]
		public static const CrossActive:Class;
		
		[Embed(source="assets/images/pinbored/icon_cross_white.png")]
		public static const CrossWhite:Class;
		
		// heart
		[Embed(source="assets/images/pinbored/icon_heart_active.png")]
		public static const HeartActive:Class;
		
		[Embed(source="assets/images/pinbored/icon_heart_white.png")]
		public static const HeartWhite:Class;
		
		// tags
		[Embed(source="assets/images/pinbored/icon_tags_active.png")]
		public static const TagActive:Class;
		
		[Embed(source="assets/images/pinbored/icon_tags_white.png")]
		public static const TagWhite:Class;
		
		
		private var
			iconCheckmark:Icon,
			iconTags:Icon,
			iconHeart:Icon,
			iconCross:Icon,
			urlChecker:UrlChecker;
			
		public var
			bookmarkData: Object,
			href:String,
			description:String,
			extended:String,
			tags:Vector.<String>,
			accessory: LayoutGroup,
			icons: LayoutGroup,
			staleConfirmed:Signal = new Signal(),
			notStaleConfirmed:Signal = new Signal();
			
			
		public function BookMark(bookmarkData:Object)
		{
			this.bookmarkData = bookmarkData;
			this.href = bookmarkData.href;
			this.description = bookmarkData.description;
			this.extended = bookmarkData.extended;
			this.tags = Vector.<String>(String(bookmarkData.tags).split(" "));
			
			accessory = new LayoutGroup();
			var layout:HorizontalLayout = new HorizontalLayout();
			layout.gap = 5;
			layout.padding = 5;
			accessory.layout = layout;
			
			// create icons from textures
			
			var checkmarkParams:Object = {
				normal:new Image(Texture.fromBitmap(new CheckmarkWhite())),
				active:new Image(Texture.fromBitmap(new CheckmarkActive()))
			};
			iconCheckmark = new Icon(checkmarkParams, true, 0.27);
			
			var tagsParams:Object = {
				normal:new Image(Texture.fromBitmap(new TagWhite())),
				active:new Image(Texture.fromBitmap(new TagActive()))
			};
			iconTags = new Icon(tagsParams, true, 0.27);
			
			var heartParams:Object = {
				normal:new Image(Texture.fromBitmap(new HeartWhite())),
				active:new Image(Texture.fromBitmap(new HeartActive()))
			};
			iconHeart = new Icon(heartParams, true, 0.27);
			
			var crossParams:Object = {
				normal:new Image(Texture.fromBitmap(new CrossWhite())),
				active:new Image(Texture.fromBitmap(new CrossActive()))
			};
			iconCross = new Icon(crossParams, true, 0.27);
			
			icons = new LayoutGroup();
			var iconlayout:HorizontalLayout = new HorizontalLayout();
			iconlayout.gap = 5;
			iconlayout.padding = 5;
			icons.layout = iconlayout;
			
			icons.addChild(iconCheckmark);
			icons.addChild(iconTags);
			icons.addChild(iconHeart);
			icons.addChild(iconCross);
				
			var editButton:Button = new Button();
			editButton.nameList.add(Button.ALTERNATE_NAME_CALL_TO_ACTION_BUTTON);
			editButton.label = "edit";
			editButton.addEventListener( Event.TRIGGERED, editTriggeredHandler );
			accessory.addChild(editButton);
			
			var staleButton:Button = new Button();
			staleButton.nameList.add(Button.ALTERNATE_NAME_CALL_TO_ACTION_BUTTON);
			staleButton.label = "stale check";
			staleButton.addEventListener( Event.TRIGGERED, staleTriggeredHandler );
			accessory.addChild(staleButton);
			
			var dangerButton:Button = new Button();
			dangerButton.nameList.add(Button.ALTERNATE_NAME_DANGER_BUTTON);
			dangerButton.label = "delete";
			dangerButton.addEventListener( Event.TRIGGERED, removeTriggeredHandler );
			accessory.addChild(dangerButton);
			
		}
		
		private function editTriggeredHandler(event:Event):void
		{
			const button:Button = Button(event.currentTarget);
			trace(button.label + " triggered.");
		}
		
		private function staleTriggeredHandler(event:Event):void
		{
			const button:Button = Button(event.currentTarget);
			trace(button.label + " triggered.");
			
			urlChecker = UrlCheckerFactory.get();
			var bookmark:BookMark = this;
			
			urlChecker.check(this.href, function(stale:Boolean):void{
				trace('is bookmark stale: ' + stale);
				if(stale) {
					bookmark.staleConfirmed.dispatch();
					iconCross.setActive();
				} else {
					bookmark.notStaleConfirmed.dispatch();
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
		}
		
		public function removeUrlChecker():void
		{
			this.urlChecker = null;
		}
	}
}