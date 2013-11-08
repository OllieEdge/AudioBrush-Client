package com.edgington.view.model
{
	import com.edgington.constants.Constants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.types.DeviceTypes;
	import com.edgington.util.debug.LOG;
	
	import flash.system.Capabilities;

	public class ScreenManager
	{
		public function ScreenManager()
		{
			
		}
		
		public function setupDynamicScaling():void{
			getDevice();
			DynamicConstants.BUTTON_MINI_SCALE = DynamicConstants.MESSAGE_SCALE*0.68;
		}
		
		public static function getDevice():String {
			var info:Array = Capabilities.os.split(" ");
			
			calculateDeviceDependantResolutions();
			
			// ordered from specific (iPhone1,1) to general (iPhone)
				switch(DynamicConstants.SCREEN_WIDTH){
					case 1136://iPhone 5 - iPhone 5S/5C
						DynamicConstants.DEVICE_TYPE = DeviceTypes.IPHONE;
						DynamicConstants.DEVICE_NAME = Constants.IPHONE_5PLUS;
						
						DynamicConstants.DEVICE_SCALE = 1;
						
						DynamicConstants.MESSAGE_SCALE = 1.5;
						
						DynamicConstants.BUTTON_SCALE = 2;
						
						DynamicConstants.BUTTON_SPACING = 17;
						
						DynamicConstants.SCREEN_MARGIN = 50;
						
						DynamicConstants.BUTTON_PURCHASE_SCALE = 1.2;
						
						return Constants.IPHONE_5PLUS;
						break;
					case 1024://iPad 1 - iPad 2 - iPad Mini
						DynamicConstants.DEVICE_TYPE = DeviceTypes.IPAD;
						DynamicConstants.DEVICE_NAME = Constants.IPAD_2;
						
						DynamicConstants.DEVICE_SCALE = 1;
						
						DynamicConstants.MESSAGE_SCALE = 1;
						
						DynamicConstants.BUTTON_SCALE = 1;
						
						DynamicConstants.BUTTON_SPACING = 17;
						
						DynamicConstants.SCREEN_MARGIN = 100;
						
						DynamicConstants.BUTTON_PURCHASE_SCALE = 1;
						
						return Constants.IPAD_2;
						break;
					case 960://iPhone 4 - iPhone 4S
						DynamicConstants.DEVICE_TYPE = DeviceTypes.IPHONE;
						DynamicConstants.DEVICE_NAME = Constants.IPHONE_4;
						
						DynamicConstants.DEVICE_SCALE = 1;
						
						DynamicConstants.MESSAGE_SCALE = 1.3;
						
						DynamicConstants.BUTTON_SCALE = 2;
						
						DynamicConstants.BUTTON_SPACING = 17;
						
						DynamicConstants.SCREEN_MARGIN = 50;
						
						DynamicConstants.BUTTON_PURCHASE_SCALE = 1.2;
						
						return Constants.IPHONE_4S;
						break;
					case 480://iPhone 3GS - not compatible on iOS 7
						DynamicConstants.DEVICE_TYPE = DeviceTypes.IPHONE;
						DynamicConstants.DEVICE_NAME = Constants.IPHONE_3GS;
						
						DynamicConstants.DEVICE_SCALE = 0.5;
						
						DynamicConstants.MESSAGE_SCALE = 0.6;
						
						DynamicConstants.BUTTON_SCALE = 1;
						
						DynamicConstants.BUTTON_SPACING = 8;
						
						DynamicConstants.SCREEN_MARGIN = 25;
						
						DynamicConstants.BUTTON_PURCHASE_SCALE = 0.6;
						
						return Constants.IPHONE_3GS;
						break;
					case 2048://iPad 3/4
						DynamicConstants.DEVICE_TYPE = DeviceTypes.IPAD;
						DynamicConstants.DEVICE_NAME = Constants.IPAD_4PLUS;
						
						DynamicConstants.DEVICE_SCALE = 2;
						
						DynamicConstants.MESSAGE_SCALE = 2;
						
						DynamicConstants.BUTTON_SCALE = 2;
						
						DynamicConstants.BUTTON_SPACING = 34;
						
						DynamicConstants.SCREEN_MARGIN = 200;
						
						DynamicConstants.BUTTON_PURCHASE_SCALE = 2;
						
						return Constants.IPAD_4PLUS;
						break;
					default:
						calculateDeviceDependantResolutions();
						break;
				}
//			else{
//				for each (var device:String in Constants.IOS_DEVICES) {	
//					if (info[3].indexOf(device) != -1) {
//						return device;
//					}
//				}
//			}
				
			LOG.debug("DEVICE RECOGNISED: " + DynamicConstants.DEVICE_NAME);
				
			if(DynamicConstants.SCREEN_WIDTH > 1500){
				return Constants.UNKNOWN_LARGE;
			}
			else{
				return Constants.UNKNOWN_SMALL;
			}
			return Constants.UNKNOWN;
		}
		
		private static function calculateDeviceDependantResolutions():void{
				if(DynamicConstants.SCREEN_WIDTH >= 1920){
					DynamicConstants.DEVICE_TYPE = DeviceTypes.IPAD;
					DynamicConstants.DEVICE_NAME = Constants.ANDROID_XXL;
					
					DynamicConstants.DEVICE_SCALE = 2;
					
					DynamicConstants.MESSAGE_SCALE = 2;
					
					DynamicConstants.BUTTON_SCALE = 2.2;
					
					DynamicConstants.BUTTON_SPACING = 40;
					
					DynamicConstants.SCREEN_MARGIN = 200;
					
					DynamicConstants.BUTTON_PURCHASE_SCALE = 2;
				}
				else if(DynamicConstants.SCREEN_WIDTH >= 1280){
					DynamicConstants.DEVICE_TYPE = DeviceTypes.IPAD;
					DynamicConstants.DEVICE_NAME = Constants.ANDROID_L;
					
					DynamicConstants.DEVICE_SCALE = 1;
					
					DynamicConstants.MESSAGE_SCALE = 1.3;
					
					DynamicConstants.BUTTON_SCALE = 1.3;
					
					DynamicConstants.BUTTON_SPACING = 20;
					
					DynamicConstants.SCREEN_MARGIN = 100;
					
					DynamicConstants.BUTTON_PURCHASE_SCALE = 1.1;
					
				}
				else{// if(DynamicConstants.SCREEN_WIDTH >= 1024){
					DynamicConstants.DEVICE_TYPE = DeviceTypes.IPAD;
					DynamicConstants.DEVICE_NAME = Constants.ANDROID_IPAD_2_SIZE;
					
					DynamicConstants.DEVICE_SCALE = 1;
					
					DynamicConstants.MESSAGE_SCALE = 1;
					
					DynamicConstants.BUTTON_SCALE = 1;
					
					DynamicConstants.BUTTON_SPACING = 17;
					
					DynamicConstants.SCREEN_MARGIN = 100;
					
					DynamicConstants.BUTTON_PURCHASE_SCALE = 1;
				}
			
			LOG.debug("SCREEN RES X: " + Capabilities.screenResolutionX);
			LOG.debug("SCREEN RES Y: " + Capabilities.screenResolutionY);
			LOG.debug("SCREEN DPI: " + Capabilities.screenDPI);
		}
	}
}