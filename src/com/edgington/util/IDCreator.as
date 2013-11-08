package com.edgington.util
{
	public class IDCreator
	{
		public static function createTrackID(trackname:String, artistname:String):String{
			var regExp:RegExp=new RegExp(/[^a-zA-Z 0-9]+|\s/g);
			var track:String = trackname.replace(regExp, "").toLowerCase();
			var artist:String = trackname.replace(regExp, "").toLowerCase();
			return track + "_" + artist;
		}
	}
}