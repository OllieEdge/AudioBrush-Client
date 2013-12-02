package com.edgington.constants
{
	
	import flash.system.Capabilities;

	public class DynamicConstants
	{
		//Populated at start-up
		public static var SCREEN_WIDTH:int = 0;
		public static var SCREEN_HEIGHT:int = 0;
		
		public static var CURRENT_LANGUAGE:String = "en";
		
		public static var CURRENT_GAME_STATE:String;
		
		public static var BUTTON_SCALE:Number = 1;
		public static var BUTTON_MINI_SCALE:Number = 1;
		public static var BUTTON_SPACING:int = 17;
		
		public static var BUTTON_PURCHASE_SCALE:Number;
		
		public static var MESSAGE_SCALE:Number = 1;
		
		public static var SCREEN_MARGIN:int = 100;
		
		public static var DEVICE_TYPE:String;
		public static var DEVICE_NAME:String;
		public static var DEVICE_SCALE:Number;
		
		public static var IS_CONNECTED:Boolean = true;
		
		public static var DISABLE_RELOAD:Boolean = true;
		
		public static var SERVER_TIME_DIFFERENCE:Number = 0;
		
		public static function isMobileOS():Boolean{
			return (getOperatingSystem() == Constants.OS_IOS || getOperatingSystem() == Constants.OS_ANDRIOD);
		}
		
		public static function isIOSPlatform():Boolean{
			return (getOperatingSystem() == Constants.OS_IOS);
		}
		
		private static function getOperatingSystem():String{
			var str:String = String(Capabilities.os);
			if(str == "iPhone OS 6.1 x86_64"){
				return Constants.OS_MAC;
			}
			str = str.substr(0, 1);
			switch(str.toLowerCase()){
				case "w":
					return Constants.OS_WINDOWS;
					break;
				case "m":
					return Constants.OS_MAC;
					break;
				case "l":
					return Constants.OS_ANDRIOD;
					break;
				case "a":
					return Constants.OS_ANDRIOD;
					break;
				case "i":
					return Constants.OS_IOS;
					break;
			}
			return Constants.OS_MAC;
		}
		
		public static function getCurrentServerTime():Date{
			var serverTime:Date = new Date();
			serverTime.setTime(serverTime.time+SERVER_TIME_DIFFERENCE);
			return serverTime;
		}
		
		public static function isDebug():Boolean{
			return new Error().getStackTrace().search(/:[0-9]+\]$/m) > -1;
		}
		
		
		//for imports
		theme_normal_thumb;
		theme_ice_thumb;
		theme_fire_thumb;
	}
}