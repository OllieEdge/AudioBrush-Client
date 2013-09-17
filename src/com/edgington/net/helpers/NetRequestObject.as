package com.edgington.net.helpers
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;

	public class NetRequestObject
	{
		
		public var urlRequest:URLRequest;
		public var urlLoader:URLLoader;
		public var urlVariables:URLVariables;
		public var responseHandler:NetResponceHandler;
		
		public function NetRequestObject(responseHandler, urlRequest:URLRequest, urlLoader:URLLoader, urlVariables:URLVariables = null)
		{
			this.urlRequest = urlRequest;
			this.urlLoader = urlLoader;
			this.urlVariables = urlVariables;
			this.responseHandler = responseHandler;
		}
	}
}