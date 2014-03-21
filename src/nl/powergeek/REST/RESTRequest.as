package nl.powergeek.REST
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
			urlOverride:String = '',
			fullUrl:String = '',
			tokenParam:String = '',
			token:String = '',
			formatParam:String = '',
			format:String = '',
			data:String = '',
			payload:URLRequest = null,
			signal:Signal = null,
			callback:Function = null,
			modifyFactory:Function = defaultModifyFactory;
			
			
		public function RESTRequest(params:Object)
		{
			// REQUIRED
			type = params.type;
			
			// EITHER
			if(params.url && params.url.length > 0) {
				url = params.url;
			}
			
			// OR
			if(params.urlOverride && params.urlOverride.length > 0) {
				urlOverride = params.urlOverride;
			}
			
			if(!params.url && !params.urlOverride)
				throw new Error('Either the (local) url property or the \'urlOverride\' property has to be set!');
			
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
			if(url)
				fullUrl = RESTClient.REST_BASE_URL + url + tokenParam + token + formatParam + format + data;
			else if(urlOverride)
				fullUrl = urlOverride
					
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
			
			//trace('payload url: ' + payload.url);
			
			// return the request
			return payload;
		}
		
		public function defaultModifyFactory(urlRequest:URLRequest):URLRequest {
			return payload;
		}
		
	}
}