package com.edgington.view.huds.elements.trackselection
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.SoundConstants;
	import com.edgington.model.SoundManager;
	import com.edgington.types.CollectionType;
	import com.edgington.types.FontFaceType;
	import com.edgington.util.localisation.getfont;
	import com.edgington.util.localisation.gettext;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.osflash.signals.Signal;
	
	public class element_collectionTypeSelection extends Sprite
	{
		
		private var playlist:ui_track_collection_playlists;
		private var artists:ui_track_collection_artists;
		private var albums:ui_track_collection_albums;
		private var spotify:ui_track_collection_spotify;
		
		private var collectionChangeSignal:Signal;
		
		private var _width:int;
		
		public var currentCollectionTypeSelected:String;
		
		public function element_collectionTypeSelection(collectionChangeSignal:Signal, _width:int)
		{
			super();
			
			currentCollectionTypeSelected = CollectionType.ARTISTS;
			
			this.collectionChangeSignal = collectionChangeSignal;
			this._width = _width;
			
			addListeners();
			
			setupVisuals();
		}
		
		private function addListeners():void{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		private function setupVisuals():void{
			
			playlist = new ui_track_collection_playlists();
			playlist.gotoAndStop(1);
			playlist.scaleX = playlist.scaleY = DynamicConstants.BUTTON_SCALE;
			playlist.x = (_width*.25)*this.numChildren;
			playlist.addEventListener(MouseEvent.MOUSE_UP, handleCollectionSelection);
			playlist.cacheAsBitmap = true;
			this.addChild(playlist);

			artists = new ui_track_collection_artists();
			artists.gotoAndStop(1);
			artists.scaleX = artists.scaleY = DynamicConstants.BUTTON_SCALE;
			artists.x = (_width*.25)*this.numChildren;
			artists.addEventListener(MouseEvent.MOUSE_UP, handleCollectionSelection);
			artists.cacheAsBitmap = true;
			this.addChild(artists);
			
			albums = new ui_track_collection_albums();
			albums.gotoAndStop(1);
			albums.scaleX = albums.scaleY = DynamicConstants.BUTTON_SCALE;
			albums.x = (_width*.25)*this.numChildren;
			albums.addEventListener(MouseEvent.MOUSE_UP, handleCollectionSelection);
			albums.cacheAsBitmap = true;
			this.addChild(albums);
			
			spotify = new ui_track_collection_spotify();
			spotify.gotoAndStop(1);
			spotify.scaleX = spotify.scaleY = DynamicConstants.BUTTON_SCALE;
			spotify.x = (_width*.25)*this.numChildren;
			spotify.addEventListener(MouseEvent.MOUSE_UP, handleCollectionSelection);
			spotify.cacheAsBitmap = true;
			this.addChild(spotify);
			
			handleCurrentSelectionHighlight();
		}
		
		private function handleCollectionSelection(e:MouseEvent):void{
			var newCollectionType:String;
			switch(e.currentTarget){
				case playlist:
					newCollectionType = CollectionType.PLAYLISTS;
					break;
				case artists:
					newCollectionType = CollectionType.ARTISTS;
					break;
				case albums:
					newCollectionType = CollectionType.ALBUMS;
					break;
				case spotify:
					newCollectionType = CollectionType.SPOTIFY;
					break;
			}
			
			if(newCollectionType != currentCollectionTypeSelected){
				SoundManager.getInstance().loadAndPlaySFX(SoundConstants.SFX_OPTION_SELECT, "", 1);
				currentCollectionTypeSelected = newCollectionType;
				collectionChangeSignal.dispatch();
				handleCurrentSelectionHighlight();
			}
		}
		
		private function handleCurrentSelectionHighlight():void{
			albums.gotoAndStop(1);
			artists.gotoAndStop(1);
			playlist.gotoAndStop(1);
			spotify.gotoAndStop(1);
			
			switch(currentCollectionTypeSelected){
				case CollectionType.ALBUMS:
					albums.gotoAndStop(2);
					break;
				case CollectionType.ARTISTS:
					artists.gotoAndStop(2);
					break;
				case CollectionType.PLAYLISTS:
					playlist.gotoAndStop(2);
					break;
				case CollectionType.SPOTIFY:
					spotify.gotoAndStop(2);
					break;
			}
			
			getfont(spotify.txt_label, FontFaceType.REGULAR);
			getfont(albums.txt_label, FontFaceType.REGULAR);
			getfont(artists.txt_label, FontFaceType.REGULAR);
			getfont(playlist.txt_label, FontFaceType.REGULAR);
			
			spotify.txt_label.text = gettext("track_collection_button_not_available");
			albums.txt_label.text = gettext("track_collection_button_albums");
			artists.txt_label.text = gettext("track_collection_button_artists");
			playlist.txt_label.text = gettext("track_collection_button_playlists");
		}
		
		private function destroy(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			collectionChangeSignal.removeAll();
			collectionChangeSignal = null;
		}
		
		
	}
}