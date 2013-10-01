package com.edgington.net
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.FacebookConstants;
	import com.edgington.model.GameProxy;
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.net.events.TournamentEvent;
	import com.edgington.net.helpers.NetResponceHandler;
	import com.edgington.util.debug.LOG;
	import com.edgington.valueobjects.net.HighscoreServerVO;
	import com.edgington.valueobjects.net.ServerScoreVO;
	
	import flash.net.NetConnection;
	import flash.net.Responder;
	
	import org.osflash.signals.Signal;
	
	public class TournamentPostData extends BaseData
	{
		private static var INSTANCE:TournamentPostData;
		
		private const CALL_POST_HIGHSCORE:String = "tournaments.TournamentManager.postNewHighscore";
		
		private var postResponder:Responder;
		
		private var netConnection:NetConnection;
		
		public var tournamentStatusSignal:Signal;
		
		private var postedSavedScore:Boolean = false;
		
		//The variables that are parsed to the server go in this object
		private var postObject:Object;
		
		public function TournamentPostData()
		{
			super("score", "scores");
			LOG.create(this);
			
			tournamentStatusSignal = new Signal();
			
			postResponder = new Responder(onHighscorePosted, onHighscorePostFailed);
		}
		
		
		public function postHighscore():void{
			if(FacebookManager.getInstance().checkIfUserIsLoggedIn() || FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
				var facebookID:String
				if(FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
					facebookID = FacebookConstants.DEBUG_USER_ID;
				}
				else{
					facebookID = FacebookManager.getInstance().currentLoggedInUser.id;
				}
				
			}
			else{
				tournamentStatusSignal.dispatch(TournamentEvent.SCORE_POST_FAILED);
				return;
			}
			
			var score:int = GameProxy.INSTANCE.score;
			var tournamentID:String = TournamentData.getInstance().currentActiveTournament.ID;

			if(DynamicConstants.IS_CONNECTED){
				
				postObject = new Object();
				postObject.trackkey = "tournament_"+tournamentID;
				postObject.fb_id = facebookID;
				postObject.score = score;
				postObject.trackname = TournamentData.getInstance().currentActiveTournament.TRACK;
				postObject.artist = TournamentData.getInstance().currentActiveTournament.ARTIST;
				
				PUT(new NetResponceHandler(onHighscorePosted, onHighscorePostFailed), postObject.trackkey, postObject);
			}
			else{
				tournamentStatusSignal.dispatch(TournamentEvent.SCORE_POST_FAILED);
			}
		}
		
		
		private function onHighscorePosted(e:Object = null):void{
			
			//Make sure that there is a valid score response.
			if(e && ServerScoreVO.checkObject(e)){
				var localHighscore:HighscoreServerVO = convertServerScoreVOtoClientVO(new ServerScoreVO(e));
				if(localHighscore.newHighscore){
					if(postedSavedScore){
						localHighscore.newHighscore = false;
					}
					localHighscore.requiresSyncWithServer = false;
					tournamentStatusSignal.dispatch(TournamentEvent.NEW_HIGHSCORE, localHighscore);
				}
				else{
					tournamentStatusSignal.dispatch(TournamentEvent.NO_NEW_HIGHSCORE, localHighscore);
				}
			}
			else{
				LOG.error("There was a problem from the server");
				tournamentStatusSignal.dispatch(TournamentEvent.SCORE_POST_FAILED);
			}
		}
		
		private function onHighscorePostFailed():void{
			LOG.error("There was a problem from the server");
			tournamentStatusSignal.dispatch(TournamentEvent.SCORE_POST_FAILED);
		}
		
		private function connectionErrorHandler():void{
			LOG.error("GameProxy was removed before the post highscore could respond (HANDLED)");
			tournamentStatusSignal.dispatch(TournamentEvent.SCORE_POST_FAILED);
		}
		
		private function convertServerScoreVOtoClientVO(serverVO:ServerScoreVO):HighscoreServerVO{
			var localHighscore:HighscoreServerVO = new HighscoreServerVO();
			localHighscore.artist = postObject.artist
			localHighscore.track = postObject.trackname;
			localHighscore.newHighscore = (postObject.score == serverVO.score);//This might be wrong?
			localHighscore.rank = serverVO.rank;
			localHighscore.score = serverVO.score;
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

