package com.edgington.net
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.FacebookConstants;
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.model.tournaments.TournamentAssetsManager;
	import com.edgington.net.events.TournamentEvent;
	import com.edgington.net.helpers.NetResponceHandler;
	import com.edgington.util.debug.LOG;
	import com.edgington.valueobjects.TournamentVO;
	import com.edgington.valueobjects.net.ServerScoreVO;
	import com.edgington.valueobjects.net.ServerTournamentDataVO;
	
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.net.SharedObject;
	
	import org.osflash.signals.Signal;

	public class TournamentData extends BaseData
	{
		
		private static var INSTANCE:TournamentData;
		
		private var netConnection:NetConnection;
		
		private const CALL_GET_TOURNAMENT:String = "tournaments.TournamentManager.getCurrentTournament";
		private const CALL_GET_CURRENT_LEADER:String = "tournaments.TournamentManager.getCurrentLeader";
		
		private var tournamentDataReposnder:Responder;
		private var tournamentLeaderResponder:Responder;
		
		public var responceSignal:Signal;
		
		private var tournamentData:SharedObject = SharedObject.getLocal("ab_tournaments");
		
		public var currentActiveTournaments:Vector.<TournamentVO>;
		
		public var currentActiveTournament:TournamentVO;
		public var currentLeader:Vector.<ServerScoreVO>;
		
		public var currentTournamentDataDownloaded:Boolean = false;
		
		public var isThisGameATournamentGame:Boolean = false;
		
		public function TournamentData()
		{
			super("tournament", "tournaments");
			LOG.create(this);
			
			currentLeader = new Vector.<ServerScoreVO>
			
			responceSignal = new Signal();
			
			tournamentDataReposnder = new Responder(onTournamentReceived, onTournamentFailed);
			tournamentLeaderResponder= new Responder(onLeaderReceived, onLeaderFailed);
			
			if(tournamentData.data.listings == null){
				tournamentData.data.listings = new Array();
				saveData();
			}
		}
		
		public function getCurrentTournamentData():void{
			if(DynamicConstants.IS_CONNECTED && FacebookManager.getInstance().checkIfUserIsLoggedIn()/* || FacebookConstants.DEBUG_FACEBOOK_ALLOWED*/){
				GET(new NetResponceHandler(onTournamentReceived, onTournamentFailed), true, "", "active");
			}
		}
		
		private function onTournamentReceived(e:Object = null):void{
			if(e && e.length > 0){
				if(ServerTournamentDataVO.checkObject(e[0])){
					currentActiveTournaments = new Vector.<TournamentVO>;
					for(var i:int = 0; i < e.length; i++){
						var serverTournamentDataVO:ServerTournamentDataVO = new ServerTournamentDataVO(e[i]);
						var tournamentVO:TournamentVO = convertDatabaseObjectToTournamentVO(serverTournamentDataVO);
						tournamentVO.CACHED = (TournamentAssetsManager.getInstance().checkForCachedTournamentData(String(serverTournamentDataVO.tournamentID)));
						currentActiveTournaments.push(tournamentVO);
					}
					currentActiveTournament = currentActiveTournaments[0];
				}
			}
			else{
				if(e && e.length == 0){
					LOG.warning("There are no active tournaments");
				}
				else{
					LOG.error("There was a problem getting the tournaments from the server");
				}
			}
			responceSignal.dispatch(TournamentEvent.TOURNAMENT_DATA_RECEIVED);
		}
		
		private function onTournamentFailed():void{
			LOG.error("There was a problem when trying to retrieve the tournaments data from the server");
			responceSignal.dispatch(TournamentEvent.TOURNAMENT_DATA_FAILED);
		}
		
		public function getLeader(tournamentID:String):void{
			GET(new NetResponceHandler(onLeaderReceived, onLeaderFailed), false, "leader/"+tournamentID);
			//netConnection.call(CALL_GET_CURRENT_LEADER, tournamentLeaderResponder, currentActiveTournament.ID);
		}
		
		private function onLeaderReceived(e:Object = null):void{
			if(e != null){
				if(ServerScoreVO.checkObject(e)){
					var leaderVo:ServerScoreVO = new ServerScoreVO(e);
					var updated:Boolean = false;
					for(var i:int = 0; i < currentLeader.length; i++){
						if(currentLeader[i].trackkey == leaderVo.trackkey){
							currentLeader[i] = leaderVo;
							updated = true;
							break;
						}
					}
					if(!updated){
						currentLeader.push(leaderVo);
					}
					
				}
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
		
		private function convertDatabaseObjectToTournamentVO(e:ServerTournamentDataVO):TournamentVO{
			var tVO:TournamentVO = new TournamentVO();
			
			tVO.ID = String(e.tournamentID);
			tVO.ACTIVE_DATE = e.activeDate;
			tVO.END_DATE = e.endDate;
			tVO.COST = e.cost;
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