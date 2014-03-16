package
{
	import feathers.controls.Button;
	import feathers.controls.LayoutGroup;
	import feathers.data.ListCollection;
	import feathers.layout.HorizontalLayout;
	
	import org.osflash.signals.Signal;
	
	import services.UrlCheckerFactory;
	
	import starling.events.Event;

	public class BookMark
	{
		public var
			bookmarkData: Object,
			href:String,
			description:String,
			extended:String,
			tags:Vector.<String>,
			accessory: LayoutGroup,
			staleConfirmed:Signal = new Signal(),
			notStaleConfirmed:Signal = new Signal();

			private var urlChecker:UrlChecker;
			
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
				} else {
					bookmark.notStaleConfirmed.dispatch();
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