package com.edgington.net
{
	import com.edgington.net.helpers.NetRequestObject;
	import com.edgington.net.helpers.NetResponceHandler;
	import com.edgington.net.helpers.NetResponceTypeIdentifier;
	import com.edgington.util.debug.LOG;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.Capabilities;

	public class NetResponder
	{
		private static var INSTANCE:NetResponder;
		
		private var NetRequestObjects:Vector.<NetRequestObject>;
		
		public function NetResponder()
		{
			NetRequestObjects = new Vector.<NetRequestObject>;
		}
		
		/**
		 * Sends a call to the supplied URL.
		 * 
		 * urlString - should contain the FULL url to the requested server.
		 * method - should contain the method to use when calling the REST API (for example URLRequestMethod.POST)
		 * urlVariables - is the call requires variables a URLVariables object should be parsed, but this is not compulsory
		 */
		public function newCall(responseHandler:NetResponceHandler, urlString:String, method:String, urlVariables:URLVariables = null):void{
			var request:URLRequest = new URLRequest(urlString);
			LOG.server("New "+method+" Request: " + urlString);
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			request.method = method;
			
			if(urlVariables != null){
				request.data = urlVariables;
			}
			
			var netRequestObject:NetRequestObject = new NetRequestObject(responseHandler, request, loader, urlVariables);
			NetRequestObjects.push(netRequestObject);
			
			loader.addEventListener(Event.COMPLETE, onServerResponceComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR , onSecurityError);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
			
			loader.load(request);
		}
		
		/**
		 * On successful response from the server
		 */
		private function onServerResponceComplete(e:Event):void{
			var responceData:Object = JSON.parse(e.target.data as String);
			var responceType:String = NetResponceTypeIdentifier.GET_RESPONCE_TYPE(responceData);
			
			LOG.server("Responce Type: " + responceType);
			if(Capabilities.isDebugger){
				LOG.server("JSON: " + e.target.data);
			}
			
			for(var i:int = 0; i < NetRequestObjects.length; i++){
				if(e.currentTarget == NetRequestObjects[i].urlLoader){
					NetRequestObjects[i].responseHandler.succesful(responceData);
					NetRequestObjects.splice(i, 1);
					break;
				}
			}
			
		}
		
		private function onIOError(e:IOErrorEvent):void{
			LOG.server("IO Error: " + e.toString());
			
			for(var i:int = 0; i < NetRequestObjects.length; i++){
				if(e.currentTarget == NetRequestObjects[i].urlLoader){
					NetRequestObjects[i].responseHandler.failed();
					NetRequestObjects.splice(i, 1);
					break;
				}
			}
		}
		
		private function onSecurityError(e:SecurityErrorEvent):void{
			LOG.server("Security Error: " + e.toString());
			
			for(var i:int = 0; i < NetRequestObjects.length; i++){
				if(e.currentTarget == NetRequestObjects[i].urlLoader){
					NetRequestObjects[i].responseHandler.failed();
					NetRequestObjects.splice(i, 1);
					break;
				}
			}
		}
		
		private function onHTTPStatus(e:HTTPStatusEvent):void{
			LOG.server("HTTP Response Code: " + e.status);
		}
		
		public static function getInstance():NetResponder{
			if(INSTANCE == null){
				INSTANCE = new NetResponder();
			}
			return INSTANCE;
		}
	}
}