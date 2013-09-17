package com.edgington.model.events
{
	public class AudioEvent
	{
		
		/**
		 * When the song file has completed loading this is the event type used.
		 */
		public static var TRACK_SELECTION_CANCELED:String = "AudioEvent::TRACK_SELECTION_CANCELED";
		
		/**
		 * When the song file has completed loading this is the event type used.
		 */
		public static var TRACK_ERROR_PROTECTED:String = "AudioEvent::TRACK_ERROR_PROTECTED";
		
		/**
		 * When the song file has completed loading this is the event type used.
		 */
		public static var TRACK_ERROR_IMPORTING:String = "AudioEvent::TRACK_ERROR_IMPORTING";
		
		
		/**
		 * When the track has completed playing all the way through
		 */
		public static var TRACK_NEEDS_CONVERSION:String = "AudioEvent::TRACK_NEEDS_CONVERSION";
		
		/**
		 * When the track has completed playing all the way through
		 */
		public static var TRACK_CONVERSION_PROGRESS:String = "AudioEvent::TRACK_CONVERSION_PROGRESS";
		
		/**
		 * When the track has completed playing all the way through
		 */
		public static var TRACK_CONVERSION_COMPLETE:String = "AudioEvent::TRACK_CONVERSION_COMPLETE";
		
		
		
		
		/**
		 * When the song file has completed loading this is the event type used.
		 */
		public static var TRACK_LOADED:String = "AudioEvent::TRACK_LOADED";
		
		/**
		 * When the song file is being imported from the iOS music library, parsed with a progress (0 - 1)
		 */
		public static var TRACK_IMPORTING:String = "AudioEvent::TRACK_IMPORTING";
		
		/**
		 * When the song file is being analised, this will parse a progress value (0 - 1)
		 */
		public static var TRACK_ANALISING:String = "AudioEvent::TRACK_ANALISING";
		
		/**
		 * When the track analysis is complete
		 */
		public static var TRACK_ANALYSIS_COMPLETE:String = "AudioEvent::TRACK_ANALYSIS_COMPLETE";
		
		/**
		 * When the track has completed playing all the way through
		 */
		public static var TRACK_COMPLETE:String = "AudioEvent::TRACK_COMPLETE";
	}
}