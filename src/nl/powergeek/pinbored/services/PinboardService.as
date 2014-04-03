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
		
		public static function getUserToken(username:String, password:String, dryrun:Boolean = false):Promise {
			
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
			
			// modify url to include basic auth,  user:password. See https://pinboard.in/api/ under authentication
			var modifiedUrl:String = partialRequest.fullUrl.replace('api', username + ':' + password + '@api');
			
			// setup request params
			var overrideParams:Object = {
				type:			'get',
				urlOverride: 	modifiedUrl
			};
			
			// do the real 'login' token request
			RESTClient.doPromiseRequest(overrideParams, dryrun, deferred);
			
			return deferred.promise;
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
				type:			'get',
				url: 			'posts/all',
				data:			argument,
				signalSuccess: 	bookmarksReceived
			};
			
			// build the request
			var getBookmarks:RESTRequest = new RESTRequest(params);
			
			// do the request (or dryrun it)
			RESTClient.doRequest(getBookmarks, false);
		}
		
		public static function deleteBookmark(bookmark:BookMark, dryrun:Boolean = false):Promise {
			
			// setup deferred
			var deferred:Deferred = new Deferred();
			
			// data
			var data:String = '&url=' + bookmark.href;
			
			// setup request params
			var params:Object = {
				type:			'get',
				url: 			'posts/delete',
				data:			data
			};
			
			// do request
			RESTClient.doPromiseRequest(params, dryrun, deferred);
			
			// return promise
			return deferred.promise;
		}
		
		public static function updateBookmark(bookmark:BookMark, dryrun:Boolean = false):Promise
		{
			var deferred:Deferred = new Deferred();
			
			/*
			url	url	the URL of the item
			description	title	Title of the item. This field is unfortunately named 'description' for backwards compatibility with the delicious API
			extended	text	Description of the item. Called 'extended' for backwards compatibility with delicious API
			tags	tag	List of up to 100 tags
			dt	datetime	creation time for this bookmark. Defaults to current time. Datestamps more than 10 minutes ahead of server time will be reset to current server time
			replace	yes/no	Replace any existing bookmark with this URL. Default is yes. If set to no, will throw an error if bookmark exists
			shared	yes/no	Make bookmark public. Default is "yes" unless user has enabled the "save all bookmarks as private" user setting, in which case default is "no"
			toread	yes/no	Marks the bookmark as unread. Default is "no"
			*/
			
			// data
			var data:String = 
				'&url=' + bookmark.href_new + 
				'&description=' + bookmark.description_new +
				'&extended=' + bookmark.extended_new + 
				'&tags=' + bookmark.tags_new.toString() +
				'&replace=yes' + 
				'&shared=' + bookmark.shared +
				'&toread=' + bookmark.toread;
			
			// setup request params
			var params:Object = {
				type:			'get',
				url: 			'posts/add',
				data:			data
			};
			
			// do request
			RESTClient.doPromiseRequest(params, dryrun, deferred);
			
			return deferred.promise;
		}
		
		public static function getAllTags(dryrun:Boolean = false):Promise
		{
			var success:Signal = new Signal(Event);
			var error:Signal = new Signal(Event);
			var deferred:Deferred = new Deferred();
			
			// setup request params
			var params:Object = {
				type:			'get',
				url:			'tags/get',
				signalSuccess: 	success,
				signalError:	error
			};
			
			// build the request
			var request:RESTRequest = new RESTRequest(params);
			
			// attach listeners to request complete and request fail
			success.addOnce(function(event:Event):void { deferred.resolve(event); });
			error.addOnce(function(event:Event):void { deferred.reject(event); });
			
			// do the request only to build (so dryrun!)
			request = RESTClient.doRequest(request, dryrun);
			
			return deferred.promise;
		}
		
	}
}