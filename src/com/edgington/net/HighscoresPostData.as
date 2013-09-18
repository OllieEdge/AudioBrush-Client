package com.edgington.net
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.FacebookConstants;
	import com.edgington.model.GameProxy;
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.net.events.HighscoreEvent;
	import com.edgington.net.helpers.NetResponceHandler;
	import com.edgington.util.debug.LOG;
	import com.edgington.valueobjects.net.HighscoreServerVO;
	import com.edgington.valueobjects.net.ServerScoreVO;
	
	import flash.net.SharedObject;
	import flash.utils.Dictionary;
	
	import org.osflash.signals.Signal;
	
	public class HighscoresPostData extends BaseData
	{
		private static var INSTANCE:HighscoresPostData;
		
		private const CALL_POST_HIGHSCORE:String = "highscores.HighscoresManager.postNewHighscore";
		
		private var highscoresOfflineData:SharedObject;
		
		public var highscoreDataSignal:Signal;
		
		private var postedSavedScore:Boolean = false;
		
		public function HighscoresPostData()
		{
			super("score", "scores");
			LOG.create(this);
			
			highscoresOfflineData = SharedObject.getLocal("local_highscores");
			if(highscoresOfflineData.data.highscores == null){
				highscoresOfflineData.data.highscores = new Dictionary();
				saveHighscore();
			}
			
			highscoreDataSignal = new Signal();
		}
		
		public function postHighscore():void{
			postedSavedScore = false;
			
			var facebookID:String
			if(FacebookManager.getInstance().checkIfUserIsLoggedIn()){
				facebookID = FacebookManager.getInstance().currentLoggedInUser.profileID;
			}
			if(FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
				facebookID = FacebookConstants.DEBUG_USER_ID;
			}
			
			var regExp:RegExp=new RegExp(/[^a-zA-Z 0-9]+|\s/g);
			var track:String = GameProxy.INSTANCE.currentTrackDetails.trackTitle.replace(regExp, "").toLowerCase();
			var artist:String = GameProxy.INSTANCE.currentTrackDetails.artistName.replace(regExp, "").toLowerCase();
			var score:int = GameProxy.INSTANCE.score;
			var difficulty:int = GameProxy.INSTANCE.difficulty;
			
			var localHighscore:HighscoreServerVO = new HighscoreServerVO();
			var shouldPostScoreToServer:Boolean = true;
			if(highscores[artist + "_" + track + "_" + difficulty] == null){
				localHighscore.score = score;
				localHighscore.requiresSyncWithServer = true;
				highscores[artist + "_" + track + "_" + difficulty] = localHighscore;
				saveHighscore();
			}
			else if(highscores[artist + "_" + track + "_" + difficulty].score >= score){
				if(highscores[artist + "_" + track + "_" + difficulty].requiresSyncWithServer){
					postedSavedScore = true;
					score = highscores[artist + "_" + track + "_" + difficulty].score;
				}
				else{
					shouldPostScoreToServer = false;
					highscores[artist + "_" + track + "_" + difficulty].newHighscore = false;
					highscoreDataSignal.dispatch(HighscoreEvent.NO_NEW_HIGHSCORE, convertServerScoreVOtoClientVO(highscores[artist + "_" + track + "_" + difficulty]));
					return;
				}
			}

			if(DynamicConstants.IS_CONNECTED && shouldPostScoreToServer && FacebookManager.getInstance().checkIfUserIsLoggedIn() || FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
				
				var obj:Object = new Object();
				obj.trackkey = artist+"_"+track;
				obj.fb_id = facebookID;
				obj.score = score;
				obj.trackname = track;
				obj.artist = artist;
				
				PUT(new NetResponceHandler(onHighscorePosted, onHighscorePostFailed), obj.trackkey, obj);
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
				if(highscores[artist + "_" + track + "_" + difficulty].score < score){
					highscores[artist + "_" + track + "_" + difficulty] = localHighscore;
					saveHighscore();
				}
				
				highscoreDataSignal.dispatch(HighscoreEvent.NEW_HIGHSCORE, localHighscore);
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
					highscores[localHighscore.track + "_" + localHighscore.artist + "_" + localHighscore.difficulty] == localHighscore;
					saveHighscore();
					highscoreDataSignal.dispatch(HighscoreEvent.NEW_HIGHSCORE, localHighscore);
				}
				else{
					highscoreDataSignal.dispatch(HighscoreEvent.NO_NEW_HIGHSCORE, localHighscore);
				}
			}
		}
		
		private function onHighscorePostFailed():void{
			LOG.error("There was a problem posting the score to the server");
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
				if(highscores[artist + "_" + track + "_" + difficulty].score < score){
					highscores[artist + "_" + track + "_" + difficulty] = localHighscore;
					saveHighscore();
					highscoreDataSignal.dispatch(HighscoreEvent.NEW_HIGHSCORE, localHighscore);
				 }
				else{
					highscoreDataSignal.dispatch(HighscoreEvent.NO_NEW_HIGHSCORE, convertServerScoreVOtoClientVO(highscores[artist + "_" + track + "_" + difficulty]));
				}
				
			}
			catch(e:Error){
				LOG.error("GameProxy was removed before the post highscore could respond (HANDLED)");
				highscoreDataSignal.dispatch();
			}
		}
		
		private function convertServerScoreVOtoClientVO(serverVO:ServerScoreVO):HighscoreServerVO{
			var localHighscore:HighscoreServerVO = new HighscoreServerVO();
			localHighscore.artist = highscores[serverVO.trackkey + "_" + 0].artist;
			localHighscore.track = highscores[serverVO.trackkey + "_" + 0].track;
			localHighscore.newHighscore = (highscores[serverVO.trackkey + "_" + 0].score != serverVO.score);
			localHighscore.rank = serverVO.rank;
			localHighscore.score = serverVO.score;
			localHighscore.difficulty = 0;
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

