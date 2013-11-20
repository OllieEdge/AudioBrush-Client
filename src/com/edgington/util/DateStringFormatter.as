package com.edgington.util
{
	import com.edgington.util.localisation.gettext;

	public class DateStringFormatter
	{
		public static function getDurationBetweenDatesString(startDate:Date, endDate:Date):String{
			var str:String;

			var days:int = 0;
			var hours:int = 0;
			var minutes:int = 0;
			var seconds:int = 0;
			
			var leftOvers:Number;
			
			var difference:Number = endDate.time - startDate.time;
			
			days = Math.floor(difference / 86400000);
			hours = Math.floor(difference / 3600000);
			minutes = Math.floor(difference / 60000);
			seconds = Math.floor(difference / 1000);
			
			if(days > 1){
				return gettext("tournament_days_remaining", {days:days});
			}
			if(hours > 1){
				return gettext("tournament_hours_remaining", {hours:hours});
			}
			if(minutes > 1){
				return gettext("tournament_minutes_remaining", {minutes:minutes});
			}
			if(seconds > 1){
				return gettext("tournament_seconds_remaining", {seconds:seconds});
			}
			
			return gettext("tournament_seconds_remaining", {seconds:0});
		}
	}
}