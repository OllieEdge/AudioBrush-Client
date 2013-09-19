package com.edgington.util
{
	public class DateFormatter
	{
		/**
		 * Converts the new standard which is commonly used by facebook and MongoDB:
		 * 2013-09-19T00:00:00.000Z
		 * 
		 * To a ActionScript Date object in the correct time zone.
		*/
		public static function RFC3339toDate( rfc3339:String ):Date
		{ 
			var datetime:Array    = rfc3339.split("T");
			
			var date:Array     = datetime[0].split("-");
			var year:int    = int(date[0])
			var month:int    = int(date[1]-1)
			var day:int     = int(date[2])
			
			var time:Array     = datetime[1].split(":");
			var hour:int    = int(time[0])
			var minute:int    = int(time[1])
			var second:Number
			
			// parse offset
			var offsetString:String  = time[2];
			var offsetUTC:int
			
			if ( offsetString.charAt(offsetString.length -1) == "Z" )
			{
				// Zulu time indicator
				offsetUTC  = 0;
				second  = parseFloat( offsetString.slice(0,offsetString.length-1) )
			}
			else
			{
				// split off UTC offset
				var a:Array
				if (offsetString.indexOf("+") != -1)
				{
					a = offsetString.split("+")
					offsetUTC = 1
				}
				else if (offsetString.indexOf("-") != -1)
				{
					a = offsetString.split("-")  
					offsetUTC = -1
				}
				else
				{
					throw new Error( "Invalid Format: cannot parse RFC3339 String." )
				}
				
				// set seconds
				second = parseFloat( a[0] )
				
				// parse UTC offset in millisceonds
				var ms:Number = 0
				if ( time[3] )
				{
					ms = parseFloat(a[1]) * 3600000   
					ms += parseFloat(time[3]) * 60000   
				}
				else
				{
					ms = parseFloat(a[1]) * 60000   
				}
				offsetUTC = offsetUTC * ms   
			}
			return new Date( Date.UTC( year, month, day, hour, minute, second) + offsetUTC );
		}
	}
}