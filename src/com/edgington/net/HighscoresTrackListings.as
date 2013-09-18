package com.edgington.net
{
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.net.events.HighscoreEvent;
	import com.edgington.net.helpers.NetResponceHandler;
	import com.edgington.util.debug.LOG;
	import com.edgington.valueobjects.net.ServerTrackVO;
	
	import flash.net.NetConnection;
	import flash.net.Responder;
	
	import org.osflash.signals.Signal;
	
	public class HighscoresTrackListings extends BaseData
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
		
		private var latestTrackListing:Vector.<ServerTrackVO>;
		
		public function HighscoresTrackListings()
		{
			super("track", "tracks");
			LOG.create(this);
			
			responceSignal = new Signal();
		}
		
		public function getLatestTracks(amountToList:int):void{
			GET(new NetResponceHandler(onTrackListingLatestSuccess, onTrackListingLatestFailed), true);
		}
		
		public function getPopularTracks(amountToList:int):void{
			GET(new NetResponceHandler(onTrackListingPopularSuccess, onTrackListingPopularSuccess), true);
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
				responceSignal.dispatch(HighscoreEvent.TRACK_LISTING_NO_FACEBOOK, null);
			}
		}
		
		public function getSearchedTracks(searchCriteria:String):void{
			GET(new NetResponceHandler(onTrackListingSearchSuccess, onTrackListingSearchFailed), true, "", "search/" + searchCriteria);
		}
		
		private function onTrackListingSearchSuccess(e:Object):void{
			if(e && e.length > 0){
				latestTrackListing = new Vector.<ServerTrackVO>;
				for(var i:int = 0; i < e.length; i++){
					if(ServerTrackVO.checkObject(e[i])){
						latestTrackListing.push(new ServerTrackVO(e[i]));
					}
				}
				responceSignal.dispatch(HighscoreEvent.TRACK_LISTING_LATEST_SEARCH, latestTrackListing);
				responceSignal.dispatch(HighscoreEvent.TRACK_LISTING_POPULAR_SEARCH, latestTrackListing);
			}
			else{
				if(e.length == 0){
					LOG.warning("There were no tracks to return form the server");
				}
				else{
					LOG.error("Something went wrong with the response from the server.");
				}
				responceSignal.dispatch(HighscoreEvent.TRACK_LISTING_LATEST_SEARCH, new Vector.<ServerTrackVO>);
				responceSignal.dispatch(HighscoreEvent.TRACK_LISTING_POPULAR_SEARCH, new Vector.<ServerTrackVO>);
			}
		}
		
		private function onTrackListingSearchFailed(e:Object):void{
			LOG.error("UserData: " + e.description);
		}
		
		private function onTrackListingLatestSuccess(e:Object = null):void{
			if(e && e.length > 0){
				latestTrackListing = new Vector.<ServerTrackVO>;
				for(var i:int = 0; i < e.length; i++){
					if(ServerTrackVO.checkObject(e[i])){
						latestTrackListing.push(new ServerTrackVO(e[i]));
					}
				}
				responceSignal.dispatch(HighscoreEvent.TRACK_LISTING_LATEST, latestTrackListing);
			}
			else{
				if(e.length == 0){
					LOG.warning("There were no tracks to return form the server");
				}
				else{
					LOG.error("Something went wrong with the response from the server.");
				}
				responceSignal.dispatch(HighscoreEvent.TRACK_LISTING_LATEST, new Vector.<ServerTrackVO>);
			}
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
			if(e && e.length > 0){
				latestTrackListing = new Vector.<ServerTrackVO>;
				for(var i:int = 0; i < e.length; i++){
					if(ServerTrackVO.checkObject(e[i])){
						latestTrackListing.push(new ServerTrackVO(e[i]));
					}
				}
				responceSignal.dispatch(HighscoreEvent.TRACK_LISTING_POPULAR, latestTrackListing);
			}
			else{
				if(e.length == 0){
					LOG.warning("There were no tracks to return form the server");
				}
				else{
					LOG.error("Something went wrong with the response from the server.");
				}
				responceSignal.dispatch(HighscoreEvent.TRACK_LISTING_POPULAR, new Vector.<ServerTrackVO>);
			}
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