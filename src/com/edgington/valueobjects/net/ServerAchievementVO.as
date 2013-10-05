package com.edgington.valueobjects.net
{
	import com.edgington.util.DateFormatter;
	import com.edgington.util.debug.LOG;
	
	public class ServerAchievementVO
	{
		public var owner:String;
		
		public var updated:Date;
		public var completed:Date;
		
		public var progress:int;
		public var achievementID:int;
		public var credits:int;
		public var reward:String;
		
		public function ServerAchievementVO(rawObject:Object = null)
		{
			for(var key:String in rawObject){
				if(key.charAt(0) != "_" && key != "_id"){
					if(key == "updated" || key == "completed"){
						if(key == "updated"){
							updated = DateFormatter.RFC3339toDate(rawObject[key]);
						}
						else{
							completed = DateFormatter.RFC3339toDate(rawObject[key]);
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
			var serverObject:ServerAchievementVO = new ServerAchievementVO();
			
			for(var key:String in obj){
				if(key.charAt(0) != "_" && key != "_id"){
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