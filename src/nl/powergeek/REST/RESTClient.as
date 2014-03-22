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
			
		public function RESTClient() { }
		
		public static function initialize(RESTBaseUrl:String, tokenParameter:String = '', token:String = '', returnTypeParameter:String = '', returnType:String = ''):void
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
		
		public static function setToken(tokenParameter:String, token:String):void {
			TOKEN_PARAMETER = tokenParameter;
			TOKEN = token;
		}
		
		public static function setReturnType(returnTypeParameter:String, returnType:String):void {
			RETURN_TYPE_PARAMETER = returnTypeParameter;
			RETURN_TYPE = returnType;
		}
		
		public static function getBaseUrl():String {
			return REST_BASE_URL + TOKEN_PARAMETER + TOKEN + RETURN_TYPE_PARAMETER + RETURN_TYPE;
		}
		
		public static function doRequest(restrequest:RESTRequest, dryRun:Boolean = false):RESTRequest {
			
			var errorHandler:Function = function(event:Event):void {
				
				// remove anon listener
				loader.removeEventListener(event.type, arguments.callee);
				
				// dispatch error signal if present
				if(restrequest.signalError != null)
					restrequest.signalError.dispatch(event);
				
				// call error callback if present
				if(restrequest.callbackError != null)
					restrequest.callbackError(event);
			};
				
			var successHandler:Function = function(event:Event):void {
				
				// remove anon listener
				loader.removeEventListener(event.type, arguments.callee);
				
				// dispatch signal if present
				if(restrequest.signal != null)
					restrequest.signal.dispatch(event);
				
				// call callback if present
				if(restrequest.callback != null)
					restrequest.callback(event);
			};
				
			// attach complete listener to loader
			loader.addEventListener(Event.COMPLETE, successHandler);
			
			// attach listeners on security event
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			
			// attach listeners on security event
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
		
			// pass in token or other stuff
			restrequest.tokenParam = TOKEN_PARAMETER;
			restrequest.token = TOKEN;
			
			restrequest.formatParam = RETURN_TYPE_PARAMETER;
			restrequest.format = RETURN_TYPE;
			
			// 'build' request:
			restrequest.build();
			
			// send the request or dry run it
			if(dryRun == false) {
				loader.load(restrequest.payload);
				// echo request
				trace('requested :\n',
					restrequest.type, '\n',
					restrequest.payload.url, '\n'
				);
			} else {
				// echo request
				trace('requesting DRY-RUN :\n',
					restrequest.type, '\n',
					restrequest.payload.url, '\n'
				);
			}
			
			return restrequest;
		}
		
		public static function doDirectRequest(urlRequest:URLRequest):void {
			
		}
		
		protected static function ioErrorHandler(event:IOErrorEvent):void
		{
			trace('RESTClient ERROR: ' + event.text);
		}
		
		protected static function securityErrorHandler(event:SecurityErrorEvent):void
		{
			trace('RESTClient SECURITY ERROR: ' + event.text);
		}
		
		protected static function httpStatusHandler(event:HTTPStatusEvent):void
		{
//			trace('RESTClient STATUS: ' + event.status, event.responseURL);
		}
	}
}


