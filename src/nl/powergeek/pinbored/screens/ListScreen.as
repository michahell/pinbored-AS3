package nl.powergeek.pinbored.screens
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
	import flash.utils.setTimeout;
	
	import nl.powergeek.REST.RESTClient;
	import nl.powergeek.REST.RESTRequest;
	import nl.powergeek.feathers.components.AppScreen;
	import nl.powergeek.feathers.components.Pager;
	import nl.powergeek.feathers.components.PinboardLayoutGroupItemRenderer;
	import nl.powergeek.feathers.components.PinboredHeader;
	import nl.powergeek.feathers.components.Tag;
	import nl.powergeek.feathers.components.TagTextInput;
	import nl.powergeek.feathers.themes.PinboredDesktopTheme;
	import nl.powergeek.pinbored.model.AppModel;
	import nl.powergeek.pinbored.model.BookMark;
	import nl.powergeek.pinbored.model.BookmarkEvent;
	import nl.powergeek.pinbored.model.ListScreenModel;
	import nl.powergeek.pinbored.services.PinboardService;
	import nl.powergeek.utils.ArrayCollectionPager;
	
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osmf.layout.HorizontalAlign;
	
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.ResizeEvent;
	import starling.textures.Texture;
	
	public class ListScreen extends AppScreen
	{
		// GUI related
		private var 
			panel:Panel = new Panel(),
			searchTags:TagTextInput,
			pagingControl:Pager,
			listScrollContainer:ScrollContainer,
			list:List = new List(),
			_backgroundImage:Image = new Image(Texture.fromBitmap(new PinboredDesktopTheme.BACKGROUND2(), false)),
			header:PinboredHeader,
			footer:ScrollContainer,
			searchBookmarks:TextInput;
		
		private var
			_onLoginScreenRequest:Signal = new Signal( ListScreen );

		
		public function ListScreen()
		{
			super();
		}
		
		override protected function initialize():void
		{
			// initialize model
			ListScreenModel.initialize();
			
			// create GUI
			createGUI();
			
			// listen for transition complete
			owner.addEventListener(FeathersEventType.TRANSITION_COMPLETE, onTransitionComplete);
		}
		
		private function onTransitionComplete(event:starling.events.Event):void
		{
			// remove listener
			owner.removeEventListener(FeathersEventType.TRANSITION_COMPLETE, onTransitionComplete);
			
			// setup list delete listener
			list.addEventListener( FeathersEventType.RENDERER_ADD, listRendererAddHandler );
			list.addEventListener( FeathersEventType.RENDERER_REMOVE, listRendererRemoveHandler );
			
			// when searched for tags, update the bookmarks list
			searchTags.searchTagsTriggered.add(function(tagNames:Vector.<String>):void {
				
				// show loading icon
				showLoading();
				
				// filter on tags 
				ListScreenModel.filter();
				
				// show loading icon
				hideLoading();
				
				// small timeout for update?
				setTimeout(function():void {
					// validate for list scroll height update
					invalidate(INVALIDATION_FLAG_ALL);
				}, 1000);
					
				if(ListScreenModel.rawBookmarkDataListFiltered.length > 0) {
					displayInitialResultsPage(ListScreenModel.getFilteredBookmarks());
				} else {
					trace('no results after filtering...');
					cleanBookmarkList();
				}
			});
			
			// listen to Tag input signals
			searchTags.tagsChanged.add(function(tags:Vector.<String>):void {
				ListScreenModel.setCurrentTags(tags);
			});
			
			// listen to Pager signals
			pagingControl.firstPageRequested.add(function():void {
				displayFirstResultsPage();
			});
			
			pagingControl.previousPageRequested.add(function():void {
				displayPreviousResultsPage();
			});
			
			pagingControl.numberedPageRequested.add(function(number:Number):void {
				displayNumberedResultsPage(number);
			});
			
			pagingControl.nextPageRequested.add(function():void {
				displayNextResultsPage();
			});
			
			pagingControl.lastPageRequested.add(function():void {
				displayLastResultsPage();
			});
			
			ListScreenModel.resultPageChanged.add(function(pageNumber:Number):void {
				if(pagingControl.visible == true)
					pagingControl.update(pageNumber);
			});
			
			// get all bookmarks and populate list control
			getInitialData();
		}
		
		private function listRendererAddHandler( event:starling.events.Event, itemRenderer:PinboardLayoutGroupItemRenderer ):void
		{
//			itemRenderer.addSelf();
			
			itemRenderer.addEventListener(BookmarkEvent.BOOKMARK_DELETED, function(event:starling.events.Event):void {
				trace('receiving BOOKMARK_DELETED event from custom item renderer...');
				var deletedBookmark:BookMark = BookMark(event.data);
				removeBookmarkFromList(deletedBookmark);
			});
			
			itemRenderer.addEventListener(BookmarkEvent.BOOKMARK_EXPANDING, function(event:starling.events.Event):void {
				trace('receiving BOOKMARK_EXPANDING event from custom item renderer...');
				var collapsedBookmark:BookMark = BookMark(event.data);
				// TODO stuff with collapsing bookmark
			});
			
			itemRenderer.addEventListener(BookmarkEvent.BOOKMARK_FOLDING, function(event:starling.events.Event):void {
				trace('receiving BOOKMARK_FOLDING event from custom item renderer...');
				var foldedBookmark:BookMark = BookMark(event.data);
				// TODO stuff with folding bookmark
			});
		}
		
		private function listRendererRemoveHandler( event:starling.events.Event, itemRenderer:PinboardLayoutGroupItemRenderer ):void
		{
			itemRenderer.removeEventListeners(BookmarkEvent.BOOKMARK_EXPANDING);
			itemRenderer.removeEventListeners(BookmarkEvent.BOOKMARK_EXPANDED);
			itemRenderer.removeEventListeners(BookmarkEvent.BOOKMARK_FOLDING);
			itemRenderer.removeEventListeners(BookmarkEvent.BOOKMARK_FOLDED);
			itemRenderer.removeEventListeners(BookmarkEvent.BOOKMARK_DELETED);
			itemRenderer.removeEventListeners(BookmarkEvent.BOOKMARK_EDITED);
		}
		
		private function searchBookmarksHandler(event:starling.events.Event):void
		{
			//trace('entered search key word');
			
			// show loading icon
			showLoading();
			
			// filter
			var searchString:String = TextInput(event.target).text;
			//trace('searchString: ' + searchString);
			ListScreenModel.filter(searchString);
			
			// show loading icon
			hideLoading();
			
			// small timeout for update?
			setTimeout(function():void {
				// validate for list scroll height update
				invalidate(INVALIDATION_FLAG_ALL);
			}, 1000);
			
			if(ListScreenModel.getFilteredBookmarks().length > 0) {
				displayInitialResultsPage(ListScreenModel.getFilteredBookmarks());
			} else {
				trace('no results after filtering...');
				cleanBookmarkList();
			}
		}
		
		private function getInitialData():void
		{
			// throw all bookmarks into a list
			PinboardService.bookmarksReceived.addOnce(function(event:flash.events.Event):void {
				
				var parsedResponse:Object = JSON.parse(event.target.data as String);
				
				parsedResponse.forEach(function(bookmark:Object, index:int, array:Array):void {
					// quick href field replace (for auto-linking with hypertextfieldtextrenderer
					bookmark.link = '<a href=\"' + bookmark.href + '\">' + bookmark.href + '</a>';
					ListScreenModel.rawBookmarkDataList.push(bookmark);
				});
				
				displayInitialResultsPage(ListScreenModel.rawBookmarkDataList);
				
				// hide loading icon
				setTimeout(function():void {
					hideLoading();
					// validate for list scroll height update
					invalidate(INVALIDATION_FLAG_ALL);
				}, 1000);
			});
			
			// show loading icon
			showLoading();
			
			// get all bookmarks
			PinboardService.GetAllBookmarks(['Webdevelopment']);
			//PinboardService.GetAllBookmarks();
		}
		
		private function cleanBookmarkList():void {
			
			// first, remove all listeners from old bookmarksList
			ListScreenModel.bookmarksList.forEach(function(bm:BookMark, index:uint, array:Array):void {
				bm.editTapped..removeAll();
				bm.deleteTapped.removeAll();
				bm.staleConfirmed.removeAll();
				bm.notStaleConfirmed.removeAll();
			});
			
			// then, null the dataprovider for refresh
			list.dataProvider = null;
		}
		
		private function activateBookmarkList():void {
			
			// attach listeners to each bookmark in the bookmarkslist
			ListScreenModel.bookmarksList.forEach(function(bm:BookMark, index:uint, array:Array):void {
				
				// if bookmark DELETE is tapped
				bm.deleteTapped.addOnce(function(tappedBookmark:BookMark):void {
					trace('bookmark delete tapped!');
					// execute request and attach listener to returned signal
					var returnSignal:Signal = PinboardService.deleteBookmark(tappedBookmark);
					returnSignal.addOnce(function():void {
						trace('bookmark delete request completed.');
						// update the bookmark by confirming delete
						tappedBookmark.deleteConfirmed.dispatch();
					});
					
					// mock delete
					setTimeout(function():void{
						trace('[MOCK] bookmark delete request completed.');
						// update the bookmark by confirming delete
						tappedBookmark.deleteConfirmed.dispatch();
					}, 500);
					
				});
				
			});
			
			// update the list's dataprovider
			list.dataProvider = new ListCollection(ListScreenModel.bookmarksList);
		}
		
		private function displayInitialResultsPage(array:Array):void
		{
			// create a new array collection pager and get number of result pages
			var resultPages:Number = ListScreenModel.createArrayCollectionPager(array);
			
			if(resultPages > 1) {
				// make paging control visible
				pagingControl.visible = true;
				pagingControl.activate(resultPages);
			} else {
				pagingControl.visible = false;
			}
			
			pagingControl.invalidate(INVALIDATION_FLAG_ALL);
			invalidate(INVALIDATION_FLAG_ALL);
			
			// display initial results
			displayFirstResultsPage();
		}
		
		private function displayFirstResultsPage():void
		{
			var page:Array = ListScreenModel.getFirstResultPage();
			if(page && page.length > 0)
				refreshListWithCollection(page);
			else
				trace('todo: first: some warning?');
		}
		
		private function displayPreviousResultsPage():void
		{
			var page:Array = ListScreenModel.getPreviousResultPage();
			if(page && page.length > 0)
				refreshListWithCollection(page);
			else
				trace('todo: previous: some warning?');
		}
		
		private function displayNumberedResultsPage(number:Number):void
		{
			var page:Array = ListScreenModel.getNumberedResultsPage(number);
			if(page && page.length > 0)
				refreshListWithCollection(page);
			else
				trace('todo: numbered: some warning?');
		}
		
		private function displayNextResultsPage():void
		{
			var page:Array = ListScreenModel.getNextResultsPage();
			if(page && page.length > 0)
				refreshListWithCollection(page);
			else
				trace('todo: next: some warning?');
		}
		
		private function displayLastResultsPage():void
		{
			var page:Array = ListScreenModel.getLastResultsPage();
			if(page && page.length > 0)
				refreshListWithCollection(page);
			else
				trace('todo: last: some warning?');
		}
		
		private function refreshListWithCollection(array:Array):void
		{
			if(!array || array.length == 0)
				throw new Error('array is null or contains no items.');
				
			cleanBookmarkList();
			ListScreenModel.bookmarksList = PinboardService.mapRawBookmarksToBookmarks(array);
			activateBookmarkList();
		}		
		
		private function removeBookmarkFromList(bookmark:BookMark):void {
			
			// remove item from list dataProvider
			var bmIndex:Number = list.dataProvider.getItemIndex(bookmark);
			list.dataProvider.removeItemAt(bmIndex);
			
			// also delete item from rawBookMarkList
			// TODO delete item from rawBookMarkList
		}
		
		public function get onLoginScreenRequest():ISignal
		{
			return _onLoginScreenRequest;
		}
		
		private function createGUI():void
		{
			// create nice background
			this.addChild(_backgroundImage);
			
			// add a panel with a header, footer and no scroll shit
			this.panel.verticalScrollPolicy = Panel.SCROLL_POLICY_OFF;
			this.panel.horizontalScrollPolicy = Panel.SCROLL_POLICY_OFF;
			this.panel.nameList.add(PinboredDesktopTheme.PANEL_TRANSPARENT_BACKGROUND);
			
			this.panel.headerFactory = function():PinboredHeader
			{
				// const header:Header = new Header();
				header = new PinboredHeader();
				header.title = "Bookmarks list";
				header.titleAlign = Header.TITLE_ALIGN_PREFER_LEFT;
				header.padding = 0;
				header.paddingLeft = 10;
				header.gap = 0;
				
				header.titleFactory = function():ITextRenderer
				{
					var titleRenderer:TextFieldTextRenderer = new TextFieldTextRenderer();
					titleRenderer.textFormat = PinboredDesktopTheme.TEXTFORMAT_SCREEN_TITLE;
					return titleRenderer;
				}
				
				searchBookmarks = new TextInput();
				searchBookmarks.nameList.add(PinboredDesktopTheme.TEXTINPUT_SEARCH);
				searchBookmarks.prompt = "search any keyword and hit enter...";
				searchBookmarks.width = 500;
				
				//we can't get an enter key event without changing the returnKeyLabel
				//not using ReturnKeyLabel.GO here so that it will build for web
				searchBookmarks.textEditorProperties.returnKeyLabel = "go";
				searchBookmarks.addEventListener(FeathersEventType.ENTER, searchBookmarksHandler);
				
				header.rightItems = new <DisplayObject>[searchBookmarks];
				
				return header;
			}
				
			// panel footer
			panel.footerFactory = function():ScrollContainer
			{ 
				footer = new ScrollContainer();
				footer.nameList.add( ScrollContainer.ALTERNATE_NAME_TOOLBAR );
				footer.horizontalScrollPolicy = ScrollContainer.SCROLL_POLICY_OFF;
				footer.verticalScrollPolicy = ScrollContainer.SCROLL_POLICY_OFF;
								
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
				var logo:Image = new Image(Texture.fromBitmap(new PinboredDesktopTheme.LOGO_TRANSPARENT(), true));
				logo.scaleX = logo.scaleY = 0.75;
				logo.alpha = alpha;
				leftItems.addChild(logo);
				
				// create disclaimer text
				var disclaimer:Label = new Label();
				disclaimer.maxWidth = 400;
				disclaimer.nameList.add(PinboredDesktopTheme.LABEL_DISCLAIMER);
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
				var feathersLogo:Image = new Image(Texture.fromBitmap(new PinboredDesktopTheme.ICON_FEATHERS(), true));
				feathersLogo.scaleX = feathersLogo.scaleY = 0.8;
				feathersLogo.alpha = alpha;
				rightItems.addChild(feathersLogo);
				
				var starlingLogo:Image = new Image(Texture.fromBitmap(new PinboredDesktopTheme.ICON_STARLING(), true));
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
				opensourceText.nameList.add(PinboredDesktopTheme.LABEL_RIGHT_ALIGNED_TEXT);
				opensourceText.text = AppModel.OPENSOURCE_TEXT;
				rightTextGroup.addChild(opensourceText);
				
				// create author link text
				var authorlinkText:Label = new Label();
				authorlinkText.isQuickHitAreaEnabled = false;
				authorlinkText.nameList.add(PinboredDesktopTheme.LABEL_AUTHOR_LINK);
				authorlinkText.text = AppModel.LINK_TEXT;
				rightTextGroup.addChild(authorlinkText);
				
				// add text on the right to the right items layoutgroup
				rightItems.addChild(rightTextGroup);
				
				// add the left AND right items to the container
				footer.addChild(leftItems);
				footer.addChild(rightItems);
				
				return footer;
			}
				
			this.panel.padding = 0;
			this.addChild(panel);
				
			// create screen layout (vertical unit)
			var panelLayout:VerticalLayout = new VerticalLayout();
			panelLayout.gap = 0;
			panelLayout.padding = 0;
			this.panel.layout = panelLayout;
			
			// add the tag search 'bar'
			this.searchTags = new TagTextInput(this._dpiScale, null);
			this.searchTags.width = this.width;
			this.panel.addChild(this.searchTags);
			
			// add the list result paging bar, initially set to invisible
			this.pagingControl = new Pager();
			this.pagingControl.visible = false;
			this.panel.addChild(this.pagingControl);
			
			// add a scrollcontainer for the list
			this.listScrollContainer = new ScrollContainer();
			this.listScrollContainer.verticalScrollPolicy = ScrollContainer.SCROLL_POLICY_ON;
			
			this.panel.addChild(this.listScrollContainer);
			
			// list styling
			var listLayout:VerticalLayout = new VerticalLayout();
			listLayout.hasVariableItemDimensions = true;
			
			// copied over from list initialize function
			listLayout.useVirtualLayout = true;
			listLayout.manageVisibility = true;
			listLayout.paddingTop = listLayout.paddingRight = listLayout.paddingBottom = listLayout.paddingLeft = 0;
			listLayout.gap = 0;
			listLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
			listLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			
			// assign the listLayout to the list
			this.list.layout = listLayout;
			
			// add a list for the bookmarks
			this.list.itemRendererFactory = function():IListItemRenderer
			{
				var renderer:PinboardLayoutGroupItemRenderer = new PinboardLayoutGroupItemRenderer();
				renderer.padding = 5;
				return renderer;
			};
			
			this.list.isSelectable = false;
			
			// add list to panel
			this.listScrollContainer.addChild(list);
			var listBg:Quad = new Quad(50, 50, 0x000000);
			listBg.alpha = 0.3;
			this.list.backgroundSkin = this.list.backgroundDisabledSkin = listBg;
			
			this.isQuickHitAreaEnabled = false;
			
			// finally, validate panel for scroll container height update
//			invalidate(INVALIDATION_FLAG_ALL);
		}
		
		override protected function draw():void
		{
			// resize panel
			panel.width = AppModel.starling.stage.stageWidth;
			panel.height = AppModel.starling.stage.stageHeight;
			
			_backgroundImage.width = this.width;
			_backgroundImage.height = this.height;
			
			// update searchtags
			searchTags.width = panel.width;
			
			// update paging control
			pagingControl.width = panel.width;
			
			// update list scrollcontainer and list width
			listScrollContainer.width = panel.width;
			list.width = panel.width;
			
			// update listcontainerHeight
			var listContainerHeight:Number = 0;
			
			if(header && footer && pagingControl && searchTags)
				listContainerHeight = header.height + footer.height + pagingControl.height + searchTags.height + 1;
			
			// update scrollcontainer height
			//this.listScrollContainer.height = panel.height - listContainerHeight - searchTags.height - 123;
			this.listScrollContainer.height = panel.height - listContainerHeight;
			
			super.draw();
		}

	}
}