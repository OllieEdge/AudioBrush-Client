package com.edgington.net
{
	import com.edgington.model.tournaments.TournamentAssetsManager;
	import com.edgington.net.events.TournamentEvent;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.valueobjects.TournamentVO;
	
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.net.SharedObject;
	
	import org.osflash.signals.Signal;

	public class TournamentData
	{
		
		private static var INSTANCE:TournamentData;
		
		private var netConnection:NetConnection;
		
		private const CALL_GET_TOURNAMENT:String = "tournaments.TournamentManager.getCurrentTournament";
		private const CALL_GET_CURRENT_LEADER:String = "tournaments.TournamentManager.getCurrentLeader";
		
		private var tournamentDataReposnder:Responder;
		private var tournamentLeaderResponder:Responder;
		
		public var responceSignal:Signal;
		
		private var tournamentData:SharedObject = SharedObject.getLocal("ab_tournaments");
		
		public var currentActiveTournament:TournamentVO;
		public var currentLeader:Object;
		
		public var currentTournamentDataDownloaded:Boolean = false;
		
		public var isThisGameATournamentGame:Boolean = false;
		
		public function TournamentData()
		{
			LOG.create(this);
			
			responceSignal = new Signal();
			
			tournamentDataReposnder = new Responder(onTournamentReceived, onTournamentFailed);
			tournamentLeaderResponder= new Responder(onLeaderReceived, onLeaderFailed);
			
			if(tournamentData.data.listings == null){
				tournamentData.data.listings = new Array();
				saveData();
			}
		}
		
		public function getCurrentTournamentData():void{
			netConnection.call(CALL_GET_TOURNAMENT, tournamentDataReposnder);
		}
		
		private function onTournamentReceived(e:Object):void{
			var tournamentFound:Boolean = false;
			for(var i:int = 0; i < tournamentData.data.listings; i++){
				if(tournamentData.data.listing[i].id == e.id){
					currentActiveTournament = convertDatabaseObjectToTournamentVO(e);
					tournamentFound = true;
					break;
				}
			}
			if(!tournamentFound){
				tournamentData.data.listings.push(e);
				currentActiveTournament = convertDatabaseObjectToTournamentVO(e);
			}
			
			//If the current tournament data has already been download (ie, track, data files etc);
			if(TournamentAssetsManager.getInstance().checkForCachedTournamentData(e.id)){
				currentTournamentDataDownloaded = true
			}
			else{
				currentTournamentDataDownloaded = false;
			}
			
			responceSignal.dispatch(TournamentEvent.TOURNAMENT_DATA_RECEIVED);
		}
		
		private function onTournamentFailed(e:Object):void{
			LOG.error("TournamentData Data: " + e.description);
			responceSignal.dispatch(TournamentEvent.TOURNAMENT_DATA_FAILED);
		}
		
		public function getLeader():void{
			netConnection.call(CALL_GET_CURRENT_LEADER, tournamentLeaderResponder, currentActiveTournament.ID);
		}
		
		private function onLeaderReceived(e:Object):void{
			if(e != 0){
				currentLeader = e;
			}
			else{
				currentLeader = new Object();
				currentLeader.name = gettext("tournament_entry_no_entries");
				currentLeader.score = 0;
			}
			responceSignal.dispatch(TournamentEvent.TOURNAMENT_LEADER_RECEIVED);
		}
		
		private function onLeaderFailed(e:Object):void{
			LOG.error("TournamentData Leader: " + e.description);
			responceSignal.dispatch(TournamentEvent.TOURNAMENT_LEADER_FAILED);
		}
		
		private function connectionErrorHandler():void{
			responceSignal.dispatch(TournamentEvent.TOURNAMENT_DATA_FAILED);
		}
		
		private function saveData():void{
			tournamentData.flush();
		}
		
		private function convertDatabaseObjectToTournamentVO(e:Object):TournamentVO{
			var tVO:TournamentVO = new TournamentVO();
			
			tVO.ID = e.id;
			tVO.ACTIVE_DATE = e.activeDate;
			tVO.END_DATE = e.endData;
			tVO.COST = parseInt(e.cost);
			tVO.TRACK = e.track;
			tVO.ARTIST = e.artist;
			tVO.ARTWORK_URL = e.artworkURL;
			tVO.TRACK_URL = e.trackURL;
			tVO.BEATS_FILE_URL = e.beatsFile;
			tVO.BEATS_DETECTED_FILE_URL = e.beatsDetectedFile;
			tVO.STAR_BEATS_FILE_URL = e.starBeatsFile;
			tVO.FLUX_FILE_URL = e.fluxFile;
			tVO.SECTIONS_FILE_URL = e.sectionsFile;
			tVO.STAR_SECTIONS_FILE_URL = e.starSectionsFile;
			tVO.PRIZES = e.prizes;
			
			return tVO;
		}
		
		public static function getInstance():TournamentData{
			if(INSTANCE == null){
				INSTANCE = new TournamentData();
			}
			return INSTANCE;
		}
	}
}