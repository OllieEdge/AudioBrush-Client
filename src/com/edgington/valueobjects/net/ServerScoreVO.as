package com.edgington.valueobjects.net
{
	import com.edgington.util.debug.LOG;
	
	public class ServerScoreVO
	{
		private var created:String;
		
		public var userId:ServerUserVO;
		public var trackId:ServerTrackVO;
		public var score:Number;
		public var trackkey:String;
		public var starrating:int;
		
		public var userIdSTRING:String;
		public var trackIdSTRING:String;
		
		//This value is populated after obtaining from the server
		public var rank:int;
		
		//This value is populated after obtaining from the server
		//This WILL ONLY be returned when saving a new score
		public var xpRewarded:uint;
		
		public function ServerScoreVO(rawObject:Object = null)
		{
			for(var key:String in rawObject){
				if(key.charAt(0) != "_"){
					if(rawObject[key] is Array){
						if(key == "userId" && ServerUserVO.checkObject(rawObject[key][0])){
							userId = new ServerUserVO(rawObject[key][0]);
						}	
						else if(key == "trackId" && ServerTrackVO.checkObject(rawObject[key][0])){
							trackId = new ServerTrackVO(rawObject[key][0]);
						}
					}
					else{
						try{
							this[key] = rawObject[key];
						}
						catch(e:Error){
							if(key == "userId"){
								userIdSTRING = rawObject[key];
							}
							else if(key == "trackId"){
								trackIdSTRING = rawObject[key];
							}
							else{
								LOG.fatal("There was a type failure when attempting to add a key to the scores object");
							}
						}
					}
				}
			}
		}
		
		public static function checkObject(obj:Object):Boolean{
			var isUserObject:Boolean = true;
			var serverObject:ServerScoreVO = new ServerScoreVO();
			
			for(var key:String in obj){
				if(key != "created" && key.charAt(0) != "_"){
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