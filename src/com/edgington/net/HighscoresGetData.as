package com.edgington.net
{
	import com.edgington.NativeMediaManager.NativeMediaVO;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.FacebookConstants;
	import com.edgington.ipodlibrary.ILMediaItem;
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.net.events.HighscoreEvent;
	import com.edgington.net.helpers.NetResponceHandler;
	import com.edgington.util.debug.LOG;
	import com.edgington.valueobjects.net.ServerScoreVO;
	
	import flash.net.NetConnection;
	import flash.net.Responder;
	
	import org.osflash.signals.Signal;

	public class HighscoresGetData extends BaseData
	{
		
		private var netConnection:NetConnection;
		
		private const CALL_GET_TOP_X:String = "highscores.HighscoresManager.getTopX";
		private const CALL_GET_FRIEND_SCORES:String = "highscores.HighscoresManager.getFriendScores";
		
		private var TopXResponder:Responder;
		private var FriendScoresResponder:Responder;
		
		public var responceSignal:Signal;
		
		public function HighscoresGetData()
		{
			super("scores", "scores");
			LOG.create(this);
			
			FriendScoresResponder = new Responder(onFriendScoresRecevied, onFriendScoresFailed);
			responceSignal = new Signal();
		}
		
		public function getTopX(amountOfResults:int, trackDetails:ILMediaItem, difficulty:int):void{
			if(DynamicConstants.IS_CONNECTED){
				
				var regExp:RegExp=new RegExp(/[^a-zA-Z 0-9]+|\s/g);
				var track:String = trackDetails.trackTitle.replace(regExp, "").toLowerCase();
				var artist:String = trackDetails.artist.replace(regExp, "").toLowerCase();
				
				var obj:Object = new Object();
				obj.limit = amountOfResults;
				
				POST(new NetResponceHandler(onTopXReceived, onTopXFailed), artist+"_"+track, obj);
			}
		}
		
		public function getTopXWithTrackkey(amountOfResults:int, trackkey:String):void{
			if(DynamicConstants.IS_CONNECTED){
				
				var obj:Object = new Object();
				obj.limit = amountOfResults;
				
				POST(new NetResponceHandler(onTopXReceived, onTopXFailed), trackkey, obj);
			}
		}
		
		public function getFriendsScores(amountOfResults:int, trackDetails:ILMediaItem, difficulty:int):void{
			if(DynamicConstants.IS_CONNECTED && FacebookManager.getInstance().checkIfUserIsLoggedIn()/* || FacebookConstants.DEBUG_FACEBOOK_ALLOWED*/){
				var friendIDs:Array = new Array();
				
//				if(FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
//					friendIDs = FacebookConstants.DEBUG_USER_FRIENDS.concat();
//				}
//				else{
					friendIDs.push(FacebookManager.getInstance().currentLoggedInUser.id);
					for(var i:int = 0; i < FacebookManager.getInstance().currentLoggedInUserFriendsWithInstall.length; i++){
						friendIDs.push(FacebookManager.getInstance().currentLoggedInUserFriendsWithInstall[i].id);
					}
//				}
				
				var regExp:RegExp=new RegExp(/[^a-zA-Z 0-9]+|\s/g);
				var track:String = trackDetails.trackTitle.replace(regExp, "").toLowerCase();
				var artist:String = trackDetails.artist.replace(regExp, "").toLowerCase();
				
				var obj:Object = new Object();
				obj.friends = friendIDs;
				
				POST(new NetResponceHandler(onFriendScoresRecevied, onFriendScoresFailed), "related/"+artist+"_"+track, obj);
			}
			else{
				responceSignal.dispatch(HighscoreEvent.NO_FRIENDS_WITH_HIGHSCORES);
			}
		}
		
		public function getFriendsScoresWithTrackkey(amountOfResults:int, trackkey:String):void{
			if(DynamicConstants.IS_CONNECTED && FacebookManager.getInstance().checkIfUserIsLoggedIn()/* || FacebookConstants.DEBUG_FACEBOOK_ALLOWED*/){
				var friendIDs:Array = new Array();
				
				//				if(FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
				//					friendIDs = FacebookConstants.DEBUG_USER_FRIENDS.concat();
				//				}
				//				else{
				friendIDs.push(FacebookManager.getInstance().currentLoggedInUser.id);
				for(var i:int = 0; i < FacebookManager.getInstance().currentLoggedInUserFriendsWithInstall.length; i++){
					friendIDs.push(FacebookManager.getInstance().currentLoggedInUserFriendsWithInstall[i].id);
				}
				//				}
				
				var obj:Object = new Object();
				obj.friends = friendIDs;
				
				POST(new NetResponceHandler(onFriendScoresRecevied, onFriendScoresFailed), "related/"+trackkey, obj);
			}
			else{
				responceSignal.dispatch(HighscoreEvent.NO_FRIENDS_WITH_HIGHSCORES);
			}
		}
		
		private function onFriendScoresRecevied(e:Object = null):void{
			if(responceSignal){
				if(e && e.length > 0){
					var scores:Vector.<ServerScoreVO> = new Vector.<ServerScoreVO>;
					for(var i:int = 0; i < e.length; i++){
						if(ServerScoreVO.checkObject(e[i])){
							var scr:ServerScoreVO = new ServerScoreVO(e[i]);
							scr.rank = i+1;
							scores.push(scr);
						}
					}
					
					responceSignal.dispatch(HighscoreEvent.FRIEND_HIGHSCORES_RECEIVED, scores);
				}
				else{
					if(e == null){
						LOG.error("There was an error in retrieving the scores on the server");
					}
					else if(e.length == 0){
						LOG.warning("Track requested does not contain any scores");
					}
					else{
						LOG.error("There is something wrong with the format of the scores that were sent back.");
					}
					responceSignal.dispatch(HighscoreEvent.FRIEND_HIGHSCORES_RECEIVED, new Vector.<ServerScoreVO>);
				}
			}
		}
		
		private function onFriendScoresFailed():void{
			if(responceSignal){
				LOG.error("There was a problem getting the scores from the server");
				responceSignal.dispatch(HighscoreEvent.HIGHSCORES_FAILED);
			}
		}
		
		private function onTopXReceived(e:Object = null):void{
			if(e && e.length > 0){
				var scores:Vector.<ServerScoreVO> = new Vector.<ServerScoreVO>;
				for(var i:int = 0; i < e.length; i++){
					if(ServerScoreVO.checkObject(e[i])){
						var scr:ServerScoreVO = new ServerScoreVO(e[i]);
						scr.rank = i+1;
						scores.push(scr);
					}
				}
				
				responceSignal.dispatch(HighscoreEvent.TOP_X_RECEVIED, scores);
			}
			else{
				if(e == null){
					LOG.error("There was an error in retrieving the scores on the server");
				}
				else if(e.length == 0){
					LOG.warning("Track requested does not contain any scores");
				}
				else{
					LOG.error("There is something wrong with the format of the scores that were sent back.");
				}
				responceSignal.dispatch(HighscoreEvent.TOP_X_RECEVIED, new Vector.<ServerScoreVO>);
			}
		}
		
		private function onTopXFailed():void{
			LOG.error("There was a problem getting the scores from the server");
			responceSignal.dispatch(HighscoreEvent.HIGHSCORES_FAILED);
		}
		
		private function connectionErrorHandler():void{
			LOG.error("There was a problem getting the scores from the server");
			responceSignal.dispatch(HighscoreEvent.HIGHSCORES_FAILED);
		}
		
		public function destroy():void{
			responceSignal.removeAll();
			responceSignal = null;
		}
	}
}