package com.edgington.view.huds.vo
{
	public class CollectionListingItemVO
	{
		public var artist:String;
		public var album:String
		public var playlist:String;
		public var id:String;
		public var numOfTracks:int = 0;
		public var selected:Boolean = false;
		
		public function CollectionListingItemVO(artist:String, album:String, playlist:String, id:String, numOfTracks:int, selected:Boolean){
			this.artist = artist;
			this.album = album;
			this.playlist = playlist;
			this.id = id;
			this.numOfTracks = numOfTracks;
			this.selected = selected;
		}
	}
}