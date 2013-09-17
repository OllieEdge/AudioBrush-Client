package com.edgington.model.tournaments
{
	import com.edgington.net.events.TournamentEvent;
	import com.edgington.util.debug.LOG;
	import com.edgington.valueobjects.TournamentVO;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.DataLoader;
	import com.greensock.loading.LoaderMax;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import org.osflash.signals.Signal;

	public class TournamentAssetsManager
	{
		
		private static var INSTANCE:TournamentAssetsManager;
		
		private var CACHE_DIRECTORY:String;
		
		public var downloadSignal:Signal;
		
		private var currentDownloadData:TournamentVO;
		
		private var loadQue:Vector.<String>;
		
		private var urlStream:URLStream;
		private var fileData:ByteArray;
		
		private var loader:LoaderMax;
		
		
		public function TournamentAssetsManager()
		{
			LOG.create(this);
			CACHE_DIRECTORY = File.cacheDirectory.url;
			LOG.debug("Cache Directory: " + CACHE_DIRECTORY);
			
			
			
			downloadSignal = new Signal();
		}
		
		public function checkForCachedTournamentData(tournamentID:String):Boolean{
			var cacheFolder:File = new File(CACHE_DIRECTORY + "/tournaments/" + tournamentID);	
			if(cacheFolder.isDirectory){
				var contents:Array = cacheFolder.getDirectoryListing(); 
				if(contents.length >= 7){
					return true;
				}
				else{
					cacheFolder.deleteDirectory(true); 
				}
			}
			
			return false;
		}
		
		public function cancelDownload():void{
			loader.removeEventListener(LoaderEvent.PROGRESS, handleDownloadProgress);
			loader.removeEventListener(LoaderEvent.CHILD_COMPLETE, handleDownloadChildComplete);
			loader.removeEventListener(LoaderEvent.COMPLETE, handleDownloadComplete);
			loader.empty(true, true);
			loader.dispose(true);
			loader = null;
			checkForCachedTournamentData(currentDownloadData.ID);
		}
		
		public function downloadAssets(tournamentVO:TournamentVO):void{
			currentDownloadData = tournamentVO;
			loader = new LoaderMax();
			
			loader.append(new DataLoader(tournamentVO.TRACK_URL, {tournamentVO:tournamentVO, estimatedBytes:8388608, format:"binary"}));
			loader.append(new DataLoader(tournamentVO.BEATS_DETECTED_FILE_URL, {tournamentVO:tournamentVO, estimatedBytes:1000, format:"binary"}));
			loader.append(new DataLoader(tournamentVO.BEATS_FILE_URL, {tournamentVO:tournamentVO, estimatedBytes:1000, format:"binary"}));
			loader.append(new DataLoader(tournamentVO.FLUX_FILE_URL, {tournamentVO:tournamentVO, estimatedBytes:1000, format:"binary"}));
			loader.append(new DataLoader(tournamentVO.SECTIONS_FILE_URL, {tournamentVO:tournamentVO, estimatedBytes:1000, format:"binary"}));
			loader.append(new DataLoader(tournamentVO.STAR_BEATS_FILE_URL, {tournamentVO:tournamentVO, estimatedBytes:1000, format:"binary"}));
			loader.append(new DataLoader(tournamentVO.STAR_SECTIONS_FILE_URL, {tournamentVO:tournamentVO, estimatedBytes:1000, format:"binary"}));
			
			loader.addEventListener(LoaderEvent.PROGRESS, handleDownloadProgress);
			loader.addEventListener(LoaderEvent.CHILD_COMPLETE, handleDownloadChildComplete);
			loader.addEventListener(LoaderEvent.COMPLETE, handleDownloadComplete);
			
			loader.load();
		}
		
		private function handleDownloadProgress(e:LoaderEvent):void{
			downloadSignal.dispatch(TournamentEvent.DATA_PROGRESS, e.target.progress);
		}
		
		private function handleDownloadChildComplete(e:LoaderEvent):void{
			var extension:String = e.target.url.substring(e.target.url.lastIndexOf(".")+1, e.target.url.length);
				
			var file:File = new File(CACHE_DIRECTORY + "/tournaments/"+ currentDownloadData.ID +"/" + currentDownloadData.ID + "." +  extension);
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeBytes(e.target.content, 0, e.target.content.length);
			fileStream.close();
		}
		
		private function handleDownloadComplete(e:LoaderEvent):void{
			downloadSignal.dispatch(TournamentEvent.DATA_COMPLETE, 1);
			loader.removeEventListener(LoaderEvent.PROGRESS, handleDownloadProgress);
			loader.removeEventListener(LoaderEvent.CHILD_COMPLETE, handleDownloadChildComplete);
			loader.removeEventListener(LoaderEvent.COMPLETE, handleDownloadComplete);
			loader.dispose(true);
			loader = null;
		}
		
		public static function getInstance():TournamentAssetsManager{
			if(INSTANCE == null){
				INSTANCE = new TournamentAssetsManager();
			}
			return INSTANCE;
		}
	}
}