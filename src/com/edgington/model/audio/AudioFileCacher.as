package com.edgington.model.audio
{
	import com.edgington.ipodlibrary.ILMediaItem;
	import com.edgington.util.debug.LOG;
	import com.edgington.valueobjects.AudioBrushMediaItemVO;
	
	import flash.filesystem.File;
	import flash.net.SharedObject;

	public class AudioFileCacher
	{
		private static var INSTANCE:AudioFileCacher;
		
		private var libraryData:SharedObject = SharedObject.getLocal("ab_libraryCache");
		
		private var cacheLibrary:Vector.<AudioBrushMediaItemVO>;
		private var trackCacheDirectoty:File;
		
		public function AudioFileCacher()
		{
			trackCacheDirectoty = File.cacheDirectory;
			trackCacheDirectoty.resolvePath("/audiobrush/tracks");
			if(!trackCacheDirectoty.isDirectory){
				trackCacheDirectoty.createDirectory();
				LOG.debug("Created Audio File Cache Directory");
			}
			
			cacheLibrary = new Vector.<AudioBrushMediaItemVO>;
			
			getPreloadedTracks();
		}
		
		/**
		 * This loads any previous tracks already cached in another session with all the relevant AudioBrushMediaItemVO properties.
		 */
		private function getPreloadedTracks():void{
			if(libraryData.data.cache != null){
				for(var i:int = 0; i < libraryData.data.cache.length; i++){
					cacheLibrary.push(new AudioBrushMediaItemVO(JSON.parse(JSON.stringify(libraryData.data.cache[i]))));
					var trackFile:File = new File(libraryData.data.cache[i].trackURL);
					cacheLibrary[cacheLibrary.length-1].isLoaded = trackFile.exists;
				}
			}
			else{
				LOG.debug("Created a new library cache");
				libraryData.data.cache = cacheLibrary;
			}
		}
		
		public function checkCache(trackID:String):Boolean{
			for(var i:int = 0; i < cacheLibrary.length; i++){
				if(cacheLibrary[i].trackID == trackID){
					return true;
				}
			}
			return false;
		}
		
		public function updateDifficulty(trackID:String, difficulty:String):void{
			for(var i:int = 0; i < cacheLibrary.length; i++){
				if(cacheLibrary[i].trackID == trackID){
					cacheLibrary[i].difficulty = difficulty;
					break;
				}
			}
		}
		
		public function getCachedItem(trackID:String):AudioBrushMediaItemVO{
			for(var i:int = 0; i < cacheLibrary.length; i++){
				if(cacheLibrary[i].trackID == trackID){
					return cacheLibrary[i];
				}
			}
			return null;
		}
		
		public function addItemToCache(trackID:String, trackPath:String, trackDetails:ILMediaItem):void{
			var audioBrushMediaItem:AudioBrushMediaItemVO = new AudioBrushMediaItemVO();
			audioBrushMediaItem.trackID = trackID;
			audioBrushMediaItem.trackURL = trackPath;
			audioBrushMediaItem.isLoaded = true;
			audioBrushMediaItem.trackDetails = trackDetails;
			audioBrushMediaItem.difficulty = "";
			audioBrushMediaItem.playCount = 0;
			
			cacheLibrary.push(audioBrushMediaItem);
			saveCache();
		}
		
		private function saveCache():void{
			libraryData.data.cache = cacheLibrary;
			libraryData.flush();
		}
		
		public static function getInstance():AudioFileCacher{
			if(INSTANCE == null){
				INSTANCE = new AudioFileCacher();
			}
			return INSTANCE;
		}
	}
}