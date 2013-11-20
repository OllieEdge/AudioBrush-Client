package com.edgington.net
{
	import com.edgington.constants.FacebookConstants;
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
			GET(new NetResponceHandler(onTrackListingLatestSuccess, onTrackListingLatestFailed), true, "", "latest");
		}
		
		public function getPopularTracks(amountToList:int):void{
			GET(new NetResponceHandler(onTrackListingPopularSuccess, onTrackListingPopularSuccess), true, "", "popular");
		}
		
		public function getTournamentTracks():void{
			GET(new NetResponceHandler(onTrackListingTournamentSuccess, onTrackListingTournamentFailed), true, "", "tournaments");
		}
		
		public function getFriendsTracks(searchCriteria:String = ""):void{
			if(FacebookManager.getInstance().checkIfUserIsLoggedIn() /*|| FacebookConstants.DEBUG_FACEBOOK_ALLOWED*/){
				var friends:Array = new Array();
				
//				if(FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
//					friends = FacebookConstants.DEBUG_USER_FRIENDS;
//				}
//				else{
					for(var i:int = 0; i < FacebookManager.getInstance().currentLoggedInUserFriendsWithInstall.length; i++){
						friends.push(FacebookManager.getInstance().currentLoggedInUserFriendsWithInstall[i].id);
					}
//				}
				
				if(friends.length > 0){
					if(friends.length == 1){
						friends.push(0);
					}
					var obj:Object = new Object();
					obj.friends = friends;
					if(searchCriteria != ""){
						friendSearch = true;
						POST(new NetResponceHandler(onTrackListingFriendsSuccess, onTrackListingFriendsFailed), "", obj, "related");
					}
					else{
						POST(new NetResponceHandler(onTrackListingFriendsSuccess, onTrackListingFriendsFailed), "", obj, "related");
					}
				}
				else{
					responceSignal.dispatch(HighscoreEvent.TRACK_LISTING_NO_FACEBOOK, null);
				}
			}
			else{
				responceSignal.dispatch(HighscoreEvent.TRACK_LISTING_NO_FACEBOOK, null);
			}
		}
		
		public function getSearchedTracks(searchCriteria:String):void{
			GET(new NetResponceHandler(onTrackListingSearchSuccess, onTrackListingSearchFailed), true, "", "search/" + searchCriteria);
		}
		
		private function onTrackListingSearchSuccess(e:Object = null):void{
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
		
		private function onTrackListingSearchFailed():void{
			LOG.error("There was a problem getting the track listing");
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
		
		private function onTrackListingLatestFailed():void{
			LOG.error("There was a problem getting the track listing");
		}
		
		private function onTrackListingFriendsSuccess(e:Object = null):void{
			if(e && e.length > 0){
				latestTrackListing = new Vector.<ServerTrackVO>;
				for(var i:int = 0; i < e.length; i++){
					if(ServerTrackVO.checkObject(e[i])){
						latestTrackListing.push(new ServerTrackVO(e[i]));
					}
				}
				if(friendSearch){
					friendSearch = false;
					responceSignal.dispatch(HighscoreEvent.TRACK_LISTING_FRIENDS_SEARCH, latestTrackListing);
				}
				else{
					responceSignal.dispatch(HighscoreEvent.TRACK_LISTING_FRIENDS, latestTrackListing);	
				}
			}
			else{
				if(e && e.length == 0){
					LOG.warning("There were no tracks to return form the server");
				}
				else{
					LOG.error("Something went wrong with the response from the server.");
				}
				responceSignal.dispatch(HighscoreEvent.TRACK_LISTING_FRIENDS, new Vector.<ServerTrackVO>);
			}
		}
		
		private function onTrackListingFriendsFailed():void{
			LOG.error("There was a problem getting the track listing");
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
		
		private function onTrackListingPopularFailed():void{
			LOG.error("There was a problem getting the track listing");
		}
		
		
		private function onTrackListingTournamentSuccess(e:Array):void{
			if(e && e.length > 0){
				latestTrackListing = new Vector.<ServerTrackVO>;
				for(var i:int = 0; i < e.length; i++){
					if(ServerTrackVO.checkObject(e[i])){
						latestTrackListing.push(new ServerTrackVO(e[i]));
					}
				}
				responceSignal.dispatch(HighscoreEvent.TRACK_LISTING_TOURNAMENT, latestTrackListing);
			}
			else{
				if(e.length == 0){
					LOG.warning("There were no tracks to return form the server");
				}
				else{
					LOG.error("Something went wrong with the response from the server.");
				}
				responceSignal.dispatch(HighscoreEvent.TRACK_LISTING_TOURNAMENT, new Vector.<ServerTrackVO>);
			}
		}
		
		private function onTrackListingTournamentFailed():void{
			LOG.error("There was a problem getting the track listing");
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