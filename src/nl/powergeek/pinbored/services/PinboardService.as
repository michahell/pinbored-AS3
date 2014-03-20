package nl.powergeek.pinbored.services
{
	import flash.events.Event;
	import flash.net.URLVariables;
	
	import nl.powergeek.REST.RESTClient;
	import nl.powergeek.REST.RESTRequest;
	import nl.powergeek.utils.ArrayCollectionPager;
	
	import org.osflash.signals.Signal;
	import nl.powergeek.pinbored.model.BookMark;

	public class PinboardService
	{
		public static const
			allBookmarksReceived:Signal = new Signal(Event);
		
		public function PinboardService() {
			
		}
		
		public static function deleteBookmark(bookmark:BookMark):Signal {
			
			var deleteSignal:Signal = new Signal();
			var argument:String = '&url=';
			
			// setup request params
			var params:Object = {
				type:		'get',
				url: 		'posts/delete',
				data:		argument + bookmark.href,
				signal: 	deleteSignal
			};
			
			// build the request
			var getBookmarks:RESTRequest = new RESTRequest(params);
			
			// do the request (or dryrun it)
			RESTClient.doRequest(getBookmarks, true);
			
			return deleteSignal;
		}
		
		public static function GetAllBookmarks(tags:Array = null):void {
			
			var tagList:String = '&tag=';
			var argument:String = '';
			
			if(tags && tags.length > 0) {
				tags.forEach(function(tag:String, index:int, array:Array):void {
					if(index == array.length - 1)
						tagList += tag;
					else
						tagList += tag + '+';
				});
				argument = tagList;
			}
			
			// setup request params
			var params:Object = {
				type:		'get',
				url: 		'posts/all',
				data:		argument,
				signal: 	allBookmarksReceived
			};
			
			// build the request
			var getBookmarks:RESTRequest = new RESTRequest(params);
			
			// do the request (or dryrun it)
			RESTClient.doRequest(getBookmarks, false);
		}
		
		public static function mapRawBookmarksToBookmarks(rawObjectsArray:Array):Array
		{
			var bookmarkCollection:Array = [];
			
			// add all bookmarks to 'the list'
			rawObjectsArray.forEach(function(bookmark:Object, index:int, array:Array):void {
				var bm:BookMark = new BookMark(bookmark);
				bookmarkCollection.push(bm);
			});
			
			return bookmarkCollection;
		}
		
		public static function filterTags(rawBookmarkDataList:Array, tagNames:Vector.<String>):Array
		{
			var result:Array = [];
			
			if(tagNames.length > 0) {
				
				result = rawBookmarkDataList.filter(function(bm:Object, index:int, arr:Array):Boolean {
					
					var tags:Array = String(bm.tags).split(" ");
					var test:Boolean;
					
					// if no tags, exclude
					if(tags.length == 0) {
						test = false;
					// one tag on bookmark, one tag to filter with
					} else if(tags.length == 1 && tagNames.length == 1) {
						if (tags[0] == tagNames[0]) test = true;
					// multiple tags on bookmark, multiple tags to filter with
					} else if(tags.length >= 1 && tagNames.length >= 1) {
						for(var i:uint = 0; i < tags.length; i++) {
							if(tagNames.indexOf(tags[i] == -1)) {
								test = false;
								break;
							}
						}
					}
					
					return test;
				});
				
			} else {
				result = rawBookmarkDataList;
			}
			
			return result;
		}
	}
}