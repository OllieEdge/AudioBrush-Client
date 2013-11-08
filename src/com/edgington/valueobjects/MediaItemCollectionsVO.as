package com.edgington.valueobjects
{
	import com.edgington.ipodlibrary.ILMediaItem;
	import com.edgington.util.localisation.gettext;
	
	import flash.utils.Dictionary;

	public class MediaItemCollectionsVO
	{
		
		public var artistDictionary:Dictionary;
		public var albumDictionary:Dictionary;
		public var playlistsDictionary:Dictionary;
		
		public function MediaItemCollectionsVO(allMeditaItems:Vector.<ILMediaItem>)
		{
			artistDictionary = new Dictionary();
			albumDictionary = new Dictionary();
			
			for(var i:int = 0; i < allMeditaItems.length; i++){
				if(artistDictionary[allMeditaItems[i].artist] == null){
					
					if(allMeditaItems[i].artist == null){
						var uncategorisedLocaleTextArtist:String = gettext("track_collection_uncategorized")
						if(artistDictionary[uncategorisedLocaleTextArtist] == null){
							artistDictionary[uncategorisedLocaleTextArtist] = new Vector.<ILMediaItem>;
						}
						allMeditaItems[i].artist = gettext("track_collection_no_artist");
						if(allMeditaItems[i].album == null){
							allMeditaItems[i].album = gettext("track_collection_no_album");
						}
						artistDictionary[uncategorisedLocaleTextArtist].push(allMeditaItems[i]);
					}
					else{
						artistDictionary[allMeditaItems[i].artist] = new Vector.<ILMediaItem>;
						artistDictionary[allMeditaItems[i].artist].push(allMeditaItems[i]);
					}
					
				}
				else{
					if(allMeditaItems[i].album == null){
						allMeditaItems[i].album = gettext("track_collection_no_album");
					}
					artistDictionary[allMeditaItems[i].artist].push(allMeditaItems[i]);
				}
				
				
				if(albumDictionary[allMeditaItems[i].album] == null){
					
					if(allMeditaItems[i].album == null){
						var uncategorisedLocaleTextAlbum:String = gettext("track_collection_uncategorized")
						if(albumDictionary[uncategorisedLocaleTextArtist] == null){
							albumDictionary[uncategorisedLocaleTextArtist] = new Vector.<ILMediaItem>;
						}
						allMeditaItems[i].album = gettext("track_collection_no_album");
						albumDictionary[uncategorisedLocaleTextArtist].push(allMeditaItems[i]);
					}
					else{
						albumDictionary[allMeditaItems[i].album] = new Vector.<ILMediaItem>;
						albumDictionary[allMeditaItems[i].album].push(allMeditaItems[i]);
					}
					
				}
				else{
					albumDictionary[allMeditaItems[i].album].push(allMeditaItems[i]);
				}
			}
		}
		
		public function addPlaylists(playlistMediaItems:Vector.<ILMediaItem>):void{
			playlistsDictionary = new Dictionary();
			
			for(var i:int = 0; i < playlistMediaItems.length; i++){
				if(playlistsDictionary[playlistMediaItems[i].playlist] == null){
					
					if(playlistMediaItems[i].playlist == null){
						var uncategorisedLocaleTextArtist:String = gettext("track_collection_uncategorized")
						if(playlistsDictionary[uncategorisedLocaleTextArtist] == null){
							playlistsDictionary[uncategorisedLocaleTextArtist] = new Vector.<ILMediaItem>;
						}
						playlistMediaItems[i].playlist = gettext("track_collection_no_artist");
						playlistsDictionary[uncategorisedLocaleTextArtist].push(playlistMediaItems[i]);
					}
					else{
						playlistsDictionary[playlistMediaItems[i].playlist] = new Vector.<ILMediaItem>;
						playlistsDictionary[playlistMediaItems[i].playlist].push(playlistMediaItems[i]);
					}
					
				}
				else{
					if(playlistMediaItems[i].album == null){
						playlistMediaItems[i].album = gettext("track_collection_no_album");
					}
					if(playlistMediaItems[i].artist == null){
						playlistMediaItems[i].artist = gettext("track_collection_no_artist");
					}
					playlistsDictionary[playlistMediaItems[i].playlist].push(playlistMediaItems[i]);
				}
			}
		}
	}
}