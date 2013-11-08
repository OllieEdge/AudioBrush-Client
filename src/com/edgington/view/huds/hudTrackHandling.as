package com.edgington.view.huds
{
	import com.edgington.constants.Constants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.ipodlibrary.ILMediaItem;
	import com.edgington.model.audio.AudioFileCacher;
	import com.edgington.model.audio.AudioModel;
	import com.edgington.types.CollectionType;
	import com.edgington.types.DeviceTypes;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.IDCreator;
	import com.edgington.util.TextFieldManager;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.valueobjects.AudioBrushMediaItemVO;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_mainButton;
	import com.edgington.view.huds.elements.trackselection.element_collectionSelectionTitle;
	import com.edgington.view.huds.elements.trackselection.element_collectionTypeSelection;
	import com.edgington.view.huds.elements.trackselection.element_collectionsList;
	import com.edgington.view.huds.elements.trackselection.element_mediaItemList;
	import com.edgington.view.huds.elements.trackselection.element_searchBar;
	import com.edgington.view.huds.elements.trackselection.element_trackSelectionContainer;
	import com.edgington.view.huds.vo.CollectionListingItemVO;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Dictionary;
	
	import org.osflash.signals.Signal;
	
	public class hudTrackHandling extends AbstractHud implements IAbstractHud
	{
		
		private var readyToRemoveSignal:Signal;
		private var buttonOptions:Vector.<String> = new <String>["BACK", "PLAY"];
		
		private var background:element_trackSelectionContainer;
		
		private var backButton:element_mainButton;
		private var playButton:element_mainButton;
		
		private var searchBar:element_searchBar;
		private var searchSignal:Signal;
		
		private var collectionSwitcher:element_collectionTypeSelection
		private var collectionListing:element_collectionsList;
		private var collectionChangeSignal:Signal;
		private var collectionSwitcherMargin:int;
		
		private var itemsListing:element_mediaItemList;
		private var itemChangedListing:Signal;
		
		private var selectedCollectionTitle:element_collectionSelectionTitle;
		
		private var collections:Vector.<CollectionListingItemVO>;
		private var items:Vector.<AudioBrushMediaItemVO>;
		
		private var collectionSignalHandler:Signal;
		
		private var collectionHeadingHolder:Sprite;
		private var collectionHeadingText:TextField;
		
		private var currentSearch:String = "";
		private var currentSelectedColleciton:CollectionListingItemVO;
		
		private var currentSelectedTrack:AudioBrushMediaItemVO;
		
		public function hudTrackHandling(removeSignal:Signal)
		{
			super();
			
			collections = new Vector.<CollectionListingItemVO>;
			var artists:Dictionary = AudioModel.getInstance().trackCollections.artistDictionary;
			for each(var vector:Vector.<ILMediaItem> in artists){
				collections.push(new CollectionListingItemVO(vector[0].artist, vector[0].album, "", vector[0].ipodID, vector.length, false));
			}
			
			readyToRemoveSignal = removeSignal;
			
			addListeners();
			
			setupVisuals();
			
			addElements();
			
			if(collections.length > 0){
				getItemsOfCollection(collections[0]);	
			}
		}
		
		public function addListeners():void
		{
			LOG.createCheckpoint("MENU: Track Selection");
			collectionChangeSignal = new Signal();
			searchSignal = new Signal();
			collectionChangeSignal.add(getCollection);
			searchSignal.add(handleSearch);
			collectionSignalHandler = new Signal();
			collectionSignalHandler.add(handleCollectionItemChange);
			itemChangedListing = new Signal();
			itemChangedListing.add(handleItemChange);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			superRemoveSignal.addOnce(readyForRemoval);
		}
		
		public function setupVisuals():void
		{
			
			background = new element_trackSelectionContainer(gettext("track_selection_description_label_1"));
			background.x = background.y = DynamicConstants.SCREEN_MARGIN;
			
			backButton = new element_mainButton(gettext("track_selection_back_button"), buttonOptions[0]);
			backButton.x = background.x;
			backButton.y = background.y + background.height + (DynamicConstants.BUTTON_SPACING*.5);
			
			collectionSwitcherMargin = 5 * DynamicConstants.DEVICE_SCALE;
			collectionSwitcher = new element_collectionTypeSelection(collectionChangeSignal, background.width*0.4);
			collectionSwitcher.x = background.x + (background.width*.5) - (background.width*0.4);
			collectionSwitcher.y = background.y + background.height - collectionSwitcher.height - collectionSwitcherMargin;
			
			collectionHeadingHolder = new Sprite();
			collectionHeadingText = TextFieldManager.createTextField(gettext("track_collection_heading_artists"), FONT_audiobrush_content_bold, Constants.DARK_FONT_COLOR, 14*DynamicConstants.DEVICE_SCALE, false, TextFieldAutoSize.CENTER);
			collectionHeadingHolder.addChild(collectionHeadingText);
			collectionHeadingHolder.x = background.x + (background.width*.25) - collectionHeadingHolder.width*.5;
			collectionHeadingHolder.y = background.y + background.getBodyOriginY() + (DynamicConstants.BUTTON_SPACING*.5);
			
			searchBar = new element_searchBar(searchSignal);
			searchBar.width = (background.width*.5)-(DynamicConstants.BUTTON_SPACING*1.5);
			searchBar.scaleY = searchBar.scaleX;
			searchBar.x = background.x + DynamicConstants.BUTTON_SPACING;
			searchBar.y = collectionHeadingHolder.y + collectionHeadingHolder.height + (DynamicConstants.BUTTON_SPACING*.5);
			
			generateListingElement();
			
			selectedCollectionTitle = new element_collectionSelectionTitle(searchBar.y+searchBar.height - collectionHeadingHolder.y);
			selectedCollectionTitle.x = background.x + (background.width*.5) + (DynamicConstants.BUTTON_SPACING*.5);
			selectedCollectionTitle.y = background.y + background.getBodyOriginY() + (DynamicConstants.BUTTON_SPACING*.5);
			
			addButton(backButton);
			
			buttonSignal.add(handleInteraction);
			
			onScreenElements.push(background, backButton, collectionListing, collectionSwitcher, collectionHeadingHolder, selectedCollectionTitle, searchBar);
		}
		
		private function getCollection():void{
			switch(collectionSwitcher.currentCollectionTypeSelected){
				case CollectionType.ARTISTS:
					collectionHeadingText.text = gettext("track_collection_heading_artists");
					collections = new Vector.<CollectionListingItemVO>;
					var artists:Dictionary = AudioModel.getInstance().trackCollections.artistDictionary;
					for each(var vector:Vector.<ILMediaItem> in artists){
						collections.push(new CollectionListingItemVO(vector[0].artist, vector[0].album, vector[0].playlist, vector[0].ipodID, vector.length, false));
					}
					break;
				case CollectionType.ALBUMS:
					collectionHeadingText.text = gettext("track_collection_heading_albums");
					collections = new Vector.<CollectionListingItemVO>;
					var albums:Dictionary = AudioModel.getInstance().trackCollections.albumDictionary;
					for each(var albumVec:Vector.<ILMediaItem> in albums){
						collections.push(new CollectionListingItemVO(albumVec[0].artist, albumVec[0].album, albumVec[0].playlist, albumVec[0].ipodID, albumVec.length, false));
					}
					break;
				case CollectionType.PLAYLISTS:
					collectionHeadingText.text = gettext("track_collection_heading_playlists");
					collections = new Vector.<CollectionListingItemVO>;
					var playlists:Dictionary = AudioModel.getInstance().trackCollections.playlistsDictionary;
					for each(var playlistVec:Vector.<ILMediaItem> in playlists){
						collections.push(new CollectionListingItemVO(playlistVec[0].artist, playlistVec[0].album, playlistVec[0].playlist, playlistVec[0].ipodID, playlistVec.length, false));
					}
					break;
				default:
					if(collectionSwitcher.currentCollectionTypeSelected == CollectionType.SPOTIFY){
						collectionHeadingText.text = gettext("track_collection_heading_spotify");
					}
					collections = new Vector.<CollectionListingItemVO>;
					var defaultDic:Dictionary = AudioModel.getInstance().trackCollections.artistDictionary;
					for each(var defaultVec:Vector.<ILMediaItem> in defaultDic){
						collections.push(new CollectionListingItemVO(defaultVec[0].artist, defaultVec[0].album, "", defaultVec[0].ipodID, defaultVec.length, false));
					}
					break;
			}
			
			removeSeperateElements(collectionListing);
			
			generateListingElement();
			
			addAdditionalElements(new <Sprite>[collectionListing]);
		}
		
		/**
		 * This generates the list of collections
		 */
		private function generateListingElement():void{
			var itemHeight:Number = background.height - background.getBodyOriginY() - searchBar.height - collectionHeadingHolder.height - collectionSwitcher.height - (DynamicConstants.BUTTON_SPACING*2);
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
				collectionListing = new element_collectionsList(collections, 5, itemHeight/5, (background.width*.5)-(DynamicConstants.BUTTON_SPACING*1.5), collectionSignalHandler, collectionSwitcher.currentCollectionTypeSelected);
			}
			else{
				collectionListing = new element_collectionsList(collections, 10, itemHeight/10, (background.width*.5)-(DynamicConstants.BUTTON_SPACING*1.5), collectionSignalHandler, collectionSwitcher.currentCollectionTypeSelected);
			}
			collectionListing.x = background.x + DynamicConstants.BUTTON_SPACING;
			collectionListing.y = (searchBar.y+searchBar.height) + (DynamicConstants.BUTTON_SPACING*.5);
		}
		
		/**
		 * This generates the iteems of the collection selected
		 */
		private function getItemsOfCollection(collection:CollectionListingItemVO):void{
			items = new Vector.<AudioBrushMediaItemVO>;
			
			currentSelectedColleciton = collection;
			
			var collectionItems:Vector.<ILMediaItem>;
			var dictionary:Dictionary;
			switch(collectionSwitcher.currentCollectionTypeSelected){
				case CollectionType.ARTISTS:
					dictionary = AudioModel.getInstance().trackCollections.artistDictionary;
					break
				case CollectionType.ALBUMS:
					dictionary = AudioModel.getInstance().trackCollections.albumDictionary;
					break;
				case CollectionType.PLAYLISTS:
					dictionary = AudioModel.getInstance().trackCollections.playlistsDictionary;
					break;
				default:
					dictionary = AudioModel.getInstance().trackCollections.artistDictionary;
					break;
			}
			
			for each(var vector:Vector.<ILMediaItem> in dictionary){
				if(vector[0].ipodID == collection.id){
					collectionItems = vector;
					break;
				}
			}
			
			for(var i:int = 0; i < collectionItems.length; i++){
				
				if(currentSearch != ""){
					if(collectionSwitcher.currentCollectionTypeSelected == CollectionType.ALBUMS){
						if(collectionItems[i].album.toLowerCase().indexOf(currentSearch) == -1 &&  collectionItems[i].trackTitle.toLowerCase().indexOf(currentSearch) == -1){
							continue;
						}
					}
					else{
						if(collectionItems[i].artist.toLowerCase().indexOf(currentSearch) == -1 &&  collectionItems[i].trackTitle.toLowerCase().indexOf(currentSearch) == -1){
							continue;
						}
					}
				}
				
				var trackID:String = IDCreator.createTrackID(collectionItems[i].trackTitle, collectionItems[i].artist);
				if(AudioFileCacher.getInstance().checkCache(trackID)){
					items.push(AudioFileCacher.getInstance().getCachedItem(trackID));
					items[items.length-1].trackDetails = collectionItems[i];
				}
				else{
					var mediaItem:AudioBrushMediaItemVO = new AudioBrushMediaItemVO();
					mediaItem.trackID = collectionItems[i].ipodID;
					mediaItem.trackDetails = collectionItems[i];
					mediaItem.isLoaded = false;
					mediaItem.playCount = 0;
					mediaItem.difficulty = "";
					items.push(mediaItem);
				}
			}
			
			selectedCollectionTitle.changeCollectionType(collectionSwitcher.currentCollectionTypeSelected, collection);
			
			if(itemsListing){
				removeSeperateElements(itemsListing);
			}
			
			generateItemListingElements();
			
			addAdditionalElements(new <Sprite>[itemsListing]);
		}
		
		/**
		 * This generates the iteems of the collection selected
		 */
		private function generateItemListingElements():void{
			var itemHeight:Number = background.height - background.getBodyOriginY() - searchBar.height - collectionHeadingHolder.height - collectionSwitcher.height - (DynamicConstants.BUTTON_SPACING*2);
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
				itemsListing = new element_mediaItemList(items, 5, itemHeight/5, (background.width*.5)-(DynamicConstants.BUTTON_SPACING*1.5), itemChangedListing, collectionSwitcher.currentCollectionTypeSelected);
			}
			else{
				itemsListing = new element_mediaItemList(items, 10, itemHeight/10, (background.width*.5)-(DynamicConstants.BUTTON_SPACING*1.5), itemChangedListing, collectionSwitcher.currentCollectionTypeSelected);
			}
			itemsListing.x = background.x + (background.width*.5) + (DynamicConstants.BUTTON_SPACING*.5);
			itemsListing.y = (searchBar.y+searchBar.height) + (DynamicConstants.BUTTON_SPACING*.5);
		}
		
		private function handleSearch(searchCriteria:String = ""):void{
			playButtonSwitcher(false);
			LOG.debug("Search for: " + searchCriteria);
			
			currentSearch = searchCriteria.toLowerCase();
			if(currentSearch == ""){
				getCollection();
				getItemsOfCollection(currentSelectedColleciton);
				return;
			}
			
			switch(collectionSwitcher.currentCollectionTypeSelected){
				case CollectionType.ALBUMS:
					collectionHeadingText.text = gettext("track_collection_heading_albums");
					collections = new Vector.<CollectionListingItemVO>;
					var albums:Dictionary = AudioModel.getInstance().trackCollections.albumDictionary;
					for each(var albumVec:Vector.<ILMediaItem> in albums){
						var addedAlbum:Boolean = false;
						for(var al:int = 0; al < albumVec.length; al++){
							if(!addedAlbum && albumVec[al].album.toLowerCase().indexOf(currentSearch) != -1 ||  albumVec[al].trackTitle.toLowerCase().indexOf(currentSearch) != -1){
								collections.push(new CollectionListingItemVO(albumVec[0].artist, albumVec[0].album, albumVec[0].playlist, albumVec[0].ipodID, albumVec.length, false));		
								addedAlbum = true;
								break;
							}
						}
					}
					break;
				case CollectionType.PLAYLISTS:
					collectionHeadingText.text = gettext("track_collection_heading_playlists");
					collections = new Vector.<CollectionListingItemVO>;
					var playlists:Dictionary = AudioModel.getInstance().trackCollections.playlistsDictionary;
					for each(var playlistVec:Vector.<ILMediaItem> in playlists){
						var addedPlaylist:Boolean = false;
						for(var pl:int = 0; pl < playlistVec.length; pl++){
							if(!addedPlaylist && playlistVec[pl].album.toLowerCase().indexOf(currentSearch) != -1 ||  playlistVec[pl].trackTitle.toLowerCase().indexOf(currentSearch) != -1 || playlistVec[pl].artist.toLowerCase().indexOf(currentSearch) != -1){
								collections.push(new CollectionListingItemVO(playlistVec[0].artist, playlistVec[0].album, playlistVec[0].playlist, playlistVec[0].ipodID, playlistVec.length, false));		
								addedPlaylist = true;
								break;
							}
						}
					}
					break;
				default:
					collectionHeadingText.text = gettext("track_collection_heading_artists");
					collections = new Vector.<CollectionListingItemVO>;
					var artists:Dictionary = AudioModel.getInstance().trackCollections.artistDictionary;
					for each(var vector:Vector.<ILMediaItem> in artists){
						var addedArtist:Boolean = false;
						for(var ar:int = 0; ar < vector.length; ar++){
							if(!addedArtist && vector[ar].artist.toLowerCase().indexOf(currentSearch) != -1 ||  vector[ar].trackTitle.toLowerCase().indexOf(currentSearch) != -1){
								collections.push(new CollectionListingItemVO(vector[0].artist, vector[0].album, vector[0].playlist, vector[0].ipodID, vector.length, false));		
								addedArtist = true;
								break;
							}
						}
					}
					break;
			}
			
			removeSeperateElements(collectionListing);
			
			generateListingElement();
			
			addAdditionalElements(new <Sprite>[collectionListing]);
			
		}
		
		//When the a item in the collections list has been pressed
		private function handleCollectionItemChange(collection:CollectionListingItemVO):void{
			playButtonSwitcher(false);
			getItemsOfCollection(collection);
		}
		
		private function handleItemChange(mediaItem:AudioBrushMediaItemVO):void{
			currentSelectedTrack = mediaItem;
			playButtonSwitcher(true);
		}
		
		private function playButtonSwitcher(isOn:Boolean):void{
			if(isOn && playButton == null){
				playButton = new element_mainButton(gettext("track_selection_play_button"), buttonOptions[1]);
				playButton.x = background.x + background.width - playButton.width;
				playButton.y = background.y + background.height + (DynamicConstants.BUTTON_SPACING*.5);
				addButton(playButton);
				addAdditionalElements(new <Sprite>[playButton]);
			}
			else if(!isOn && playButton != null){
				removeButton(playButton);
				currentSelectedTrack = null;
				playButton = null;
			}
		}
		
		private function handleInteraction(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_MAIN;
					cleanButtons();
					break;
				case buttonOptions[1]:
					AudioModel.getInstance().currentTrackDetails = currentSelectedTrack.trackDetails;
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.GAME_LOADING;
					cleanButtons();
					break;
			}
		}
		
		public function readyForRemoval():void
		{
			super.destroy();
			readyToRemoveSignal.dispatch();
		}
		
		private function destroy(e:Event):void{
			searchSignal.removeAll();
			collectionChangeSignal.removeAll();
			itemChangedListing.removeAll();
			collectionSignalHandler.removeAll();

			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			
			readyToRemoveSignal = null;
			buttonOptions = null;
			
			background = null;
			
			backButton = null;
			playButton = null;
			
			searchBar = null;
			searchSignal = null;
			
			collectionSwitcher = null;
			collectionListing = null;
			collectionChangeSignal = null;
			
			itemsListing = null;
			itemChangedListing = null;
			
			selectedCollectionTitle = null;
			
			collections = null;
			items = null;
			
			collectionSignalHandler = null;
			
			collectionHeadingHolder = null;
			collectionHeadingText = null;
			
			currentSearch = null;
			currentSelectedColleciton = null;
			
			currentSelectedTrack = null;
			
			
		}
	}
}