package com.edgington.util
{
	import flash.globalization.NumberFormatter;

	public class NumberFormat
	{
		public static function addThreeDigitCommaSeperator(value:int):String{
			var numberFormatter:NumberFormatter = new NumberFormatter("en_GB");
			numberFormatter.fractionalDigits = 0;
			numberFormatter.useGrouping = true;
			numberFormatter.groupingPattern = "3;*";
			return numberFormatter.formatInt(value);
		}
	
	}
}