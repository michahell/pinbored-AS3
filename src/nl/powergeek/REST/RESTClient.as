package nl.powergeek.REST
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	public class RESTClient
	{
		public static var
			REST_BASE_URL:String = '',
			RETURN_TYPE:String = '',
			RETURN_TYPE_PARAMETER:String = '',
			TOKEN_PARAMETER:String = '',
			TOKEN:String = '';

		private static var 
			loader:URLLoader = new URLLoader();
		
		public function RESTClient(RESTBaseUrl:String, tokenParameter:String = '', token:String = '', returnTypeParameter:String = '', returnType:String = '')
		{
			REST_BASE_URL = RESTBaseUrl;
			TOKEN_PARAMETER = tokenParameter;
			TOKEN = token;
			RETURN_TYPE_PARAMETER = returnTypeParameter;
			RETURN_TYPE = returnType;
				
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			
			// attach default listeners
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
		
		public static function doRequest(restrequest:RESTRequest, dryRun:Boolean = false):void {
			
			// attach complete listener to loader
			loader.addEventListener(Event.COMPLETE, function(event:Event):void {
				
				// remove anon listener
				loader.removeEventListener(event.type, arguments.callee);
				
				// dispatch signal belonging to request, if present:
				if(restrequest.signal != null)
					restrequest.signal.dispatch(event);
				
				// call callback, if present:
				if(restrequest.callback != null)
					restrequest.callback(event);
			});
			
			// pass in token or other stuff
			restrequest.tokenParam = TOKEN_PARAMETER;
			restrequest.token = TOKEN;
			
			restrequest.formatParam = RETURN_TYPE_PARAMETER;
			restrequest.format = RETURN_TYPE;
			
			// 'build' request:
			restrequest.build();
			
			// echo request
//			trace('requesting:\n',
//				restrequest.type, '\n',
//				restrequest.payload.url, '\n'
//			);
			
			// send the request
			if(dryRun == false)
				loader.load(restrequest.payload);
			
		}
		
		protected function ioErrorHandler(event:IOErrorEvent):void
		{
			trace('RESTClient ERROR: ' + event.text);
		}
		
		protected function securityErrorHandler(event:SecurityErrorEvent):void
		{
			trace('RESTClient SECURITY ERROR: ' + event.text);
		}
		
		protected function httpStatusHandler(event:HTTPStatusEvent):void
		{
//			trace('RESTClient STATUS: ' + event.status, event.responseURL);
		}
	}
}


