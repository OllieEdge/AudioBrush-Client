package com.edgington.model.audio
{
	import com.edgington.ipodlibrary.ILMediaItem;
	import com.edgington.model.TutorialManager;
	import com.edgington.types.AudioCachedFileTypes;
	import com.edgington.util.debug.LOG;
	import com.edgington.valueobjects.AudioCachedVO;
	import com.edgington.valueobjects.TournamentVO;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class AudioCacher
	{
		
		private static var INSTANCE:AudioCacher;
		
		private var CACHE_DIRECTORY:String;
		
		private var cachedTrackVO:AudioCachedVO;
		
		public function AudioCacher(e:SingletonEnforcer)
		{
			LOG.create(AudioCacher);
			
			CACHE_DIRECTORY = File.cacheDirectory.url;
		}
		
		public function checkForCachedVersion(trackDetails:ILMediaItem, loadCache:Boolean = true, tournamentVO:TournamentVO = null, isTutorial:Boolean = false):Boolean{
			cachedTrackVO = new AudioCachedVO();
			
			var filePrefix:String;
			var cacheFolder:File;
			
			if(tournamentVO != null){
				filePrefix = tournamentVO.ID
				cacheFolder = new File(CACHE_DIRECTORY + "/audiobrush/tournaments/"+ tournamentVO.ID);	
				if(cacheFolder.isDirectory){
					if(loadCache){
						try{
							loadTournamentAudioData(tournamentVO);
							return true;
						}
						catch(e:Error){
							LOG.fatal("There was an error in loading the cached files");
						}
					}
					else{
						return true;
					}
				}
			}
			else if(isTutorial){
				loadTutorialData();
				return true;
			}
			else{
				filePrefix = getFilePrefix(trackDetails);
				cacheFolder = new File(CACHE_DIRECTORY + "/audiobrush/cacheABFiles/"+filePrefix);	
				if(cacheFolder.isDirectory){
					if(loadCache){
						try{
							loadAudioData(trackDetails);
							return true;
						}
						catch(e:Error){
							LOG.fatal("There was an error in loading the cached files");
						}
					}
					else{
						return true;
					}
				}
			}
			return false;
		}
		
		private function loadTutorialData():void{
			var filePrefix:String = TutorialManager.getInstance().getCurrentTutorialID();
			
			LOG.info("Loading Cached FluxThresholds");
			var fluxThresholdsObject:Object = loadTutorialSongData(filePrefix, AudioCachedFileTypes.EXTENSIONS_FLUX_THRESHOLDS);
			var fluxThresholds:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>;
			for(var i:int = 0; i < fluxThresholdsObject.length; i++){
				var fftWindow:Vector.<Number> = Vector.<Number>(fluxThresholdsObject[i]);
				fluxThresholds.push(fftWindow);
			}
			
			LOG.info("Loading Cached Beats");
			var beatsObject:Object = loadTutorialSongData(filePrefix, AudioCachedFileTypes.EXTENSIONS_BEATS);
			var beats:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>;
			for(i = 0; i < beatsObject.length; i++){
				var beatWindow:Vector.<Number> = Vector.<Number>(beatsObject[i]);
				beats.push(beatWindow);
			}
			
			LOG.info("Loading Cached Beats Detected");
			var beatsDetectedObject:Object = loadTutorialSongData(filePrefix, AudioCachedFileTypes.EXTENSIONS_BEATS_DETECTED);
			var beatsDetected:Vector.<Number> = Vector.<Number>(beatsDetectedObject);
			
			LOG.info("Loading Cached Sections");
			var sectionsObject:Object = loadTutorialSongData(filePrefix, AudioCachedFileTypes.EXTENSIONS_SECTIONS);
			var sections:Array = sectionsObject as Array;
			
			LOG.info("Loading Cached Sections Average");
			var sectionsAverageObject:Object = loadTutorialSongData(filePrefix, AudioCachedFileTypes.EXTENSIONS_SECTIONS_AVERAGE);
			var sectionsAverage:Array = sectionsAverageObject as Array;
			
			LOG.info("Loading Cached Star Sections");
			var starSectionsObject:Object = loadTutorialSongData(filePrefix, AudioCachedFileTypes.EXTENSIONS_STAR_SECTIONS);
			var starSections:Array = starSectionsObject as Array;
			
			cachedTrackVO.fluxThresholds = fluxThresholds;
			cachedTrackVO.beats = beats;
			cachedTrackVO.beatsDetected = beatsDetected;
			cachedTrackVO.sections = sections;
			cachedTrackVO.sectionsAverage = sectionsAverage;
			cachedTrackVO.starSections = starSections;
		}
		
		private function loadTournamentAudioData(tournamentVO:TournamentVO):void{
			var filePrefix:String = tournamentVO.ID
			
			LOG.info("Loading Cached FluxThresholds");
			var fluxThresholdsObject:Object = loadTournamentSongData(filePrefix, AudioCachedFileTypes.EXTENSIONS_FLUX_THRESHOLDS);
			var fluxThresholds:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>;
			for(var i:int = 0; i < fluxThresholdsObject.length; i++){
				var fftWindow:Vector.<Number> = Vector.<Number>(fluxThresholdsObject[i]);
				fluxThresholds.push(fftWindow);
			}
			
			LOG.info("Loading Cached Beats");
			var beatsObject:Object = loadTournamentSongData(filePrefix, AudioCachedFileTypes.EXTENSIONS_BEATS);
			var beats:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>;
			for(i = 0; i < beatsObject.length; i++){
				var beatWindow:Vector.<Number> = Vector.<Number>(beatsObject[i]);
				beats.push(beatWindow);
			}
			
			LOG.info("Loading Cached Beats Detected");
			var beatsDetectedObject:Object = loadTournamentSongData(filePrefix, AudioCachedFileTypes.EXTENSIONS_BEATS_DETECTED);
			var beatsDetected:Vector.<Number> = Vector.<Number>(beatsDetectedObject);
			
			LOG.info("Loading Cached Sections");
			var sectionsObject:Object = loadTournamentSongData(filePrefix, AudioCachedFileTypes.EXTENSIONS_SECTIONS);
			var sections:Array = sectionsObject as Array;
			
			LOG.info("Loading Cached Sections Average");
			var sectionsAverageObject:Object = loadTournamentSongData(filePrefix, AudioCachedFileTypes.EXTENSIONS_SECTIONS_AVERAGE);
			var sectionsAverage:Array = sectionsAverageObject as Array;
			
			LOG.info("Loading Cached Star Sections");
			var starSectionsObject:Object = loadTournamentSongData(filePrefix, AudioCachedFileTypes.EXTENSIONS_STAR_SECTIONS);
			var starSections:Array = starSectionsObject as Array;
			
			cachedTrackVO.fluxThresholds = fluxThresholds;
			cachedTrackVO.beats = beats;
			cachedTrackVO.beatsDetected = beatsDetected;
			cachedTrackVO.sections = sections;
			cachedTrackVO.sectionsAverage = sectionsAverage;
			cachedTrackVO.starSections = starSections;
		}
		
		public function loadAudioData(filename:ILMediaItem):void{
			
			var filePrefix:String = getFilePrefix(filename);
			
			LOG.info("Loading Cached FluxThresholds");
			var fluxThresholdsObject:Object = loadSongData(filePrefix, AudioCachedFileTypes.EXTENSIONS_FLUX_THRESHOLDS);
			var fluxThresholds:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>;
			for(var i:int = 0; i < fluxThresholdsObject.length; i++){
				var fftWindow:Vector.<Number> = Vector.<Number>(fluxThresholdsObject[i]);
				fluxThresholds.push(fftWindow);
			}
			
			LOG.info("Loading Cached Beats");
			var beatsObject:Object = loadSongData(filePrefix, AudioCachedFileTypes.EXTENSIONS_BEATS);
			var beats:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>;
			for(i = 0; i < beatsObject.length; i++){
				var beatWindow:Vector.<Number> = Vector.<Number>(beatsObject[i]);
				beats.push(beatWindow);
			}

			LOG.info("Loading Cached Beats Detected");
			var beatsDetectedObject:Object = loadSongData(filePrefix, AudioCachedFileTypes.EXTENSIONS_BEATS_DETECTED);
			var beatsDetected:Vector.<Number> = Vector.<Number>(beatsDetectedObject);
			
			LOG.info("Loading Cached Sections");
			var sectionsObject:Object = loadSongData(filePrefix, AudioCachedFileTypes.EXTENSIONS_SECTIONS);
			var sections:Array = sectionsObject as Array;
			
			LOG.info("Loading Cached Sections Average");
			var sectionsAverageObject:Object = loadSongData(filePrefix, AudioCachedFileTypes.EXTENSIONS_SECTIONS_AVERAGE);
			var sectionsAverage:Array = sectionsAverageObject as Array;
			
			LOG.info("Loading Cached Star Sections");
			var starSectionsObject:Object = loadSongData(filePrefix, AudioCachedFileTypes.EXTENSIONS_STAR_SECTIONS);
			var starSections:Array = starSectionsObject as Array;
			
			cachedTrackVO.fluxThresholds = fluxThresholds;
			cachedTrackVO.beats = beats;
			cachedTrackVO.beatsDetected = beatsDetected;
			cachedTrackVO.sections = sections;
			cachedTrackVO.sectionsAverage = sectionsAverage;
			cachedTrackVO.starSections = starSections;
		}
		
		public function saveAudioData(filename:ILMediaItem, fluxThresholds:String, beats:String, beatsDetected:String, sections:String, sectionsAverage:String, starSections:String):void{
			
			var filePrefix:String = getFilePrefix(filename);
			
			saveSongData(filePrefix, AudioCachedFileTypes.FLUX_THRESHOLDS, fluxThresholds, AudioCachedFileTypes.EXTENSIONS_FLUX_THRESHOLDS);
			saveSongData(filePrefix, AudioCachedFileTypes.BEATS, beats, AudioCachedFileTypes.EXTENSIONS_BEATS);
			saveSongData(filePrefix, AudioCachedFileTypes.BEATS_DETECTED, beatsDetected, AudioCachedFileTypes.EXTENSIONS_BEATS_DETECTED);
			saveSongData(filePrefix, AudioCachedFileTypes.SECTIONS, sections, AudioCachedFileTypes.EXTENSIONS_SECTIONS);
			saveSongData(filePrefix, AudioCachedFileTypes.SECTIONS_AVERAGE, sectionsAverage, AudioCachedFileTypes.EXTENSIONS_SECTIONS_AVERAGE);
			saveSongData(filePrefix, AudioCachedFileTypes.STAR_SECTIONS, starSections, AudioCachedFileTypes.EXTENSIONS_STAR_SECTIONS);
		}
		
		private function saveSongData(fileName:String, dataType:String, data:String, fileExtension:String):void{
			var cacheFile:File = new File(CACHE_DIRECTORY + "/audiobrush/cacheABFiles/"+fileName+"/" + fileName + fileExtension);	
			LOG.info("Cached file - " + fileName + fileExtension);
			
			var fs:FileStream = new FileStream();
			fs.openAsync(cacheFile, FileMode.WRITE);
			
			var byteArray:ByteArray = new ByteArray();
			byteArray.writeUTFBytes(data);
			byteArray.compress();
			
			fs.writeBytes(byteArray);
			fs.close();
		}
		
		private function loadTutorialSongData(fileName:String, fileExtension:String):Object{
			var cacheFile:File = File.applicationDirectory.resolvePath("audio/Tutorial/"+ fileName +"/" + fileName + fileExtension);	
			
			var fs:FileStream = new FileStream();
			fs.open(cacheFile, FileMode.READ);   
			var byteArray:ByteArray = new ByteArray();
			fs.readBytes(byteArray);
			byteArray.uncompress();
			var obj:String = byteArray.readUTFBytes(byteArray.bytesAvailable);
			fs.close();
			
			return JSON.parse(obj);
		}
		
		private function loadTournamentSongData(fileName:String, fileExtension:String):Object{
			var cacheFile:File = new File(CACHE_DIRECTORY + "/audiobrush/tournaments/"+ fileName +"/" + fileName + fileExtension);	
			
			var fs:FileStream = new FileStream();
			fs.open(cacheFile, FileMode.READ);   
			var byteArray:ByteArray = new ByteArray();
			fs.readBytes(byteArray);
			byteArray.uncompress();
			var obj:String = byteArray.readUTFBytes(byteArray.bytesAvailable);
			fs.close();
			
			return JSON.parse(obj);
		}
		
		private function loadSongData(fileName:String, fileExtension:String):Object{
			var cacheFile:File = new File(CACHE_DIRECTORY + "/audiobrush/cacheABFiles/"+fileName+"/" + fileName + fileExtension);	
			
			var fs:FileStream = new FileStream();
			fs.open(cacheFile, FileMode.READ);   
			var byteArray:ByteArray = new ByteArray();
			fs.readBytes(byteArray);
			byteArray.uncompress();
			var obj:String = byteArray.readUTFBytes(byteArray.bytesAvailable);
			fs.close();
			
			return JSON.parse(obj);
		}
		
		public static function getInstance():AudioCacher{
			if(INSTANCE == null){
				INSTANCE = new AudioCacher(new SingletonEnforcer());
			}
			return INSTANCE;
		}
		
		private function getFilePrefix(trackDetails:ILMediaItem):String{
			var filePrefix:String;
			if(trackDetails.trackTitle != "" && trackDetails.trackTitle != null){
				var rex:RegExp = /[\s\r\n]*/gim;
				filePrefix = trackDetails.trackTitle.replace(rex,'') + String(trackDetails.duration);
			}
			else{
				filePrefix = String(trackDetails.duration);
			}
			
			return filePrefix;
		}
		
		public static function get CachedTrackVO():AudioCachedVO{
			return INSTANCE.cachedTrackVO;
		}
	}
}

class SingletonEnforcer{
	
}