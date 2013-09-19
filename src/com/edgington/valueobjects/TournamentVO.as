package com.edgington.valueobjects
{
	public class TournamentVO
	{
		public var ID:String;
		public var ACTIVE_DATE:Date;
		public var END_DATE:Date;
		public var COST:int;
		public var TRACK:String;
		public var ARTIST:String;
		public var ARTWORK_URL:String;
		public var TRACK_URL:String;
		public var BEATS_FILE_URL:String;
		public var BEATS_DETECTED_FILE_URL:String;
		public var STAR_BEATS_FILE_URL:String;
		public var FLUX_FILE_URL:String;
		public var SECTIONS_FILE_URL:String;
		public var STAR_SECTIONS_FILE_URL:String;
		public var PRIZES:String;
		public var CACHED:Boolean = false;
	}
}