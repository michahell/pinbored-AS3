package 
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;

	public class UrlChecker
	{
		private var
			loader:URLLoader,
			request:URLRequest,
			callback:Function,
			status:int;
		
		public function UrlChecker() { 
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.addEventListener(Event.COMPLETE, completeHandler);
		}
		
		public function check(url:String, callback:Function):void {
			this.callback = callback;
			request = new URLRequest(url);
			request.method = URLRequestMethod.GET;
			request.followRedirects = true;
			loader.load(request);
		}
		
		protected function completeHandler(event:Event):void
		{
			trace('request completed successfully.');
			if(status == 200)
				this.callback(false);
		}
		
		protected function ioErrorHandler(event:IOErrorEvent):void
		{
			trace('request failed: ' + event.text);
			this.callback(true);
		}
		
		protected function securityErrorHandler(event:SecurityErrorEvent):void
		{
			trace('request failed: ' + event.text);
			this.callback(true);
		}
		
		protected function httpStatusHandler(event:HTTPStatusEvent):void
		{
			//trace('request status: ' + event.status, event.responseURL);
			status = event.status;
		}
	}
}