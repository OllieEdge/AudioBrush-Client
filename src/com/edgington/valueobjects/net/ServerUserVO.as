package com.edgington.valueobjects.net
{
	import com.edgington.util.debug.LOG;

	public class ServerUserVO
	{
		private var updated:String;
		private var created:String;
		
		public var role:String;
		public var username:String;
		public var fb_id:String;
		public var credits:int;
		public var unlimited:Boolean;
		public var tracks:Array;
		
		public function ServerUserVO(rawObject:Object = null)
		{
			for(var key:String in rawObject){
				if(key.charAt(0) != "_"){
					this[key] = rawObject[key];
				}
			}
		}
		
		public static function checkObject(obj:Object):Boolean{
			var isUserObject:Boolean = true;
			var serverObject:ServerUserVO = new ServerUserVO();
			
			for(var key:String in obj){
				if(key != "created" && key != "updated" && key.charAt(0) != "_"){
					//We must filter out the mongoDB defaults as we do not use these (they start with a _ )
					if(!serverObject.hasOwnProperty(key)){
						LOG.debug("Key that doesn't exist in client but is in the server responce is: " + key);
						return false;
					}
				}
			}
			
			return isUserObject;
		}
	}
}