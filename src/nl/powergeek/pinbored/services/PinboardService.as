package nl.powergeek.pinbored.services
{
	import com.codecatalyst.promise.Deferred;
	import com.codecatalyst.promise.Promise;
	
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	import nl.powergeek.REST.RESTClient;
	import nl.powergeek.REST.RESTRequest;
	import nl.powergeek.pinbored.model.BookMark;
	import nl.powergeek.utils.ArrayCollectionPager;
	
	import org.osflash.signals.Signal;

	public class PinboardService
	{
		public static const
			bookmarksReceived:Signal = new Signal(Event);
		
		
		public function PinboardService() { }
		
		public static function getUserToken(username:String, password:String):Promise {
			
			var tokenSignal:Signal = new Signal(Event);
			var tokenSignalError:Signal = new Signal(Event);
			var deferred:Deferred = new Deferred();
			
			// setup request params
			var params:Object = {
				type:		'get',
				url: 		'user/api_token'
			};
			
			// build the request
			var partialRequest:RESTRequest = new RESTRequest(params);
			
			// do the request only to build (so dryrun!)
			partialRequest = RESTClient.doRequest(partialRequest, true);
			
			// modify url to include basic auth,  user:password
			// see https://pinboard.in/api/ under authentication
			var modifiedUrl:String = partialRequest.fullUrl.replace('api', username + ':' + password + '@api');
			
			// setup request params
			var overrideParams:Object = {
				type:			'get',
				urlOverride: 	modifiedUrl,
				signal: 		tokenSignal,
				signalError:	tokenSignalError
			};
			
			// build the request
			var tokenRequest:RESTRequest = new RESTRequest(overrideParams);
			
			// attach listeners to request complete and request fail
			tokenSignal.addOnce(function(event:Event):void { deferred.resolve(event); });
			tokenSignalError.addOnce(function(event:Event):void { deferred.reject(event); });
		
			// do the request only to build (so dryrun!)
			tokenRequest = RESTClient.doRequest(tokenRequest, false);
			
			return deferred.promise;
		}
		
		public static function deleteBookmark(bookmark:BookMark):Signal {
			
			var deleteSignal:Signal = new Signal(Event);
			var argument:String = '&url=';
			
			// setup request params
			var params:Object = {
				type:		'get',
				url: 		'posts/delete',
				data:		argument + bookmark.href,
				signal: 	deleteSignal
			};
			
			// build the request
			var deleteBookmark:RESTRequest = new RESTRequest(params);
			
			// do the request (or dryrun it)
			RESTClient.doRequest(deleteBookmark, true);
			
			return deleteSignal;
		}
		
		public static function GetAllBookmarks(tags:Array = null):void {
			
			// TODO implement deferred here
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
				signal: 	bookmarksReceived
			};
			
			// build the request
			var getBookmarks:RESTRequest = new RESTRequest(params);
			
			// do the request (or dryrun it)
			RESTClient.doRequest(getBookmarks, false);
		}
		
		public static function mapRawBookmarksToBookmarks(rawObjectsArray:Array):Array
		{
			if(!rawObjectsArray || rawObjectsArray.length == 0)
				throw new Error('error: rawObjectsArray is null or contains no items.');
				
			var bookmarkCollection:Array = [];
			
			// add all bookmarks to 'the list'
			rawObjectsArray.forEach(function(bookmark:Object, index:int, array:Array):void {
				var bm:BookMark = new BookMark(bookmark);
				bookmarkCollection.push(bm);
			});
			
			return bookmarkCollection;
		}
	}
}