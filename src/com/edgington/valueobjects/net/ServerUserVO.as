package com.edgington.valueobjects.net
{
	import com.edgington.util.DateFormatter;

	public class ServerUserVO
	{
		public var _id:String;
		
		private var updated:String;
		private var created:String;
		
		public var last_login:Date;
		public var last_bonus:Date;
		
		public var role:String;
		public var username:String;
		public var fb_id:String;
		public var credits:int;
		public var unlimited:Boolean;
		public var tracks:Array;
		public var airship_token:String;
		
		public var xp:uint;
		
		public function ServerUserVO(rawObject:Object = null)
		{
			for(var key:String in rawObject){
				if(key.charAt(0) != "_" || key == "_id"){
					if(key == "last_login" || key == "last_bonus"){
						if(key == "last_login"){
							if(String(rawObject[key]).charAt(String(rawObject[key]).length-1) == "Z"){
								last_login = DateFormatter.RFC3339toDate(rawObject[key]);
							}
						}
						else{
							if(rawObject[key] != null){
								if(String(rawObject[key]).charAt(String(rawObject[key]).length-1) == "Z"){
									last_bonus = DateFormatter.RFC3339toDate(rawObject[key]);
								}
							}
						}
					}
					else{
						this[key] = rawObject[key];
					}
				}
			}
		}
		
		public static function checkObject(obj:Object):Boolean{
			var isUserObject:Boolean = true;
			var serverObject:ServerUserVO = new ServerUserVO();
			
			for(var key:String in obj){
				if(key != "created" && key != "updated" && key.charAt(0) != "_" || key == "_id"){
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