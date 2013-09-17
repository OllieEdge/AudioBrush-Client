package com.edgington.net
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.GameProxy;
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.net.events.HighscoreEvent;
	import com.edgington.util.debug.LOG;
	import com.edgington.valueobjects.net.HighscoreServerVO;
	
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.net.SharedObject;
	import flash.utils.Dictionary;
	
	import org.osflash.signals.Signal;
	
	public class HighscoresPostData
	{
		private static var INSTANCE:HighscoresPostData;
		
		private const CALL_POST_HIGHSCORE:String = "highscores.HighscoresManager.postNewHighscore";
		
		private var highscoresOfflineData:SharedObject;
		
		private var postResponder:Responder;
		
		private var netConnection:NetConnection;
		
		public var highscoreDataSignal:Signal;
		
		private var postedSavedScore:Boolean = false;
		
		public function HighscoresPostData()
		{
			LOG.create(this);
			
			NetManager.getInstance().serverConnectionErrorSignal.add(connectionErrorHandler);
			
			netConnection = NetManager.getInstance().netConnection;
			highscoresOfflineData = SharedObject.getLocal("local_highscores");
			if(highscoresOfflineData.data.highscores == null){
				highscoresOfflineData.data.highscores = new Dictionary();
				saveHighscore();
			}
			
			highscoreDataSignal = new Signal();
			
			postResponder = new Responder(onHighscorePosted, onHighscorePostFailed);
		}
		
		public function postHighscore():void{
			postedSavedScore = false;
			if(FacebookManager.getInstance().checkIfUserIsLoggedIn()){
				var facebookID:String = FacebookManager.getInstance().currentLoggedInUser.profileID;
			}
			var regExp:RegExp=new RegExp(/[^a-zA-Z 0-9]+|\s/g);
			var track:String = GameProxy.INSTANCE.currentTrackDetails.trackTitle.replace(regExp, "").toLowerCase();
			var artist:String = GameProxy.INSTANCE.currentTrackDetails.artistName.replace(regExp, "").toLowerCase();
			var score:int = GameProxy.INSTANCE.score;
			var difficulty:int = GameProxy.INSTANCE.difficulty;
			
			var localHighscore:HighscoreServerVO = new HighscoreServerVO();
			var shouldPostScoreToServer:Boolean = true;
			if(highscores[track + "_" + artist + "_" + difficulty] == null){
				localHighscore.score = score;
				localHighscore.requiresSyncWithServer = true;
				highscores[track + "_" + artist + "_" + difficulty] = localHighscore;
				saveHighscore();
			}
			else if(highscores[track + "_" + artist + "_" + difficulty].score >= score){
				if(highscores[track + "_" + artist + "_" + difficulty].requiresSyncWithServer){
					postedSavedScore = true;
					score = highscores[track + "_" + artist + "_" + difficulty].score;
				}
				else{
					shouldPostScoreToServer = false;
					highscores[track + "_" + artist + "_" + difficulty].newHighscore = false;
					highscoreDataSignal.dispatch(HighscoreEvent.NO_NEW_HIGHSCORE, convertAMFtoVO(highscores[track + "_" + artist + "_" + difficulty]));
					return;
				}
			}

			if(DynamicConstants.IS_CONNECTED && shouldPostScoreToServer && FacebookManager.getInstance().checkIfUserIsLoggedIn()){
				netConnection.call(CALL_POST_HIGHSCORE, postResponder, facebookID, track, artist, score, difficulty, GameProxy.INSTANCE.currentTrackDetails.trackTitle, GameProxy.INSTANCE.currentTrackDetails.artistName);
			}
			else if(shouldPostScoreToServer){
				localHighscore.score = score;
				localHighscore.requiresSyncWithServer = true;
				localHighscore.artist = artist;
				localHighscore.track = track;
				localHighscore.newHighscore = true;
				localHighscore.rank = -1;
				localHighscore.score = score;
				localHighscore.difficulty = difficulty;
				if(highscores[track + "_" + artist + "_" + difficulty].score < score){
					highscores[track + "_" + artist + "_" + difficulty] = localHighscore;
					saveHighscore();
				}
				
				highscoreDataSignal.dispatch(HighscoreEvent.NEW_HIGHSCORE, localHighscore);
			}
		}
		
		private function onHighscorePosted(e:Object):void{
			var localHighscore:HighscoreServerVO = convertAMFtoVO(e);
			if(e.newHighscore == 1){
				if(postedSavedScore){
					localHighscore.newHighscore = false;
				}
				localHighscore.requiresSyncWithServer = false;
				highscores[localHighscore.track + "_" + localHighscore.artist + "_" + localHighscore.difficulty] == localHighscore;
				saveHighscore();
				highscoreDataSignal.dispatch(HighscoreEvent.NEW_HIGHSCORE, localHighscore);
			}
			else{
				highscoreDataSignal.dispatch(HighscoreEvent.NO_NEW_HIGHSCORE, localHighscore);
			}
		}
		
		private function onHighscorePostFailed(e:Object):void{
			LOG.error("UserData: " + e.description);
		}
		
		private function get highscores():Object{
			return highscoresOfflineData.data.highscores;
		}
		
		private function saveHighscore():void{
			highscoresOfflineData.flush();
		}
		
		private function connectionErrorHandler():void{
			try{
				var regExp:RegExp=new RegExp(/[^a-zA-Z 0-9]+|\s/g);
				var track:String = GameProxy.INSTANCE.currentTrackDetails.trackTitle.replace(regExp, "").toLowerCase();
				var artist:String = GameProxy.INSTANCE.currentTrackDetails.artistName.replace(regExp, "").toLowerCase();
				var score:int = GameProxy.INSTANCE.score;
				var difficulty:int = GameProxy.INSTANCE.difficulty;
				var localHighscore:HighscoreServerVO = new HighscoreServerVO();
				localHighscore.score = score;
				localHighscore.requiresSyncWithServer = true;
				localHighscore.artist = artist;
				localHighscore.track = track;
				localHighscore.newHighscore = true;
				localHighscore.rank = -1;
				localHighscore.score = score;
				localHighscore.difficulty = difficulty;
				if(highscores[track + "_" + artist + "_" + difficulty].score < score){
					highscores[track + "_" + artist + "_" + difficulty] = localHighscore;
					saveHighscore();
					highscoreDataSignal.dispatch(HighscoreEvent.NEW_HIGHSCORE, localHighscore);
				 }
				else{
					highscoreDataSignal.dispatch(HighscoreEvent.NO_NEW_HIGHSCORE, convertAMFtoVO(highscores[track + "_" + artist + "_" + difficulty]));
				}
				
			}
			catch(e:Error){
				LOG.error("GameProxy was removed before the post highscore could respond (HANDLED)");
				highscoreDataSignal.dispatch();
			}
		}
		
		private function convertAMFtoVO(amfObject:Object):HighscoreServerVO{
			var localHighscore:HighscoreServerVO = new HighscoreServerVO();
			localHighscore.score = amfObject.score;
			localHighscore.artist = amfObject.artist;
			localHighscore.track = amfObject.track;
			localHighscore.newHighscore = (amfObject.newHighscore == 1);
			localHighscore.rank = amfObject.rank;
			localHighscore.score = amfObject.score;
			localHighscore.difficulty = amfObject.difficulty;
			return localHighscore;
		}
		
		public static function getInstance():HighscoresPostData{
			if(INSTANCE == null){
				INSTANCE = new HighscoresPostData();
			}
			return INSTANCE;
		}
	}
}

