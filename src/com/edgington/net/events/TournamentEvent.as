package com.edgington.net.events
{
	public class TournamentEvent
	{
		public static const TOURNAMENT_DATA_FAILED:String = "TournamentEvent::TOURNAMENT_DATA_FAILED";
		public static const TOURNAMENT_DATA_RECEIVED:String = "TournamentEvent::TOURNAMENT_DATA_RECEIVED";
		
		public static const TOURNAMENT_LEADER_FAILED:String = "TournamentEvent::TOURNAMENT_LEADER_FAILED";
		public static const TOURNAMENT_LEADER_RECEIVED:String = "TournamentEvent::TOURNAMENT_LEADER_RECEIVED";
		
		public static const DATA_PROGRESS:String = "TournamentEvent::DATA_PROGRESS";
		public static const DATA_COMPLETE:String = "TournamentEvent::DATA_COMPLETE";
		
		
		public static const NEW_HIGHSCORE:String = "TournamentEvent::NEW_HIGHSCORE";
		public static const NO_NEW_HIGHSCORE:String = "TournamentEvent::NEW_HIGHSCORE";
		public static const SCORE_POST_FAILED:String = "TournamentEvent::SCORE_POST_FAILED";
	}
}