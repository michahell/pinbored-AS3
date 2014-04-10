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
	import feathers.events.CollectionEventType;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.text.TextFormat;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import nl.powergeek.REST.RESTClient;
	import nl.powergeek.REST.RESTRequest;
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
	
	import starling.animation.DelayedCall;
	import starling.animation.Transitions;
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
			_listFadeRef:uint,
			_resultPageChanged:Signal = new Signal(),
			_resultPageChangedPending:Signal = new Signal(),
			_listFadeChanged:Signal = new Signal( Number ),
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
			list.addEventListener( FeathersEventType.SCROLL_START, onListScrollStart );
			list.addEventListener( FeathersEventType.SCROLL_COMPLETE, onListScrollComplete );
			
			// when searched for tags, update the bookmarks list
			searchTags.searchTagsTriggered.add(function(tagNames:Vector.<String>):void {
				
				// show loading icon
				showLoading();
				
				// set list to zero alpha
				list.alpha = 0;
				
				// filter on tags 
				ListScreenModel.filter();
				
				// show loading icon
				hideLoading();
				
				// small timeout for update?
				updateScrollContainerHeight();
					
				if(ListScreenModel.rawBookmarkDataListFiltered.length > 0) {
					displayInitialResultsPage(ListScreenModel.getFilteredBookmarks());
				} else {
					displayNoResults();
				}
			});
			
			// listen to Tag input signals
			searchTags.tagsChanged.add(function(tags:Vector.<String>):void {
				ListScreenModel.setCurrentTags(tags);
			});
			
			// listen to Pager signals
			pagingControl.firstPageRequested.add(function():void {
				_resultPageChangedPending.dispatch();
				listFade(0).addOnce(function():void {
					displayFirstResultsPage();
				});
			});
			
			pagingControl.previousPageRequested.add(function():void {
				_resultPageChangedPending.dispatch();
				listFade(0).addOnce(function():void {
					displayPreviousResultsPage();
				});
			});
			
			pagingControl.numberedPageRequested.add(function(number:Number):void {
				_resultPageChangedPending.dispatch();
				listFade(0).addOnce(function():void {
					displayNumberedResultsPage(number);
				});
			});
			
			pagingControl.nextPageRequested.add(function():void {
				_resultPageChangedPending.dispatch();
				listFade(0).addOnce(function():void {
					displayNextResultsPage();
				});
			});
			
			pagingControl.lastPageRequested.add(function():void {
				_resultPageChangedPending.dispatch();
				listFade(0).addOnce(function():void {
					displayLastResultsPage();
				});
			});
			
			ListScreenModel.resultPageChanged.add(function(pageNumber:Number):void {
				if(pagingControl.visible == true)
					pagingControl.update(pageNumber);
			});
			
			_resultPageChanged.add(function():void {
				_resultPageChangedPending.removeAll();
			});
			
			// get all bookmarks and populate list control
			getInitialData();
		}
		
		private function onListScrollComplete(event:starling.events.Event):void
		{
			
		}
		
		private function onListScrollStart(event:starling.events.Event):void
		{
			
		}
		
		private function listRendererAddHandler( event:starling.events.Event, itemRenderer:PinboardLayoutGroupItemRenderer ):void
		{
			CONFIG::TESTING {
				trace('list IR added.');
			}
			listFadePostPoned(1);
			
			// set isBeingEdited to false
			itemRenderer.isBeingEdited = false;
			
			if(itemRenderer.isCreated != true) {
				itemRenderer.addEventListener(FeathersEventType.CREATION_COMPLETE, function(event:starling.events.Event):void {
					// remove listener
					itemRenderer.removeEventListener(FeathersEventType.CREATION_COMPLETE, arguments.callee);
					// call insta collapse
					itemRenderer.instaCollapse();
				});
			} else {
				itemRenderer.addEventListener(BookmarkEvent.ITEM_RENDERER_COMMIT_DATA, function():void {
					// remove listener
					itemRenderer.removeEventListener(BookmarkEvent.ITEM_RENDERER_COMMIT_DATA, arguments.callee);
					// call insta collapse
					itemRenderer.instaCollapse();
				})
			}
			
			itemRenderer.addEventListener(BookmarkEvent.BOOKMARK_DELETED, function(event:starling.events.Event):void {
				CONFIG::TESTING {
					trace('receiving BOOKMARK_DELETED event from custom item renderer...');
				}
				var deletedBookmark:BookMark = BookMark(event.data);
				removeBookmarkFromList(deletedBookmark);
			});
			
			itemRenderer.addEventListener(BookmarkEvent.BOOKMARK_EXPANDING, function(event:starling.events.Event):void {
				CONFIG::TESTING {
					trace('receiving BOOKMARK_EXPANDING event from custom item renderer...');
				}
			});
			
			itemRenderer.addEventListener(BookmarkEvent.BOOKMARK_FOLDING, function(event:starling.events.Event):void {
				CONFIG::TESTING {
					trace('receiving BOOKMARK_FOLDING event from custom item renderer...');
				}
			});
		}
		
		private function listRendererRemoveHandler( event:starling.events.Event, itemRenderer:PinboardLayoutGroupItemRenderer ):void
		{
			CONFIG::TESTING {
				trace('list IR removed.');
			}
			
			itemRenderer.removeEventListeners();
		}
		
		private function listFadePostPoned(alpha:Number):void
		{
			// clear the timeout reference if it exists
			if(_listFadeRef != 0)
				clearTimeout(_listFadeRef);
			
			// set the timeout process
			_listFadeRef = setTimeout(function():void {
				listFade(alpha);
			}, 1000);
		}
		
		private function listFade(alpha:Number):Signal
		{
			CONFIG::TESTING {
				trace('list fade called, to alpha: ' + alpha);
			}
			
			if(alpha == 1)
				pagingControl.fadeIn();
			else
				pagingControl.fadeOut();
			
			// tween params
			var tween:Tween = new Tween(list, PinboredDesktopTheme.LIST_ANIMATION_TIME, Transitions.EASE_OUT);
			tween.animate("alpha", alpha);
			
			// completed
			tween.onComplete = function():void {
				_listFadeChanged.dispatch(alpha);
			};
			
			Starling.current.juggler.add(tween);
			
			return _listFadeChanged;
		}
		
		private function searchBookmarksHandler(event:starling.events.Event):void
		{
			// show loading icon
			showLoading();
			
			// set list to zero alpha
			list.alpha = 0;
			
			// filter
			var searchString:String = TextInput(event.target).text;
			
			CONFIG::TESTING {
				trace('searchString: ' + searchString);
			}
			
			ListScreenModel.filter(searchString);
			
			// show loading icon
			hideLoading();
			
			// small timeout for update?
			updateScrollContainerHeight();
			
			if(ListScreenModel.getFilteredBookmarks().length > 0) {
				displayInitialResultsPage(ListScreenModel.getFilteredBookmarks());
			} else {
				displayNoResults();
			}
		}
		
		private function getInitialData():void
		{
			// throw all bookmarks into a list
			PinboardService.bookmarksReceived.addOnce(function(event:flash.events.Event):void {
				
				var parsedResponse:Object = JSON.parse(event.target.data as String);
				
				parsedResponse.forEach(function(bookmark:Object, index:int, array:Array):void {
					// for reference
					ListScreenModel.rawBookmarkDataList.push(bookmark);
					// for usage
					ListScreenModel.rawBookmarkDataListFiltered.push(bookmark);
				});
				
				displayInitialResultsPage(ListScreenModel.rawBookmarkDataListFiltered);
				
				// small timeout for update?
				updateScrollContainerHeight();
			});
			
			// show loading icon
			showLoading();
			
			// set list to zero alpha
			list.alpha = 0;
			
			// get all bookmarks
			//PinboardService.GetAllBookmarks(['Webdevelopment']);
			PinboardService.GetAllBookmarks();
		}
		
		private function updateScrollContainerHeight():void
		{
			setTimeout(function():void {
				hideLoading();
				// validate for list scroll height update
				invalidate(INVALIDATION_FLAG_ALL);
			}, 1000);
		}
		
		private function displayNoResults():void
		{
			CONFIG::TESTING {
				trace('no results after filtering...');
			}
			
			cleanBookmarkList();
			pagingControl.visible = false;
			
			pagingControl.invalidate(INVALIDATION_FLAG_ALL);
			invalidate(INVALIDATION_FLAG_ALL);
		}
		
		private function cleanBookmarkList():void {
			
			// first, remove all listeners from old bookmarksList
			ListScreenModel.bookmarksList.forEach(function(bm:BookMark, index:uint, array:Array):void {
				bm.editTapped..removeAll();
				bm.deleteTapped.removeAll();
				bm.editConfirmed.removeAll();
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
					
					var requestCompleted:Function = function(event:flash.events.Event):void {
						CONFIG::TESTING {
							trace('bookmark delete request completed.');
						}
						// update the bookmark by confirming delete
						tappedBookmark.deleteConfirmed.dispatch();
					}
					
					var requestFailed:Function = function(event:flash.events.Event):void {
						CONFIG::TESTING {
							trace('bookmark delete request failed.');
						}
					}
					
					// execute request and attach listener to returned signal
					PinboardService.deleteBookmark(tappedBookmark, true).then(requestCompleted, requestFailed);
					
					// mock deleted confirmed
					setTimeout(function():void {
						CONFIG::TESTING {
							trace('[MOCK] bookmark delete request completed.');
						}
						// update the bookmark by confirming delete
						tappedBookmark.deleteConfirmed.dispatch();
					}, 500);
					
				});
				
				bm.editConfirmed.add(function(editedBookmark:BookMark):void {
					
					var requestCompleted:Function = function(event:flash.events.Event):void {
						CONFIG::TESTING {
							trace('bookmark update request completed.');
						}
						
						// update array collection pager source
						ListScreenModel.updateInLists(editedBookmark);
						
						// and update array collection pager				
						
						// update to visualize directly
						editedBookmark.update();
						
						// TODO PROBLEM: solve tag problem
						//trace('edited bookmark tags: ' + editedBookmark.tags.toString());
						
						list.invalidate();
					};
					
					var requestFailed:Function = function(event:flash.events.Event):void {
						CONFIG::TESTING {
							trace('bookmark update request failed.');
						}
					};
					
					// execute request and attach promise functions
					PinboardService.updateBookmark(editedBookmark, false).then(requestCompleted, requestFailed);
				});
				
			});
			
			// update the list's dataprovider one by one
			//updateDataProvider(ListScreenModel.bookmarksList);
			
			// update the list's dataprovider with all items at once
			list.dataProvider = new ListCollection(ListScreenModel.bookmarksList);
			
			// fire result page has changed signal
			_resultPageChanged.dispatch();
		}
		
		private function onListReset(event:starling.events.Event):void
		{
			CONFIG::TESTING {
				trace('list reset!');
			}
		}
		
		private function updateDataProvider(bookmarksList:Array):void
		{
			var copy:Array = bookmarksList.slice();
			
			var functor:Function = function():void {
				if(copy && copy.length > 0)
					list.dataProvider.addItem(copy.pop());
				else
					Starling.juggler.remove(delayedCall);		
			};
			
			var delayedCall:DelayedCall = new DelayedCall(functor, 1/10);
			delayedCall.repeatCount = 0;

			list.dataProvider = new ListCollection();
			Starling.juggler.add(delayedCall);
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
			if(page && page.length > 0) {
				refreshListWithCollection(page);
			} else {
				CONFIG::TESTING {
					trace('todo: first: some warning?');
				}
			}
		}
		
		private function displayPreviousResultsPage():void
		{
			var page:Array = ListScreenModel.getPreviousResultPage();
			if(page && page.length > 0) {
				refreshListWithCollection(page);
			} else {
				CONFIG::TESTING {
					trace('todo: previous: some warning?');
				}
			}
		}
		
		private function displayNumberedResultsPage(number:Number):void
		{
			var page:Array = ListScreenModel.getNumberedResultsPage(number);
			if(page && page.length > 0) {
				refreshListWithCollection(page);
			} else {
				CONFIG::TESTING {
					trace('todo: numbered: some warning?');
				}
			}
		}
		
		private function displayNextResultsPage():void
		{
			var page:Array = ListScreenModel.getNextResultsPage();
			if(page && page.length > 0) {
				refreshListWithCollection(page);
			} else {
				CONFIG::TESTING {
					trace('todo: next: some warning?');
				}
			}
		}
		
		private function displayLastResultsPage():void
		{
			var page:Array = ListScreenModel.getLastResultsPage();
			if(page && page.length > 0) {
				refreshListWithCollection(page);
			} else {
				CONFIG::TESTING {
					trace('todo: last: some warning?');
				}
			}
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
			// delete item from rawBookMarkList
			ListScreenModel.removeFromLists(bookmark.bookmarkData);
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
			this.list.isQuickHitAreaEnabled = false;
			this.list.isSelectable = false;
			
			this.list.addEventListener(FeathersEventType.SCROLL_START, onScrollStart);
			this.list.addEventListener(FeathersEventType.SCROLL_COMPLETE, onScrollComplete);
			
			// add a list for the bookmarks
			this.list.itemRendererFactory = function():IListItemRenderer
			{
				var renderer:PinboardLayoutGroupItemRenderer = new PinboardLayoutGroupItemRenderer();
				renderer.padding = 5;
				return renderer;
			};
			
			// add list to panel
			this.listScrollContainer.addChild(list);
			var listBg:Quad = new Quad(50, 50, 0x000000);
			listBg.alpha = 0.3;
			this.list.backgroundSkin = this.list.backgroundDisabledSkin = listBg;
		}
		
		private function onScrollStart(event:starling.events.Event):void
		{
			CONFIG::TESTING {
				trace('list scroll started');
			}
			this.list.addEventListener(starling.events.Event.SCROLL, onScrollHandler);
		}
		
		private function onScrollComplete(event:starling.events.Event):void
		{
			CONFIG::TESTING {
				trace('list scroll completed');
			}
			this.list.removeEventListener(starling.events.Event.SCROLL, onScrollHandler);
		}
		
		private function onScrollHandler(event:starling.events.Event):void
		{
			CONFIG::TESTING {
				trace('list scrolling...');
			}
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