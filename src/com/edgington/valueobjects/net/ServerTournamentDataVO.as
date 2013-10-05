package com.edgington.valueobjects.net
{
	import com.edgington.util.DateFormatter;
	import com.edgington.util.debug.LOG;
	
	public class ServerTournamentDataVO
	{
		private var last_update:String;
		
		public var tournamentID:Number;
		public var activeDate:Date;
		public var endDate:Date;
		public var cost:Number;
		public var prizes:String;
		
		public var track:String;
		public var artist:String;
		public var artworkURL:String;
		public var trackURL:String;
		public var beatsFile:String;
		public var beatsDetectedFile:String;
		public var starBeatsFile:String;
		public var fluxFile:String;
		public var sectionsFile:String;
		public var starSectionsFile:String;
		
		public function ServerTournamentDataVO(rawObject:Object = null)
		{
			for(var key:String in rawObject){
				if(key.charAt(0) != "_"){
					if(key == "activeDate" || key == "endDate"){
						if(key == "activeDate"){
							activeDate = DateFormatter.RFC3339toDate(rawObject[key]);;
						}
						else{
							endDate = DateFormatter.RFC3339toDate(rawObject[key]);;
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
			var serverObject:ServerTournamentDataVO = new ServerTournamentDataVO();
			
			for(var key:String in obj){
				if(key != "last_update" && key.charAt(0) != "_"){
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