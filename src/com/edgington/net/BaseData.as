package com.edgington.net
{
	import com.edgington.net.helpers.NetResponceHandler;
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	public class BaseData
	{
		
		private var objectSingular:String;
		private var objectPlural:String;
		
		private var URLRequests:Vector.<URLRequest>;
		private var URLLoaders:Vector.<URLLoader>;
		private var URLVariablesArr:Vector.<URLVariables>;
		
		public function BaseData(objectSingular:String, objectPlural:String)
		{
			this.objectSingular = objectSingular;
			this.objectPlural = objectPlural;
			
			URLRequests = new Vector.<URLRequest>;
		}
		
		/**
		 * Public method to GET
		 * 
		 * If there is a plural for this resource (eg. user > users) in the Server API parsing true will default to get all objects.
		 */
		public function GET(responseHandler:NetResponceHandler, getAll:Boolean = false, singularExtension:String = ""):void{
			var URL:String = NetManager.getURL();
			if(getAll){
				URL += "/" + objectPlural;
			}
			else{
				URL += "/" + objectSingular + "/" + singularExtension;
			}
			NetResponder.getInstance().newCall(responseHandler, URL, URLRequestMethod.GET);
		}
		
		/**
		 * Public method to POST
		 * 
		 * The URL extension must contain the the directory to the call (eg. a user would be /user/userID)
		 * If there are any additional variables to add to that they can be populated in the object
		 */
		public function POST(responseHandler:NetResponceHandler, singularExtension, urlVariables:Object):void{
			var URL:String = NetManager.getURL();
			var VARIBALES:URLVariables = new URLVariables();
			
			//Converts a standard object into a URLVariables Object
			for(var key:String in urlVariables){
				VARIBALES[key] = urlVariables[key];
			}
			
			URL += "/" + objectSingular + "/" + singularExtension;
			
			NetResponder.getInstance().newCall(responseHandler, URL, URLRequestMethod.POST, VARIBALES);
		}
		
		/**
		 * Public method to PUT
		 * 
		 * The URL extension must contain the the directory to the call (eg. a user would be /user/userID)
		 * If there are any additional variables to add to that they can be populated in the object
		 */
		public function PUT(responseHandler:NetResponceHandler, singularExtension:String, urlVariables:Object):void{
			var URL:String = NetManager.getURL();
			var VARIBALES:URLVariables = new URLVariables();
			
			if(urlVariables != null){
				//Converts a standard object into a URLVariables Object
				for(var key:String in urlVariables){
					VARIBALES[key] = urlVariables[key];
				}
			}
			else{
				VARIBALES = null;
			}
			
			URL += "/" + objectSingular + "/" + singularExtension;
			
			NetResponder.getInstance().newCall(responseHandler, URL, URLRequestMethod.PUT, VARIBALES);
		}
	}
}