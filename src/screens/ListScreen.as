package screens
{
	import REST.RESTClient;
	import REST.RESTRequest;
	
	import feathers.controls.Button;
	import feathers.controls.Callout;
	import feathers.controls.Header;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.Panel;
	import feathers.controls.Screen;
	import feathers.controls.ScrollContainer;
	import feathers.controls.TextInput;
	import feathers.controls.renderers.BaseDefaultItemRenderer;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	import org.osflash.signals.Signal;
	
	import services.PinboardService;
	
	import starling.display.DisplayObject;
	import starling.events.ResizeEvent;
	
	public class ListScreen extends Screen
	{
		// GUI related
		private var 
			panel:Panel = new Panel(),
			searchBookmarks:TextInput,
			list:List = new List();
		
		// REST related
		private var
			restClient:RESTClient;
			
		protected var 
			button:Button,
			_onLoginScreenRequest:Signal = new Signal( LoginScreen );
		
		public function ListScreen()
		{
			super();
			
			// create REST client
			restClient = new RESTClient(
				'https://api.pinboard.in/v1/', 
				'?auth_token=', 
				'michahell:bc82053a1f923175fab7',
				'&format=',
				'json'
			);
		}
		
		override protected function initialize():void
		{
			// create GUI
			createGUI();
			
			// mockup list for custom item renderer testing
//			list.dataProvider = new ListCollection(
//			[
//				{ label: "One", href:"http://blabla/nl/sec" },
//				{ label: "Two", href:"http://blabla/nl/sec" },
//				{ label: "Three", href:"http://blabla/nl/sec" },
//				{ label: "Four", href:"http://blabla/nl/sec" },
//				{ label: "Five", href:"http://blabla/nl/sec" },
//				{ label: "One", href:"http://blabla/nl/sec" },
//				{ label: "Two", href:"http://blabla/nl/sec" },
//				{ label: "Three", href:"http://blabla/nl/sec" },
//				{ label: "Four", href:"http://blabla/nl/sec" },
//				{ label: "Five", href:"http://blabla/nl/sec" }
//			]);
			
//			list.itemRendererProperties.labelField = "text";
			
			
			// throw all bookmarks into a list
			PinboardService.allBookmarksReceived.addOnce(function(event:Event):void {
				// get request data
				var jsonResponse:String = event.target.data as String;
				var parsedResponse:Object = JSON.parse(jsonResponse);
				
				var bookmarkList:ListCollection = new ListCollection();
				
				// add all bookmarks to 'the list'
				parsedResponse.forEach(function(bookmark:Object, index:int, array:Array):void {
					var bm:BookMark = new BookMark(bookmark);
					
					// if bookmark is stale...
					bm.staleConfirmed.addOnce(function():void {
						if(bookmarkList.contains(bm)) {
							bookmarkList.getItemAt(bookmarkList.getItemIndex(bm));
						}
					});
					
					// if bookmark is stale...
					bm.notStaleConfirmed.addOnce(function():void {
						
					});
					
					bookmarkList.addItem(bm);
				});
				
				list.dataProvider = bookmarkList;
//				list.itemRendererProperties.labelField = "href";
				
			});
			
			var tags:Array = ['Webdevelopment'];
			
			// get some bookmarks
			PinboardService.GetAllBookmarks(tags);
			
		}
		
		private function createGUI():void
		{
			this.addChild(panel);
			this.panel.headerFactory = customHeaderFactory;
			
			this.panel.footerFactory = function():ScrollContainer
			{
				var container:ScrollContainer = new ScrollContainer();
				container.nameList.add( ScrollContainer.ALTERNATE_NAME_TOOLBAR );
				container.horizontalScrollPolicy = ScrollContainer.SCROLL_POLICY_OFF;
				container.verticalScrollPolicy = ScrollContainer.SCROLL_POLICY_OFF;
				return container;
			}
				
			list.itemRendererFactory = function():IListItemRenderer
			{
				var renderer:PinboardLayoutGroupItemRenderer = new PinboardLayoutGroupItemRenderer();
				renderer.padding = 5;
				return renderer;
			};
			
			list.itemRendererProperties.horizontalAlign = Button.HORIZONTAL_ALIGN_LEFT;
			list.itemRendererProperties.verticalAlign = Button.VERTICAL_ALIGN_MIDDLE;
			list.itemRendererProperties.iconPosition = Button.ICON_POSITION_LEFT;
			list.itemRendererProperties.gap = 10;
//			
//			list.itemRendererProperties.accessoryField = "accessory";
//			list.itemRendererProperties.accessoryGap = Number.POSITIVE_INFINITY;
//			list.itemRendererProperties.accessoryPosition = BaseDefaultItemRenderer.ACCESSORY_POSITION_RIGHT;
//			list.isSelectable = false;
			
			// add list to panel
			this.panel.addChild( list );
		}
		
		private function customHeaderFactory():Header
		{
			const header:Header = new Header();
			header.title = "Bookmarks list";
			header.titleAlign = Header.TITLE_ALIGN_PREFER_LEFT;
			
			if(!this.searchBookmarks)
			{
				this.searchBookmarks = new TextInput();
				this.searchBookmarks.width = 400;
				this.searchBookmarks.prompt = "search keyword";
				
				//we can't get an enter key event without changing the returnKeyLabel
				//not using ReturnKeyLabel.GO here so that it will build for web
				this.searchBookmarks.textEditorProperties.returnKeyLabel = "go";
				
				this.searchBookmarks.addEventListener(FeathersEventType.ENTER, input_enterHandler);
			}
			
			header.rightItems = new <DisplayObject>[this.searchBookmarks];
			
			return header;
		}
		
		private function input_enterHandler():void
		{
			trace('entered search key word');
		}
		
		override protected function draw():void
		{
			//runs every time invalidate() is called
			//a good place for measurement and layout
			
			panel.width = AppModel.starling.stage.stageWidth;
			panel.height = AppModel.starling.stage.stageHeight;
			list.width = panel.width;
		}
	}
}