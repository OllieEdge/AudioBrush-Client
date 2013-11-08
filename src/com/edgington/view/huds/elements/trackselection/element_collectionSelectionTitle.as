package com.edgington.view.huds.elements.trackselection
{
	import com.edgington.constants.Constants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.net.TrackData;
	import com.edgington.types.CollectionType;
	import com.edgington.util.TextFieldManager;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.vo.CollectionListingItemVO;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class element_collectionSelectionTitle extends Sprite
	{
		
		private var artwork:ui_profile_artwork;
		
		private var _height:int;
		
		private var trackCollectionPrefixTitle:TextField;
		private var trackCollectionTitle:TextField;
		
		public function element_collectionSelectionTitle(_height:int)
		{
			super();
			
			this._height = _height;
			
			addListeners();
			
			setupVisuals();
		}
		
		private function addListeners():void{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		private function setupVisuals():void{
			artwork = new ui_profile_artwork();
			artwork.height = artwork.width = _height;
			this.addChild(artwork);
			
			trackCollectionPrefixTitle = TextFieldManager.createTextField(gettext("tract_collection_title_artist_prefix"), FONT_audiobrush_content_bold, Constants.DARK_FONT_COLOR, _height*.3, false, TextFieldAutoSize.LEFT);
			trackCollectionTitle = TextFieldManager.createTextField(gettext("tract_collection_title_artist_none"), FONT_audiobrush_content_bold, Constants.DARK_FONT_COLOR, _height*.45, false, TextFieldAutoSize.LEFT);
			
			trackCollectionPrefixTitle.x = artwork.x + artwork.width + (4*DynamicConstants.DEVICE_SCALE);
			trackCollectionPrefixTitle.y = artwork.y + (artwork.height*0.05);
			
			trackCollectionTitle.x = artwork.x + artwork.width + (4*DynamicConstants.DEVICE_SCALE);
			trackCollectionTitle.y = artwork.y + (artwork.height*0.4);
			
			trackCollectionPrefixTitle.cacheAsBitmap = true;
			trackCollectionTitle.cacheAsBitmap = true;
			
			this.addChild(trackCollectionPrefixTitle);
			this.addChild(trackCollectionTitle);
		}
		
		public function changeCollectionType(collectionType:String, collectionName:CollectionListingItemVO):void{
			this.removeChild(artwork);
			artwork = null;
			artwork = new ui_profile_artwork();
			artwork.height = artwork.width = _height;
			this.addChild(artwork);
			
			switch(collectionType){
				case CollectionType.ARTISTS:
					trackCollectionPrefixTitle.text = gettext("tract_collection_title_artist_prefix");
					trackCollectionTitle.text = collectionName.artist;
					break;
				case CollectionType.ALBUMS:
					trackCollectionPrefixTitle.text = gettext("tract_collection_title_album_prefix");
					trackCollectionTitle.text = collectionName.album;
					break;
				case CollectionType.PLAYLISTS:
					trackCollectionPrefixTitle.text = gettext("tract_collection_title_playlist_prefix");
					trackCollectionTitle.text = collectionName.playlist;
					break;
				default:
					
					break;
			}
			new TrackData(new <String>[trackCollectionTitle.text], artwork);
		}
		
		private function destroy(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			
			artwork = null;
			trackCollectionPrefixTitle = null;
			trackCollectionTitle = null;
		}
	}
}