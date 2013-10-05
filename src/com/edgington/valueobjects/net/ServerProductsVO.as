package com.edgington.valueobjects.net
{
	import com.edgington.util.debug.LOG;

	public class ServerProductsVO
	{
		private var updated:String;
		private var created:String;
		
		public var fb_id:String;
		public var quantity:int;
		public var productID:String;
		
		public function ServerProductsVO(rawObject:Object = null)
		{
			for(var key:String in rawObject){
				if(key.charAt(0) != "_"){
					this[key] = rawObject[key];
				}
			}
		}
		
		public static function checkObject(obj:Object):Boolean{
			var isUserObject:Boolean = true;
			var serverObject:ServerProductsVO = new ServerProductsVO();
			
			for(var key:String in obj){
				if(key != "created" && key != "updated" && key.charAt(0) != "_"){
					//We must filter out the mongoDB defaults as we do not use these (they start with a _ )
					if(!serverObject.hasOwnProperty(key)){
						//LOG.debug("Key that doesn't exist in client but is in the server responce is: " + key);
						return false;
					}
				}
			}
			
			return isUserObject;
		}
	}
}