
package com.edgington.constants
{

	public class FontConstants
	{
		public static var useEmbedded:Boolean = true;
		
		public static var defaultFont:Class = FONT_audiobrush_content;
		public static var defaultBoldFont:Class = FONT_audiobrush_content_bold;
		
		public static var defaultNativeFont:String;
		public static var defaultBoldNativeFont:String;
		
		public static function decideNativeFontUse(language:String):void{
			switch(language){
				case "en":
					useEmbedded = true;
					defaultFont = FONT_audiobrush_content;
					defaultBoldFont = FONT_audiobrush_content_bold;
					break;
				case "zh-CN":
					useEmbedded = false;
					defaultNativeFont = "STHeitiSC-Light";
					defaultBoldNativeFont = "STHeitiSC-Medium";
					break;
				case "ja":
					useEmbedded = false;
					defaultNativeFont = "Hiragino Kaku Gothic Pro W4";
					defaultBoldNativeFont = "Hiragino Kaku Gothic Std W8";
					break;
				default:
					useEmbedded = true;
					defaultFont = FONT_audiobrush_content;
					defaultBoldFont = FONT_audiobrush_content_bold;
					break;
			}
		}
	}
}