package screens
{
	import feathers.controls.Button;
	import feathers.controls.Callout;
	import feathers.controls.Header;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.Panel;
	import feathers.controls.Screen;
	import feathers.controls.ScrollContainer;
	import feathers.controls.TextInput;
	import feathers.controls.renderers.BaseDefaultItemRenderer;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.core.ITextRenderer;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.text.TextFormat;
	
	import nl.powergeek.REST.RESTClient;
	import nl.powergeek.REST.RESTRequest;
	import nl.powergeek.feathers.components.PinboardLayoutGroupItemRenderer;
	import nl.powergeek.feathers.components.PinboredHeader;
	import nl.powergeek.feathers.components.Tag;
	import nl.powergeek.feathers.components.TagTextInput;
	import nl.powergeek.feathers.themes.PinboredMobileTheme;
	import nl.powergeek.utils.ArrayCollectionPager;
	
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	import services.PinboardService;
	
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.ResizeEvent;
	import starling.textures.Texture;
	
	public class ListScreen extends Screen
	{
		// GUI related
		private var 
			panel:Panel = new Panel(),
			screenGroup:LayoutGroup,
			listScrollContainer:ScrollContainer,
			searchBookmarks:TextInput,
			searchTags:TagTextInput,
			list:List = new List(),
			button:Button,
			_backgroundImage:Image = new Image(Texture.fromBitmap(new PinboredMobileTheme.BACKGROUND2(), false)),
			_panelExcludedSpace:uint = 0;
		
		// REST related
		private var
			restClient:RESTClient,
			resultsPerPage:Number = 25;
		
		// signals
		private var 
			_onLoginScreenRequest:Signal = new Signal( ListScreen );
		
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
			
			// listen for transition complete
			owner.addEventListener(FeathersEventType.TRANSITION_COMPLETE, onTransitionComplete);
		}
		
		private function onTransitionComplete(event:starling.events.Event):void
		{
			// remove listener
			owner.removeEventListener(FeathersEventType.TRANSITION_COMPLETE, onTransitionComplete);
			
			// get all bookmarks and populate list control
			getInitialData();
		}
		
		private function getInitialData():void
		{
			// when searched for tags, update the bookmarks list
			searchTags.searchTagsTriggered.add(function(tagNames:Vector.<String>):void {
				
				AppModel.rawBookmarkDataListFiltered = PinboardService.filterTags(AppModel.rawBookmarkDataList, tagNames);
				trace('done filtering: ' + AppModel.rawBookmarkDataListFiltered.length);
				
				if(AppModel.rawBookmarkDataListFiltered.length > 0) {
					// first, page raw bookmark results (this list can be huge)
					AppModel.rawBookmarkListCollectionPager = new ArrayCollectionPager(AppModel.rawBookmarkDataListFiltered, resultsPerPage);
					var firstResultPageCollection:Array = AppModel.rawBookmarkListCollectionPager.first();
					
					AppModel.bookmarksList = PinboardService.mapRawBookmarksToBookmarks(firstResultPageCollection);
					
					list.dataProvider = null;
					list.dataProvider = new ListCollection(AppModel.bookmarksList);
				} else {
					trace('no results after filtering...');
					list.dataProvider = null;
				}
				
			});
			
			// throw all bookmarks into a list
			PinboardService.allBookmarksReceived.add(function(event:flash.events.Event):void {
				
				var parsedResponse:Object = JSON.parse(event.target.data as String);
				
				parsedResponse.forEach(function(bookmark:Object, index:int, array:Array):void {
					AppModel.rawBookmarkDataList.push(bookmark);
				});
				
				// first, page raw bookmark results (this list can be huge)
				AppModel.rawBookmarkListCollectionPager = new ArrayCollectionPager(AppModel.rawBookmarkDataList, resultsPerPage);
				var firstResultPageCollection:Array = AppModel.rawBookmarkListCollectionPager.first();
				
				AppModel.bookmarksList = PinboardService.mapRawBookmarksToBookmarks(firstResultPageCollection);
				
				//				list.dataProvider = null;
				list.dataProvider = new ListCollection(AppModel.bookmarksList);
			});
			
			// get all bookmarks
			// PinboardService.GetAllBookmarks();
			PinboardService.GetAllBookmarks(['programming']);
		}
		
		private function createGUI():void
		{
			// create nice background
			this.addChild(_backgroundImage);
			
			// add a panel with a header, footer and no scroll shit
			this.panel.verticalScrollPolicy = Panel.SCROLL_POLICY_OFF;
			this.panel.horizontalScrollPolicy = Panel.SCROLL_POLICY_OFF;
			this.panel.nameList.add(PinboredMobileTheme.PANEL_TRANSPARENT_BACKGROUND);
			
			this.panel.headerFactory = function():PinboredHeader
			{
				// const header:Header = new Header();
				const header:PinboredHeader = new PinboredHeader();
				header.title = "Bookmarks list";
				header.titleAlign = Header.TITLE_ALIGN_PREFER_LEFT;
				header.padding = 0;
				header.paddingLeft = 10;
				header.gap = 0;
				
				header.titleFactory = function():ITextRenderer
				{
					var titleRenderer:TextFieldTextRenderer = new TextFieldTextRenderer();
					titleRenderer.textFormat = PinboredMobileTheme.TEXTFORMAT_SCREEN_TITLE;
					return titleRenderer;
				}
				
				if(!this.searchBookmarks)
				{
					this.searchBookmarks = new TextInput();
					this.searchBookmarks.nameList.add(PinboredMobileTheme.TEXTINPUT_SEARCH);
					this.searchBookmarks.prompt = "search any keyword...";
					this.searchBookmarks.width = 500;
					
					//we can't get an enter key event without changing the returnKeyLabel
					//not using ReturnKeyLabel.GO here so that it will build for web
					this.searchBookmarks.textEditorProperties.returnKeyLabel = "go";
					this.searchBookmarks.addEventListener(FeathersEventType.ENTER, input_enterHandler);
				}
				
				header.rightItems = new <DisplayObject>[this.searchBookmarks];
				_panelExcludedSpace += header.height;
				
				return header;
			}
				
			// panel footer
			panel.footerFactory = function():ScrollContainer
			{
				var container:ScrollContainer = new ScrollContainer();
				container.nameList.add( ScrollContainer.ALTERNATE_NAME_TOOLBAR );
				container.horizontalScrollPolicy = ScrollContainer.SCROLL_POLICY_OFF;
				container.verticalScrollPolicy = ScrollContainer.SCROLL_POLICY_OFF;
								
				// create logo
				var alpha:Number = 0.3;
				
				// create left horizontal layoutgroup
				var leftItems:LayoutGroup = new LayoutGroup();
				var leftItemsLayout:HorizontalLayout = new HorizontalLayout();
				leftItemsLayout.paddingTop = leftItemsLayout.paddingRight = leftItemsLayout.paddingBottom = leftItemsLayout.paddingLeft = 14;
				leftItemsLayout.gap = 10;
				leftItems.layout = leftItemsLayout;
				leftItems.layoutData = new AnchorLayoutData(0, NaN, 0, 0, NaN, 0);
				
				// create logo
				var logo:Image = new Image(Texture.fromBitmap(new PinboredMobileTheme.LOGO_TRANSPARENT(), true));
				logo.scaleX = logo.scaleY = 0.75;
				logo.alpha = alpha;
				leftItems.addChild(logo);
				
				// create disclaimer text
				var disclaimer:Label = new Label();
				disclaimer.maxWidth = 400;
				disclaimer.nameList.add(PinboredMobileTheme.LABEL_DISCLAIMER);
				disclaimer.text = AppModel.DISCLAIMER_TEXT;
				leftItems.addChild(disclaimer);
				
				// create right horizontal layoutgroup
				var rightItems:LayoutGroup = new LayoutGroup();
				var rightItemsLayout:HorizontalLayout = new HorizontalLayout();
				rightItemsLayout.paddingTop = rightItemsLayout.paddingRight = rightItemsLayout.paddingBottom = rightItemsLayout.paddingLeft = 14;
				rightItemsLayout.gap = 10;
				rightItems.layout = rightItemsLayout;
				rightItems.layoutData = new AnchorLayoutData(0, 0, 0, NaN, NaN, 0);
				
				// create starling, feathers, open source icons
				var feathersLogo:Image = new Image(Texture.fromBitmap(new PinboredMobileTheme.ICON_FEATHERS(), true));
				feathersLogo.scaleX = feathersLogo.scaleY = 0.8;
				feathersLogo.alpha = alpha;
				rightItems.addChild(feathersLogo);
				
				var starlingLogo:Image = new Image(Texture.fromBitmap(new PinboredMobileTheme.ICON_STARLING(), true));
				starlingLogo.scaleX = starlingLogo.scaleY = 0.15;
				starlingLogo.alpha = alpha + 0.1;
				rightItems.addChild(starlingLogo);
				
				// create open source + link text container
				var rightTextGroup:LayoutGroup = new LayoutGroup();
				var rightTextGroupLayout:VerticalLayout = new VerticalLayout();
				rightTextGroupLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_RIGHT;
				rightTextGroupLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
				rightTextGroup.layout = rightTextGroupLayout;
				
				// create open source text
				var opensourceText:Label = new Label();
				opensourceText.isQuickHitAreaEnabled = false;
				opensourceText.nameList.add(PinboredMobileTheme.LABEL_RIGHT_ALIGNED_TEXT);
				opensourceText.text = AppModel.OPENSOURCE_TEXT;
				rightTextGroup.addChild(opensourceText);
				
				// create author link text
				var authorlinkText:Label = new Label();
				authorlinkText.isQuickHitAreaEnabled = false;
				authorlinkText.nameList.add(PinboredMobileTheme.LABEL_AUTHOR_LINK);
				authorlinkText.text = AppModel.LINK_TEXT;
				rightTextGroup.addChild(authorlinkText);
				
				// add text on the right to the right items layoutgroup
				rightItems.addChild(rightTextGroup);
				
				// add the left AND right items to the container
				container.addChild(leftItems);
				container.addChild(rightItems);
					
				return container;
			}
				
			this.panel.padding = 0;
			this.addChild(panel);
				
			// create screen layout (vertical unit)
			var panelLayout:VerticalLayout = new VerticalLayout();
			panelLayout.gap = 0;
			panelLayout.padding = 0;
			this.panel.layout = panelLayout;
			
			// add the tag search 'bar'
			this.searchTags = new TagTextInput(this._dpiScale);
			this.searchTags.width = this.width;
			this.panel.addChild(this.searchTags);
			
			// add a scrollcontainer for the list
			this.listScrollContainer = new ScrollContainer();
			this.listScrollContainer.verticalScrollPolicy = ScrollContainer.SCROLL_POLICY_ON;
			
			// update scrollcontainer height
			this.listScrollContainer.height = panel.height - _panelExcludedSpace - searchTags.height - 100;
			
			this.panel.addChild(this.listScrollContainer);
				
			// add a list for the bookmarks
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
			list.isSelectable = false;
			
			// add list to panel
			this.listScrollContainer.addChild(list);
			var listBg:Quad = new Quad(50, 50, 0x000000);
			listBg.alpha = 0.3;
			this.list.backgroundSkin = this.list.backgroundDisabledSkin = listBg;
		}
		
		private function input_enterHandler():void
		{
			trace('entered search key word');
		}
		
		override protected function draw():void
		{
			// commit 
			
			// measurement
			panel.width = AppModel.starling.stage.stageWidth;
			panel.height = AppModel.starling.stage.stageHeight;
			
			_backgroundImage.width = this.width;
			_backgroundImage.height = this.height;
			
			// update screengroup, searchtags, scrollcontainer, list width etc.
			list.width = panel.width;
			listScrollContainer.width = panel.width;
			searchTags.width = panel.width;
			
			// update scrollcontainer height
			this.listScrollContainer.height = panel.height - _panelExcludedSpace - searchTags.height - 100;
			
			// layout
		}

		public function get onLoginScreenRequest():ISignal
		{
			return _onLoginScreenRequest;
		}

	}
}