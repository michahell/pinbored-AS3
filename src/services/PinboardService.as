package services
{
	import flash.events.Event;
	import flash.net.URLVariables;
	
	import nl.powergeek.utils.ArrayCollectionPager;
	import nl.powergeek.REST.RESTClient;
	import nl.powergeek.REST.RESTRequest;
	
	import org.osflash.signals.Signal;

	public class PinboardService
	{
		public static var
		allBookmarksReceived:Signal = new Signal(Event);
		
		public function PinboardService() {
			
		}
		
		public static function GetAllBookmarks(tags:Vector.<String> = null):void {
			
			var customData:String = '';
			
			if(tags && tags.length > 0) {
				var tagQuery:String = '&tag=';
				tags.forEach(function(tag:String, index:int, vector:Vector.<String>):void {
					if(index == vector.length - 1)
						tagQuery += tag;
					else
						tagQuery += tag + '+';
				});
				trace('requesting bookmarks filtered by tags: ' + tagQuery);
				customData += tagQuery;
			} else {
				trace('requesting all bookmarks... ');
			}
			
			var params:Object = {
				type:		'get',
				url: 		'posts/all',
				data:		customData,
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
				
				// if bookmark is stale...
				bm.staleConfirmed.addOnce(function():void {
					trace('getting signal..');
				});
				
				// if bookmark is stale...
				bm.notStaleConfirmed.addOnce(function():void {
					trace('getting signal..');
				});
				
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
					// one tag on bookmark, multiple tags to filter with
					} else if(tags.length == 1 && tagNames.length > 1) {
						if (tagNames.indexOf(tags[0]) > 0)
							test = true;
					// multiple tags on bookmark, multiple tags to filter with
					} else if(tags.length > 1 && tagNames.length > 1) {
						for(var i:uint = 0; i < tags.length; i++) {
							if(tagNames.indexOf(tags[i] > 0)) {
								test = true;
								break;
							}
						}
					// multiple tags on bookmark, multiple tags to filter with
					} else if(tags.length > 1 && tagNames.length == 1) {
						for(var j:uint = 0; j < tags.length; j++) {
							if(tagNames[0] == tags[j]) {
								test = true;
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