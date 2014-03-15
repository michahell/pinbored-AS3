package REST
{
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import org.osflash.signals.Signal;

	public class RESTRequest
	{
		public var
			type:String = 'get',
			url:String = '',
			fullUrl:String = '',
			tokenParam:String = '',
			token:String = '',
			formatParam:String = '',
			format:String = '',
			data:String = '',
			payload:URLRequest = null,
			signal:Signal = null,
			callback:Function = null;
			
		public function RESTRequest(params:Object)
		{
			// REQUIRED
			type = params.type;
			url = params.url;
			
			// optional request signal
			if(params.signal && params.signal != null)
				signal = params.signal;
			
			// optional request callback
			if(params.callback && params.callback != null)
				callback = params.callback;
			
			// optional url variables
			if(params.data && params.data != null)
				data = params.data;
		}
		
		public function build():URLRequest {
			
			// build the request
			fullUrl = RESTClient.REST_BASE_URL + url + tokenParam + token + formatParam + format + data;
			payload = new URLRequest( fullUrl );
			
			// set the request type
			switch(type) {
				case "post":
					payload.method = URLRequestMethod.POST;
					break;
				
				case "get":
					payload.method = URLRequestMethod.GET;
					break;
				
				case "put":
					payload.method = URLRequestMethod.PUT;
					break;
				
				case "delete":
					payload.method = URLRequestMethod.DELETE;
					break;
			}
			
			trace('payload url: ' + payload.url);
			
			// return the request
			return payload;
		}
		
	}
}