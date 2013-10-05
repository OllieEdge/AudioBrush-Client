package com.edgington.valueobjects.net
{
	import com.edgington.util.DateFormatter;
	import com.edgington.util.debug.LOG;
	
	public class ServerTrackVO
	{
		public var last_update:Date;
		
		public var trackname:String;
		public var artist:String;
		public var trackkey:String;
		public var plays:Number;
		public var difficulty:int;
		
		public function ServerTrackVO(rawObject:Object = null)
		{
			for(var key:String in rawObject){
				if(key.charAt(0) != "_"){
					if(key == "last_update"){
							last_update = DateFormatter.RFC3339toDate(rawObject[key]);
					}
					else{
						this[key] = rawObject[key];
					}
				}
			}
		}
		
		public static function checkObject(obj:Object):Boolean{
			var isUserObject:Boolean = true;
			var serverObject:ServerTrackVO = new ServerTrackVO();
			
			for(var key:String in obj){
				if(key.charAt(0) != "_"){
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