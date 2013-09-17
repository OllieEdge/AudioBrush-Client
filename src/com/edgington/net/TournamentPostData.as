package com.edgington.net
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.GameProxy;
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.net.events.TournamentEvent;
	import com.edgington.util.debug.LOG;
	import com.edgington.valueobjects.net.HighscoreServerVO;
	
	import flash.net.NetConnection;
	import flash.net.Responder;
	
	import org.osflash.signals.Signal;
	
	public class TournamentPostData
	{
		private static var INSTANCE:TournamentPostData;
		
		private const CALL_POST_HIGHSCORE:String = "tournaments.TournamentManager.postNewHighscore";
		
		private var postResponder:Responder;
		
		private var netConnection:NetConnection;
		
		public var tournamentStatusSignal:Signal;
		
		private var postedSavedScore:Boolean = false;
		
		public function TournamentPostData()
		{
			LOG.create(this);
			
			NetManager.getInstance().serverConnectionErrorSignal.add(connectionErrorHandler);
			netConnection = NetManager.getInstance().netConnection;
			
			tournamentStatusSignal = new Signal();
			
			postResponder = new Responder(onHighscorePosted, onHighscorePostFailed);
		}
		
		
		public function postHighscore():void{
			if(FacebookManager.getInstance().checkIfUserIsLoggedIn()){
				var facebookID:String = FacebookManager.getInstance().currentLoggedInUser.profileID;
			}
			else{
				tournamentStatusSignal.dispatch(TournamentEvent.SCORE_POST_FAILED);
				return;
			}
			var score:int = GameProxy.INSTANCE.score;
			var tournamentID:String = TournamentData.getInstance().currentActiveTournament.ID;

			if(DynamicConstants.IS_CONNECTED){
				netConnection.call(CALL_POST_HIGHSCORE, postResponder, facebookID, tournamentID, score);
			}
			else{
				tournamentStatusSignal.dispatch(TournamentEvent.SCORE_POST_FAILED);
			}
		}
		
		
		private function onHighscorePosted(e:Object):void{
			var localHighscore:HighscoreServerVO = convertAMFtoVO(e);
			if(e.newHighscore == 1){
				tournamentStatusSignal.dispatch(TournamentEvent.NEW_HIGHSCORE, localHighscore);
			}
			else{
				tournamentStatusSignal.dispatch(TournamentEvent.NO_NEW_HIGHSCORE, localHighscore);
			}
		}
		
		
		private function onHighscorePostFailed(e:Object):void{
			LOG.error("UserData: " + e.description);
			tournamentStatusSignal.dispatch(TournamentEvent.SCORE_POST_FAILED);
		}
		
		
		private function connectionErrorHandler():void{
			LOG.error("GameProxy was removed before the post highscore could respond (HANDLED)");
			tournamentStatusSignal.dispatch(TournamentEvent.SCORE_POST_FAILED);
		}
		
		
		private function convertAMFtoVO(amfObject:Object):HighscoreServerVO{
			var localHighscore:HighscoreServerVO = new HighscoreServerVO();
			localHighscore.score = amfObject.score;
			localHighscore.artist = TournamentData.getInstance().currentActiveTournament.ARTIST;
			localHighscore.track = TournamentData.getInstance().currentActiveTournament.TRACK;
			localHighscore.newHighscore = (amfObject.newHighscore == 1);
			localHighscore.rank = amfObject.rank;
			localHighscore.difficulty = 0;
			return localHighscore;
		}
		
		
		public static function getInstance():TournamentPostData{
			if(INSTANCE == null){
				INSTANCE = new TournamentPostData();
			}
			return INSTANCE;
		}
	}
}

