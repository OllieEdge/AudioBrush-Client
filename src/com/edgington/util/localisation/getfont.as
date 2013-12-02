package com.edgington.util.localisation
{
	import com.edgington.constants.FontConstants;
	import com.edgington.types.FontFaceType;
	
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;

		public function getfont(textField:TextField, type:String):void
		{
			
			
			var defaultFormat:TextFormat = textField.getTextFormat();
			
			textField.embedFonts = FontConstants.useEmbedded;
			
			switch(type){
				case FontFaceType.BOLD:
					if(FontConstants.useEmbedded){
						defaultFormat.font = Font(new FontConstants.defaultBoldFont()).fontName;
					}
					else{
						defaultFormat.font = FontConstants.defaultBoldNativeFont;
					}
					break;
				case FontFaceType.REGULAR:
					if(FontConstants.useEmbedded){
						defaultFormat.font = Font(new FontConstants.defaultFont()).fontName;
					}
					else{
						defaultFormat.font = FontConstants.defaultNativeFont;
					}
					break;
			}
			
			textField.setTextFormat(defaultFormat);
		}
}