package com.edgington.net
{
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.net.events.HighscoreEvent;
	import com.edgington.util.debug.LOG;
	
	import flash.net.NetConnection;
	import flash.net.Responder;
	
	import org.osflash.signals.Signal;
	
	public class HighscoresTrackListings
	{
		
		private var netConnection:NetConnection;
		
		private const CALL_GET_POPULAR_TRACKS:String = "highscores.HighscoresManager.getPopularTracks";
		private const CALL_GET_LATEST_TRACKS:String = "highscores.HighscoresManager.getLatestTracks";
		private const CALL_GET_FRIENDS_TRACKS:String = "highscores.HighscoresManager.getFriendsTracks";
		
		private const CALL_GET_SEARCHED_TRACKS:String = "highscores.HighscoresManager.searchForListings";
		
		private var TrackListingLatest:Responder;
		private var TrackListingPopular:Responder;
		private var TrackListingFriends:Responder;
		private var TrackListingSearch:Responder;
		
		public var responceSignal:Signal;
		
		private var friendSearch:Boolean = false;
		
		public function HighscoresTrackListings()
		{
			netConnection = NetManager.getInstance().netConnection;
			NetManager.getInstance().serverConnectionErrorSignal.add(connectionErrorHandler);
			
			TrackListingPopular = new Responder(onTrackListingPopularSuccess, onTrackListingPopularFailed);
			TrackListingLatest = new Responder(onTrackListingLatestSuccess, onTrackListingLatestFailed);
			TrackListingFriends = new Responder(onTrackListingFriendsSuccess, onTrackListingFriendsFailed);
			TrackListingSearch = new Responder(onTrackListingSearchSuccess, onTrackListingSearchFailed);
			
			responceSignal = new Signal();
		}
		
		public function getLatestTracks(amountToList:int):void{
			netConnection.call(CALL_GET_LATEST_TRACKS, TrackListingLatest, amountToList);
		}
		
		public function getPopularTracks(amountToList:int):void{
			netConnection.call(CALL_GET_POPULAR_TRACKS, TrackListingPopular, amountToList);
		}
		
		public function getFriendsTracks(searchCriteria:String = ""):void{
			if(FacebookManager.getInstance().checkIfUserIsLoggedIn()){
				var friends:Array = new Array();
				
				for(var i:int = 0; i < FacebookManager.getInstance().currentLoggedInUserFriendsWithInstall.length; i++){
					friends.push(FacebookManager.getInstance().currentLoggedInUserFriendsWithInstall[i].profileID);
				}
				
				if(searchCriteria != ""){
					friendSearch = true;
					netConnection.call(CALL_GET_FRIENDS_TRACKS, TrackListingFriends, friends, [searchCriteria]);
				}
				else{
					netConnection.call(CALL_GET_FRIENDS_TRACKS, TrackListingFriends, friends, [searchCriteria]);
				}
			}
			else{
				responceSignal.dispatch(HighscoreEvent.TRACK_LISTING_NO_FACEBOOK, []);
			}
		}
		
		public function getSearchedTracks(searchCriteria:String):void{
			netConnection.call(CALL_GET_SEARCHED_TRACKS, TrackListingSearch, [searchCriteria]);
		}
		
		private function onTrackListingSearchSuccess(e:Array):void{
			responceSignal.dispatch(HighscoreEvent.TRACK_LISTING_LATEST_SEARCH, e);
			responceSignal.dispatch(HighscoreEvent.TRACK_LISTING_POPULAR_SEARCH, e);
		}
		
		private function onTrackListingSearchFailed(e:Object):void{
			LOG.error("UserData: " + e.description);
		}
		
		private function onTrackListingLatestSuccess(e:Array):void{
			responceSignal.dispatch(HighscoreEvent.TRACK_LISTING_LATEST, e);
		}
		
		private function onTrackListingLatestFailed(e:Object):void{
			LOG.error("UserData: " + e.description);
		}
		
		private function onTrackListingFriendsSuccess(e:Array):void{
			if(friendSearch){
				friendSearch = false;
				responceSignal.dispatch(HighscoreEvent.TRACK_LISTING_FRIENDS_SEARCH, e);
			}
			else{
				responceSignal.dispatch(HighscoreEvent.TRACK_LISTING_FRIENDS, e);
			}
		}
		
		private function onTrackListingFriendsFailed(e:Object):void{
			LOG.error("UserData: " + e.description);
		}
		
		private function onTrackListingPopularSuccess(e:Array):void{
			responceSignal.dispatch(HighscoreEvent.TRACK_LISTING_POPULAR, e);
		}
		
		private function onTrackListingPopularFailed(e:Object):void{
			LOG.error("UserData: " + e.description);
		}
		
		private function connectionErrorHandler():void{
			responceSignal.dispatch(HighscoreEvent.HIGHSCORES_FAILED);
		}
		
		public function destroy():void{
			netConnection = null;
			NetManager.getInstance().serverConnectionErrorSignal.remove(connectionErrorHandler);
			TrackListingFriends = null;
			TrackListingLatest = null;
			TrackListingPopular = null;
			responceSignal.removeAll();
			responceSignal = null;
		}
	}
}