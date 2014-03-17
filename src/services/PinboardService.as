package services
{
	import nl.powergeek.REST.RESTClient;
	import nl.powergeek.REST.RESTRequest;
	
	import flash.events.Event;
	import flash.net.URLVariables;
	
	import org.osflash.signals.Signal;

	public class PinboardService
	{
		public static var
		allBookmarksReceived:Signal = new Signal(Event);
		
		public function PinboardService() { }
		
		public static function GetAllBookmarks(tags:Array = null):void {
			
			var variables:URLVariables = new URLVariables();
			
			tags.forEach(function(tag:String, index:int, array:Array):void {
//				trace('adding tag to variables: ' + tag);
				variables.tag = tag;
			});
			
//			trace('urlencoded vars: ' + variables.toString());
			
			var params:Object = {
				type:		'get',
				url: 		'posts/all',
				data:		'&' + variables.toString(),
				signal: 	allBookmarksReceived
			};
			
			// build the request
			var getBookmarks:RESTRequest = new RESTRequest(params);
			
			// do the request (dryrun)
			RESTClient.doRequest(getBookmarks, false);
			
		}
		
	}
}