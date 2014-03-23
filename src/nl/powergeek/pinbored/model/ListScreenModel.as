package nl.powergeek.pinbored.model
{
	import nl.powergeek.utils.ArrayCollectionPager;
	
	import org.osflash.signals.Signal;

	public class ListScreenModel
	{		
		public static var
			// raw bookmarks
			rawBookmarkDataList:Array = [],
			rawBookmarkDataListFiltered:Array = [],
			
			// pager
			rawBookmarkListCollectionPager:ArrayCollectionPager,
			
			// final or current list
			bookmarksList:Array = [],
			
			// result paging state
			currentResultPage:Number = -1,
			numResultPages:Number = -1;
		
		public static const
			resultPageChanged:Signal = new Signal(Number);
		
		public static const
			BOOKMARKS_PER_PAGE:uint = 25;
		
		
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
				trace('first page result #items: ' + result.length);
				
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
				trace('previous page result #items: ' + result.length);
				
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
				trace('numbered page result #items: ' + result.length);
				
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
				trace('next page result #items: ' + result.length);
				
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
				trace('last page result #items: ' + result.length);
				
				// fire signal to let know that we are now on a different result page
				resultPageChanged.dispatch(rawBookmarkListCollectionPager.numCurrentPage());
			}
			
			return result;
		}
		
	}
}