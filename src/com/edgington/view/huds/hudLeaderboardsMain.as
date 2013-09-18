package com.edgington.view.huds
{
	import com.edgington.NativeMediaManager.NativeMediaVO;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.SearchProxy;
	import com.edgington.net.HighscoresTrackListings;
	import com.edgington.net.events.HighscoreEvent;
	import com.edgington.types.DeviceTypes;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.valueobjects.net.ServerTrackVO;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_mainButton;
	import com.edgington.view.huds.elements.element_mainMiniButton;
	import com.edgington.view.huds.elements.element_searchIpad;
	import com.edgington.view.huds.elements.element_tabContainer;
	import com.edgington.view.huds.elements.element_trackListing;
	import com.edgington.view.huds.events.TabContainerEvent;
	import com.edgington.view.huds.vo.TrackListingVO;
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class hudLeaderboardsMain extends AbstractHud implements IAbstractHud
	{
		
		private var buttonOptions:Vector.<String> = new <String>["MAIN_MENU", "FRIENDS", "GLOBAL", "IPHONE_SEARCH", "CLEAR_SEARCH"];
		
		private var tabDescriptions:Vector.<String>;
		private var tabLabels:Vector.<String>;
		
		private var tabChangedSignal:Signal;
		private var searchSignal:Signal;
		private var trackSelectedSignal:Signal;
		
		private var tabContainer:element_tabContainer;
		
		private var backButton:element_mainButton;
		private var searchButton:element_mainButton;
		private var clearSearchButton:element_mainMiniButton;
		
		private var ipadSearchBox:element_searchIpad;
		
		private var loading:ui_loading;
		
		private var readyToRemoveSignal:Signal;
		
		private var latestTrackListing:Vector.<ServerTrackVO>;
		private var popularTrackListing:Vector.<ServerTrackVO>;
		private var	freindTrackListing:Vector.<ServerTrackVO>;
		
		private var searchLatestTrackListing:Vector.<ServerTrackVO>;
		private var searchPopularTrackListing:Vector.<ServerTrackVO>;
		private var	searchFreindTrackListing:Vector.<ServerTrackVO>;
		
		private var searchTrackListing:Array;
		
		private var highscoresTrackListingGetter:HighscoresTrackListings;
		
		private var amountToReturn:int = 50;
		
		private var currentTab:int = 0;
		
		private var listings:element_trackListing;
		
		public function hudLeaderboardsMain(removeSignal:Signal)
		{
			super();
			
			highscoresTrackListingGetter = new HighscoresTrackListings();
			readyToRemoveSignal = removeSignal;
			
			addListeners();
			
			setupVisuals();
			
			addElements();
		}
		
		public function addListeners():void
		{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			superRemoveSignal.addOnce(readyForRemoval);
			tabChangedSignal = new Signal();
			tabChangedSignal.add(handleTabChanged);
			highscoresTrackListingGetter.responceSignal.add(tracksListed);
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPAD){
				searchSignal = new Signal();
				searchSignal.add(handleSearch);
			}
			trackSelectedSignal = new Signal();
			trackSelectedSignal.add(trackSelected);
		}
		
		public function setupVisuals():void
		{
			LOG.createCheckpoint("Viewed Leaderboards");
			tabLabels = new Vector.<String>;
			tabDescriptions = new Vector.<String>;
			tabLabels.push(gettext("highscores_tab_latest_popular"), gettext("highscores_tab_latest"), gettext("highscores_tab_latest_friends"));
			tabDescriptions.push(gettext("highscores_tab_latest_popular_description"), gettext("highscores_tab_latest_description"), gettext("highscores_tab_latest_friends_description"));
			
			loading = new ui_loading();
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPAD){
				tabContainer = new element_tabContainer(tabLabels, tabChangedSignal, tabDescriptions, DynamicConstants.SCREEN_HEIGHT*.6);	
			}
			else{
				tabContainer = new element_tabContainer(tabLabels, tabChangedSignal, tabDescriptions, DynamicConstants.SCREEN_HEIGHT*.5);	
			}
			tabContainer.x = DynamicConstants.SCREEN_WIDTH*.5 - tabContainer.width*.5;
			tabContainer.y = DynamicConstants.SCREEN_MARGIN;
			backButton = new element_mainButton(gettext("highscores_back_button"), buttonOptions[0]);
			backButton.x = DynamicConstants.SCREEN_MARGIN;
			backButton.y = tabContainer.y + tabContainer.height + DynamicConstants.BUTTON_SPACING;
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
				searchButton = new element_mainButton(gettext("highscores_search_button"), buttonOptions[3]);
				searchButton.x = tabContainer.x + tabContainer.width - searchButton.width;
				searchButton.y = backButton.y;
				addButton(searchButton);
			}
			else{
				ipadSearchBox = new element_searchIpad(searchSignal);
				ipadSearchBox.x = tabContainer.x + tabContainer.width - ipadSearchBox.width;
				ipadSearchBox.y = tabContainer.y - ipadSearchBox.height;
				onScreenElements.push(ipadSearchBox);
			}
			
			listings = new element_trackListing(tabContainer.listingHeight, tabContainer.width, trackSelectedSignal);
			listings.x = tabContainer.x + tabContainer.listingX;
			listings.y = tabContainer.y + tabContainer.listingY;
			
			addButton(backButton);
			
			buttonSignal.add(handleInteraction);
			
			onScreenElements.push(backButton, tabContainer, listings);
			if(searchButton != null){
				onScreenElements.push(searchButton);
			}
			if(SearchProxy.getInstance().isSearch){
				clearSearchButton = new element_mainMiniButton(gettext("highscores_clear_search"), buttonOptions[4]);
				if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
					clearSearchButton.x = tabContainer.x + tabContainer.width - clearSearchButton.width;
					clearSearchButton.y = tabContainer.y;
				}
				else{
					clearSearchButton.x = ipadSearchBox.x + ipadSearchBox.width - clearSearchButton.width;
					clearSearchButton.y = ipadSearchBox.y + ipadSearchBox.height + DynamicConstants.BUTTON_SPACING*0.25;
				}
				addButton(clearSearchButton);
				onScreenElements.push(clearSearchButton);
				TweenLite.delayedCall(1, highscoresTrackListingGetter.getSearchedTracks, [SearchProxy.getInstance().currentSearch]);
			}
			else{
				TweenLite.delayedCall(1, highscoresTrackListingGetter.getPopularTracks, [amountToReturn]);
			}
		}
		
		private function handleSearch(str:String):void{
			clearSearchButton = new element_mainMiniButton(gettext("highscores_clear_search"), buttonOptions[4]);
			clearSearchButton.x = ipadSearchBox.x + ipadSearchBox.width - clearSearchButton.width;
			clearSearchButton.y = ipadSearchBox.y + ipadSearchBox.height + DynamicConstants.BUTTON_SPACING*0.25;
			addButton(clearSearchButton);
			addAdditionalElements(new <Sprite>[clearSearchButton]);
			SearchProxy.getInstance().currentSearch = str;
			SearchProxy.getInstance().isSearch = true;
			handleTabChanged(TabContainerEvent.TAB_CHANGED, tabLabels[currentTab]);
		}
		
		private function tracksListed(eventType:String, tracks:Vector.<ServerTrackVO>):void{
			switch(eventType){
				case HighscoreEvent.TRACK_LISTING_POPULAR:
						popularTrackListing = tracks.concat();
						if(currentTab == 0){
							addTrackListing();
						}
					break;
				case HighscoreEvent.TRACK_LISTING_LATEST:
						latestTrackListing = tracks.concat();
						if(currentTab == 1){
							addTrackListing();
						}
					break;
				case HighscoreEvent.TRACK_LISTING_FRIENDS:
						freindTrackListing = tracks.concat();
						if(currentTab == 2){
							addTrackListing();
						}
					break;
				case HighscoreEvent.TRACK_LISTING_POPULAR_SEARCH:
						searchPopularTrackListing = tracks.concat();
						if(currentTab == 0){
							addTrackListing();
						}
					break;
				case HighscoreEvent.TRACK_LISTING_LATEST_SEARCH:
						searchLatestTrackListing = tracks.concat();
						if(currentTab == 1){
							addTrackListing();
						}
					break;
				case HighscoreEvent.TRACK_LISTING_FRIENDS_SEARCH:
						searchFreindTrackListing = tracks.concat();
						if(currentTab == 2){
							addTrackListing();
						}
					break;
				case HighscoreEvent.TRACK_LISTING_NO_FACEBOOK:
						listings.addErrorMessage(gettext("highscores_not_available_without_facebook"));
					break;
			}
		}
		
		private function handleTabChanged(eventType:String, tabLabel:String = ""):void{
			switch(eventType){
				case TabContainerEvent.TAB_CHANGED:
					listings.addLoading();
					switch(tabLabel)
					{
						case tabLabels[0]:
							currentTab = 0;
							if(popularTrackListing == null && !SearchProxy.getInstance().isSearch){
								highscoresTrackListingGetter.getPopularTracks(amountToReturn);
							}
							else if(searchPopularTrackListing == null && SearchProxy.getInstance().isSearch){
								highscoresTrackListingGetter.getSearchedTracks(SearchProxy.getInstance().currentSearch);
							}
							else{
								addTrackListing();
							}
							break;
						case tabLabels[1]:
							currentTab = 1;
							if(latestTrackListing == null && !SearchProxy.getInstance().isSearch){
								highscoresTrackListingGetter.getLatestTracks(amountToReturn);
							}
							else if(searchLatestTrackListing == null && SearchProxy.getInstance().isSearch){
								highscoresTrackListingGetter.getSearchedTracks(SearchProxy.getInstance().currentSearch);
							}
							else{
								addTrackListing();
							}
							break;
						case tabLabels[2]:
							currentTab = 2;
							if(freindTrackListing == null && !SearchProxy.getInstance().isSearch){
								highscoresTrackListingGetter.getFriendsTracks();
							}
							else if(searchFreindTrackListing == null && SearchProxy.getInstance().isSearch){
								highscoresTrackListingGetter.getFriendsTracks(SearchProxy.getInstance().currentSearch);	
							}
							else{
								addTrackListing();
							}
							break;
					}
					break;
			}
		}
		
		private function addTrackListing():void{
			var currentArray:Vector.<ServerTrackVO>;;
			if(SearchProxy.getInstance().isSearch){
				switch(currentTab){
					case 0:
						currentArray = searchPopularTrackListing.concat();					
						break;
					case 1:
						currentArray = searchLatestTrackListing.concat();
						break;
					case 2:
						currentArray = searchFreindTrackListing.concat();
						break;
				}
			}
			else{
				switch(currentTab){
					case 0:
						currentArray = popularTrackListing.concat();					
						break;
					case 1:
						currentArray = latestTrackListing.concat();
						break;
					case 2:
						currentArray = freindTrackListing.concat();
						break;
				}
			}
			listings.addTrackListing(currentArray);
		}
		
		private function handleInteraction(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_MAIN;
					cleanButtons();
					break;
				case buttonOptions[1]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.SUMMARY_DETAILS;
					cleanButtons();
					break;
				case buttonOptions[2]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.SUMMARY_HIGHSCORES;
					cleanButtons();
					break;
				case buttonOptions[3]:
					LOG.createCheckpoint("Searched for Artist/Track");
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.HIGHSCORES_IPHONE_SEARCH;
					cleanButtons();
					break;
				case buttonOptions[4]:
					searchFreindTrackListing = null;
					searchLatestTrackListing = null;
					searchPopularTrackListing = null;
					SearchProxy.getInstance().isSearch = false;
					handleTabChanged(TabContainerEvent.TAB_CHANGED, tabLabels[currentTab]);
					if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPAD){
						ipadSearchBox.refreshSearch();
					}
					break;
			}
		}
		
		private function trackSelected(trackDetails:TrackListingVO):void{
			var trackDetailsVO:NativeMediaVO = new NativeMediaVO();
			trackDetailsVO.artistName = trackDetails.artist;
			trackDetailsVO.trackTitle = trackDetails.trackName;
			SearchProxy.getInstance().currentTrack = trackDetailsVO;
			
			DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.HIGHSCORES_TRACK;
			cleanButtons();
		}
		
		public function readyForRemoval():void
		{
			super.destroy();
			readyToRemoveSignal.dispatch();
		}
		
		private function destroy(e:Event):void{
			SearchProxy.getInstance().isSearch = false;
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			backButton = null;
			searchButton = null;
			clearSearchButton = null;
			ipadSearchBox = null;
		}
	}
}