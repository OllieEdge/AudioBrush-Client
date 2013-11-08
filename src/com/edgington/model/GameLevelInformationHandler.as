package com.edgington.model
{
	public class GameLevelInformationHandler
	{
		
		private static var INSTANCE:GameLevelInformationHandler;
		
		public var levelBeforeGame:int;
		public var levelAfterGame:int;
		public var xpBeforeGame:int;
		public var xpAfterGame:int;
		
		public function GameLevelInformationHandler()
		{
		}
		
		public static function get isReady():Boolean{
			return (INSTANCE.xpAfterGame != 0);
		}
		
		public static function checkIfAvailable():Boolean{
			return (INSTANCE != null);
		}
		
		public static function deleteInstance():void{
			INSTANCE = null;
		}
		
		public static function getInstance():GameLevelInformationHandler{
			if(INSTANCE == null){
				INSTANCE = new GameLevelInformationHandler();
			}
			return INSTANCE;
		}
	}
}