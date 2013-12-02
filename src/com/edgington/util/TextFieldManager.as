package com.edgington.util
{	
	import com.edgington.constants.FontConstants;
	
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class TextFieldManager
	{
		
		public static function createTextField(text : String, font : Class, colour : Number, size : int, multiline : Boolean = false, align:String = "") : TextField
		{
			var tf : TextFormat = new TextFormat();
			tf.align = TextFieldAutoSize.LEFT;
			if(font == FONT_audiobrush_content_bold){
				if(FontConstants.useEmbedded){
					tf.font = Font(new FontConstants.defaultBoldFont()).fontName;
				}
				else{
					tf.font = FontConstants.defaultBoldNativeFont;
				}
			}
			else{
				if(FontConstants.useEmbedded){
					tf.font = Font(new FontConstants.defaultFont()).fontName;
				}
				else{
					tf.font = FontConstants.defaultNativeFont;
				}
			}
			tf.size = size;
			tf.color = colour;
			
			var tField : TextField = new TextField();
			tField.defaultTextFormat = tf;
			tField.border = false;
			tField.selectable = false;
			tField.embedFonts = FontConstants.useEmbedded;
			tField.htmlText = text;
			tField.multiline = multiline;
			tField.autoSize = TextFieldAutoSize.LEFT;
			
			if(align != ""){
				tField.autoSize = align;//(align == TextFieldAutoSize.LEFT || align == TextFieldAutoSize.CENTER || align == TextFieldAutoSize.RIGHT) ? align : TextFieldAutoSize.CENTER ;
			}
			
			return tField;
		}
		
		public static function createCentrallyAllignedTextField(text : String, font : Class, colour : Number, size : int, multiline : Boolean = false, width : Number = 0) : TextField
		{
			var tf : TextFormat = new TextFormat();
			tf.align = TextFieldAutoSize.CENTER;
			
			if(font == FONT_audiobrush_content_bold){
				if(FontConstants.useEmbedded){
					tf.font = Font(new FontConstants.defaultBoldFont()).fontName;
				}
				else{
					tf.font = FontConstants.defaultBoldNativeFont;
				}
			}
			else{
				if(FontConstants.useEmbedded){
					tf.font = Font(new FontConstants.defaultFont()).fontName;
				}
				else{
					tf.font = FontConstants.defaultNativeFont;
				}
			}
			
			tf.size = size;
			tf.color = colour;
			
			var tField : TextField = new TextField();
			
			tField.defaultTextFormat = tf;
			tField.border = false;
			tField.selectable = false;
			tField.embedFonts = FontConstants.useEmbedded;
			tField.multiline = multiline;
			tField.wordWrap = multiline;
			tField.text = text;
			
			if(width != 0) {
				tField.autoSize = TextFieldAutoSize.NONE;
				tField.width = width;
			}
			
			tField.autoSize = TextFieldAutoSize.CENTER;
			
			return tField;
		}
		
		public static function createTextFieldWithAlignment(text : String, font : Class, colour : Number, size : int, alignment : String, multiline:Boolean = false, width:int = 0) : TextField 
		{
			var tf : TextFormat = new TextFormat();
			if(font == FONT_audiobrush_content_bold){
				if(FontConstants.useEmbedded){
					tf.font = Font(new FontConstants.defaultBoldFont()).fontName;
				}
				else{
					tf.font = FontConstants.defaultBoldNativeFont;
				}
			}
			else{
				if(FontConstants.useEmbedded){
					tf.font = Font(new FontConstants.defaultFont()).fontName;
				}
				else{
					tf.font = FontConstants.defaultNativeFont;
				}
			}
			tf.size = size;
			tf.color = colour;
			tf.align = alignment;
			
			var tField : TextField = new TextField();
			tField.defaultTextFormat = tf;
			tField.border = false;
			tField.selectable = false;
			tField.multiline = multiline;
			tField.wordWrap = multiline;
			tField.embedFonts = FontConstants.useEmbedded;
			tField.text = text;
			
			if(width != 0) {
				tField.autoSize = TextFieldAutoSize.NONE;
				tField.width = width;
			}
			else{
				tField.autoSize = (alignment == TextFieldAutoSize.LEFT || alignment == TextFieldAutoSize.CENTER || alignment == TextFieldAutoSize.RIGHT) ? alignment : TextFieldAutoSize.CENTER ;
			}
			
			return tField;
		}
	}
}

