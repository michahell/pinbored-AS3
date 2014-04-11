package nl.powergeek.pinbored.model
{
	import nl.powergeek.utils.ArrayCollectionPager;
	
	import org.osflash.signals.Signal;

	public class ListScreenModel
	{		
		public static var
			rawBookmarkDataList:Array = [],
			rawBookmarkDataListFiltered:Array = [],
			rawBookmarkListCollectionPager:ArrayCollectionPager,
			bookmarksList:Array = [],
			currentResultPage:Number = -1,
			numResultPages:Number = -1;
			
		private static var
			searchTags:Vector.<String>,
			searchString:String;
		
		public static const
			resultPageChanged:Signal = new Signal(Number);
		
		
		public function ListScreenModel()
		{
			
		}
		
		public static function initialize():void
		{
			resultPageChanged.add(function(number:Number):void {
				// update current result page 'pointer'
				currentResultPage = number; 
			});
		}
		
		public static function getFirstResultPage():Array
		{
			var result:Array = [];
			
			if(currentResultPage != 1) {
				
				// reference result to resulting page data array
				result = rawBookmarkListCollectionPager.first();
				
				CONFIG::TESTING {
					trace('first page result #items: ' + result.length);
				}
				
				// also update total result pages. This is unique for this function!
				numResultPages = rawBookmarkListCollectionPager.numPages;
				
				// fire signal to let know that we are now on a different result page
				resultPageChanged.dispatch(rawBookmarkListCollectionPager.numCurrentPage());
			}
			
			return result;
		}
		
		public static function getPreviousResultPage():Array
		{
			var result:Array = [];
			
			if(currentResultPage > 1) {
				
				// reference result to resulting page data array
				result = rawBookmarkListCollectionPager.previous();
				
				CONFIG::TESTING {
					trace('previous page result #items: ' + result.length);
				}
				
				// fire signal to let know that we are now on a different result page
				resultPageChanged.dispatch(rawBookmarkListCollectionPager.numCurrentPage());
			}
			
			return result;
		}
		
		public static function getNumberedResultsPage(number:Number):Array
		{
			var result:Array = [];
			
			if(currentResultPage != number) {
				
				// reference result to resulting page data array
				result = rawBookmarkListCollectionPager.numbered(number);
				
				CONFIG::TESTING {
					trace('numbered page result #items: ' + result.length);
				}
				
				// fire signal to let know that we are now on a different result page
				resultPageChanged.dispatch(rawBookmarkListCollectionPager.numCurrentPage());
			}
			
			return result;
		}
		
		public static function getNextResultsPage():Array
		{
			var result:Array = [];
			
			if(currentResultPage < numResultPages) {
				
				// reference result to resulting page data array
				result = rawBookmarkListCollectionPager.next();
				
				CONFIG::TESTING {
					trace('next page result #items: ' + result.length);
				}
				
				// fire signal to let know that we are now on a different result page
				resultPageChanged.dispatch(rawBookmarkListCollectionPager.numCurrentPage());
			}
			
			return result;
		}
		
		public static function getLastResultsPage():Array
		{
			var result:Array = [];
			
			if(currentResultPage != numResultPages) {
				
				// reference result to resulting page data array
				result = rawBookmarkListCollectionPager.last();
				
				CONFIG::TESTING {
					trace('last page result #items: ' + result.length);
				}
				
				// fire signal to let know that we are now on a different result page
				resultPageChanged.dispatch(rawBookmarkListCollectionPager.numCurrentPage());
			}
			
			return result;
		}
		
		public static function filter(searchWords:String = ''):Array
		{
			var result:Array = rawBookmarkDataList;
			
			// if we have tags or a search string to filter for
			if((searchTags && searchTags.length > 0) || (searchWords.length > 0)) {
				
				// filter on tags
				if(searchTags && searchTags.length > 0) {
					
					CONFIG::TESTING {
						trace('filtering on tags...');
					}
					
					// filter
					result = rawBookmarkDataList.filter(function(bm:Object, index:int, arr:Array):Boolean {
						
						var tags:Array = String(bm.tags).split(" ");
						var test:Boolean;
						
						// if no tags, exclude
						if(tags.length == 0) {
							test = false;
							// one tag on bookmark, one tag to filter with
						} else if(tags.length == 1 && searchTags.length == 1) {
							if (tags[0] == searchTags[0]) test = true;
							// multiple tags on bookmark, multiple tags to filter with
						} else if(tags.length >= 1 && searchTags.length >= 1) {
							for(var i:uint = 0; i < tags.length; i++) {
								if(searchTags.indexOf(tags[i] == -1)) {
									test = false;
									break;
								}
							}
						}
						
						return test;
					});
				}
				
				// fiter on search word(s)
				if(searchWords.length > 0) {
					
					CONFIG::TESTING {
						trace('filtering on search word(s): ' + searchWords);
					}
					
					// first store search string
					searchString = searchWords;
					var searchStringArray:Array = searchString.split(' ');
					
					// search for one word only
					if(searchStringArray.length == 1) {
						
						var word:String = searchStringArray[0];
						
						// filter on result, as it may have been filtered on tags before
						result = result.filter(function(bookmark:Object, index:uint, array:Array):Boolean {
							var included:Boolean = false;
							
							var hrefTest:Array = String(bookmark.href).match(word);
							var extendedTest:Array = String(bookmark.extended).match(word);
							var descriptionTest:Array = String(bookmark.description).match(word);
							var tagsTest:Array = String(bookmark.tags).match(word);
							
							if(hrefTest != null && hrefTest.length > 0) 				included = true;
							if(extendedTest != null && extendedTest.length > 0) 		included = true;
							if(descriptionTest != null && descriptionTest.length > 0) 	included = true;
							if(tagsTest != null && tagsTest.length > 0) 				included = true;
							
							return included;
						});
						
					} else {
						// TODO FEAT: search for multiple words
					}
				}
				
			}
			
			// store result
			rawBookmarkDataListFiltered = result;
			
			CONFIG::TESTING {
				trace('done filtering: ' + rawBookmarkDataListFiltered.length);
			}
			
			// also return it
			return result;
		}
		
		public static function getFilteredBookmarks():Array
		{
			return rawBookmarkDataListFiltered;
		}
		
		public static function createArrayCollectionPager(array:Array):Number
		{
			// fire signal and reset numCurrentPage;
			resultPageChanged.dispatch(-1);
			
			// reset numResultPages as well
			numResultPages = -1;
			
			// first, page raw bookmark results (this list can be huge)
			rawBookmarkListCollectionPager = new ArrayCollectionPager(array, AppSettings.BOOKMARKS_PER_PAGE);
			
			// return the number of pages
			return rawBookmarkListCollectionPager.numPages;
		}
		
		public static function setCurrentTags(tags:Vector.<String>):void
		{
			CONFIG::TESTING {
				trace('LSM tags updated: ' + tags.toString());
			}
			
			// first store tags searched for
			searchTags = tags;
		}
		
		public static function removeFromLists(bookmarkData:Object):void
		{
			var index1:int = rawBookmarkDataList.indexOf(bookmarkData);
			
			CONFIG::TESTING {
				trace('to DELETE, found in list ? ' + index1);
			}
			
			// remove from bookmarks list
			if(index1 != -1)
				rawBookmarkDataList.splice(index1, 1);
			
		}
		
		public static function updateInLists(bm:BookMark):void
		{
			// find the bookmark raw object in the source raw bookmark data list
			var index1:int = rawBookmarkDataList.indexOf(bm.bookmarkData);
			
			CONFIG::TESTING {
				trace('to UPDATE, found in lists ? ' + index1);
			}
			
			// update or replace item in the list
			if(index1 != -1)
				rawBookmarkDataList.splice(index1, 1, bm.bookmarkData_new);
		
			// update array collection pager
			refreshArrayCollectionPager();
		}
		
		private static function refreshArrayCollectionPager():void
		{
			// check if any search string or search tags exist, if so filter
			if( (searchString && searchString.length > 0) || (searchTags && searchTags.length > 0) ) {
				if(searchString.length > 0)
					filter(searchString);
				else
					filter();
				
				// refresh source with FILTERED
				CONFIG::TESTING {
					trace('updating filtered...');
				}
				rawBookmarkListCollectionPager.updateSource(rawBookmarkDataListFiltered);
			} else {
				// refresh source with STANDARD
				CONFIG::TESTING {
					trace('updating normal...');
				}
				rawBookmarkListCollectionPager.updateSource(rawBookmarkDataList);
			}
		}
	}
}