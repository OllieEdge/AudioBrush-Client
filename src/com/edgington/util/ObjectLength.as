package com.edgington.util
{
	public class ObjectLength
	{
		public static function count(myObject:Object):int {
			var cnt:int=0;
			
			for (var s:String in myObject) cnt++;
			
			return cnt;
		}
	}
}