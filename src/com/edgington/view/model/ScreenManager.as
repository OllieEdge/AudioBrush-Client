package com.edgington.view.model
{
	import com.edgington.constants.Constants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.types.DeviceTypes;
	
	import flash.system.Capabilities;

	public class ScreenManager
	{
		public function ScreenManager()
		{
			
		}
		
		public function setupDynamicScaling():void{
			DynamicConstants.BUTTON_SCALE = setButtonScale();
			DynamicConstants.SCREEN_MARGIN = setScreenMargin();
			DynamicConstants.MESSAGE_SCALE = setMessageScale();
			DynamicConstants.BUTTON_PURCHASE_SCALE = setPurchaseButtonScale();
			DynamicConstants.BUTTON_MINI_SCALE = DynamicConstants.MESSAGE_SCALE*0.68;
			DynamicConstants.DEVICE_SCALE = setDeviceScale();
		}
			
			
		
		public static function getDevice():String {
			var info:Array = Capabilities.os.split(" ");
			
			// ordered from specific (iPhone1,1) to general (iPhone)
				switch(DynamicConstants.SCREEN_WIDTH){
					case 1136:
						DynamicConstants.DEVICE_TYPE = DeviceTypes.IPHONE;
						DynamicConstants.DEVICE_NAME = Constants.IPHONE_5PLUS;
						return Constants.IPHONE_5PLUS;
						break;
					case 1024:
						DynamicConstants.DEVICE_TYPE = DeviceTypes.IPAD;
						DynamicConstants.DEVICE_NAME = Constants.IPAD_2;
						return Constants.IPAD_2;
						break;
					case 960:
						DynamicConstants.DEVICE_TYPE = DeviceTypes.IPHONE;
						DynamicConstants.DEVICE_NAME = Constants.IPHONE_4;
						return Constants.IPHONE_4S;
						break;
					case 480:
						DynamicConstants.DEVICE_TYPE = DeviceTypes.IPHONE;
						DynamicConstants.DEVICE_NAME = Constants.IPHONE_3GS;
						return Constants.IPHONE_3GS;
						break;
					case 2048:
						DynamicConstants.DEVICE_TYPE = DeviceTypes.IPAD;
						DynamicConstants.DEVICE_NAME = Constants.IPAD_4PLUS;
						return Constants.IPAD_4PLUS;
						break;
				}
//			else{
//				for each (var device:String in Constants.IOS_DEVICES) {	
//					if (info[3].indexOf(device) != -1) {
//						return device;
//					}
//				}
//			}
			if(DynamicConstants.SCREEN_WIDTH > 1500){
				return Constants.UNKNOWN_LARGE;
			}
			else{
				return Constants.UNKNOWN_SMALL;
			}
			return Constants.UNKNOWN;
		}
		
		public static function setDeviceScale():Number{
			switch(getDevice()){
				case Constants.IPHONE_5PLUS:
					return 1;
					break;
				case Constants.IPHONE_4S:
					return 1;
					break;
				case Constants.IPHONE_3GS:
					return 0.5;
					break;
				case Constants.IPAD_2:
					return 1;
					break;
				case Constants.IPAD_3:
					return 2;
					break;
				case Constants.IPAD_4PLUS:
					return 2;
					break;
				default:
					if(getDevice() == Constants.UNKNOWN_LARGE){
						DynamicConstants.BUTTON_SPACING *= 2;
						return 2;
					}
					else{
						return 1;
					}
					break;
			}
			return 1;
		}
		
		public static function setMessageScale():Number{
			//if(DynamicConstants.isMobileOS()){
				switch(getDevice()){
					case Constants.IPHONE_5PLUS:
						DynamicConstants.DEVICE_TYPE = DeviceTypes.IPHONE;
						return 1.5;
						break;
					case Constants.IPAD_3:
						DynamicConstants.DEVICE_TYPE = DeviceTypes.IPAD;
						return 2;
						break;
					case Constants.IPAD_4PLUS:
						DynamicConstants.DEVICE_TYPE = DeviceTypes.IPAD;
						return 2;
						break;
					case Constants.IPHONE_4S:
						DynamicConstants.DEVICE_TYPE = DeviceTypes.IPHONE;
						return 1.3;
						break;
					case Constants.IPHONE_3GS:
						DynamicConstants.DEVICE_TYPE = DeviceTypes.IPHONE;
						return 0.65;
						break;
					default:
						DynamicConstants.DEVICE_TYPE = DeviceTypes.IPAD;
						return 1;
						break;
				}
		//	}
			return 1;
		}
		
		
		public static function setButtonScale():Number{
			//if(DynamicConstants.isMobileOS()){
				switch(getDevice()){
					case Constants.IPHONE_5PLUS:
						return 2;
						break;
					case Constants.IPAD_3:
						DynamicConstants.BUTTON_SPACING *= 2;
						return 2;
						break;
					case Constants.IPAD_4PLUS:
						DynamicConstants.BUTTON_SPACING *= 2;
						return 2;
						break;
					case Constants.IPHONE_4S:
						return 2;
						break;
					case Constants.IPHONE_3GS:
						return 1;
						break;
					default:
						if(getDevice() == Constants.UNKNOWN_LARGE){
							DynamicConstants.BUTTON_SPACING *= 2;
							return 2;
						}
						else{
							return 1;
						}
						break;
				}
		//	}
			return 1;
		}
		
		public static function setPurchaseButtonScale():Number{
			//if(DynamicConstants.isMobileOS()){
			switch(getDevice()){
				case Constants.IPHONE_5PLUS:
					return 1.2;
					break;
				case Constants.IPAD_3:
					return 2;
					break;
				case Constants.IPAD_4PLUS:
					return 2;
					break;
				case Constants.IPHONE_4S:
					return 1.2;
					break;
				case Constants.IPHONE_3GS:
					return 1;
					break;
				default:
					if(getDevice() == Constants.UNKNOWN_LARGE){
						DynamicConstants.BUTTON_SPACING *= 2;
						return 2;
					}
					else{
						return 1;
					}
					break;
			}
			//	}
			return 1;
		}
		
		public static function setScreenMargin():Number{
			//if(DynamicConstants.isMobileOS()){
				switch(getDevice()){
					case Constants.IPHONE_5PLUS:
						return 50;
						break;
					case Constants.IPHONE_4S:
						return 50;
						break;
					case Constants.IPHONE_3GS:
						return 25;
						break;
					case Constants.IPAD_2:
						return 100;
						break;
					case Constants.IPAD_3:
						return 200;
						break;
					case Constants.IPAD_4PLUS:
						return 200;
						break;
					default:
						if(getDevice() == Constants.UNKNOWN_LARGE){
							DynamicConstants.BUTTON_SPACING *= 2;
							return 200;
						}
						else{
							return 50;
						}
						break;
				}
			//}
			return 100;
		}
	}
}