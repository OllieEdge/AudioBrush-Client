package com.edgington.model.audio
{
	import com.edgington.control.Control;
	import com.edgington.ipodlibrary.ILEvent;
	import com.edgington.ipodlibrary.ILFilterType;
	import com.edgington.ipodlibrary.ILMediaItem;
	import com.edgington.ipodlibrary.IpodLibrary;
	import com.edgington.model.TutorialManager;
	import com.edgington.model.audio.analysis.MusicAnalyser;
	import com.edgington.model.audio.analysis.MusicEvent;
	import com.edgington.model.audio.analysis.MusicParser;
	import com.edgington.model.events.AudioEvent;
	import com.edgington.net.TournamentData;
	import com.edgington.util.IDCreator;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.valueobjects.MediaItemCollectionsVO;
	import com.edgington.valueobjects.SoundChannelPeaksVO;
	import com.edgington.valueobjects.TournamentVO;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	
	import org.osflash.signals.Signal;

	public class AudioModel
	{
		
		private static var INSTANCE:AudioModel;
		
		private var CACHE_DIRECTORY:String;
		private var soundChannelPeaks:SoundChannelPeaksVO;
		private var trackDirectory:String = "/audiobrush/tracks";
		
		public var soundObject:Sound;
		public var soundChannel:SoundChannel;
		
		public var parser:MusicParser;
		public var musicAnalyser:MusicAnalyser;
		
		public var pausedTrackPosition:Number;
		
		public var trackCollections:MediaItemCollectionsVO;
		private var currentAvailableTracks:Vector.<ILMediaItem>;
		public var difficulty:String;
		public var hecticness:int;
		public var beatRatio:Number;
		
		public var currentTrackDetails:ILMediaItem;
		
		private var audioFileCacher:AudioFileCacher;
		
		public var trackStatusSignal:Signal;
		
		public var isTournament:Boolean;
		public var isTutorial:Boolean;
		private var tournamentData:TournamentVO;
		
		public function AudioModel()
		{
			LOG.create(AudioModel);
			
			currentAvailableTracks = new Vector.<ILMediaItem>;
			
			soundChannelPeaks = new SoundChannelPeaksVO();
			
			trackStatusSignal =  new Signal();
			
			audioFileCacher = AudioFileCacher.getInstance();
			
			CACHE_DIRECTORY = File.cacheDirectory.url;
			
			AudioCacher.getInstance();
		}
		
		
		public function getIpodLibrary():void{
			//Check if the Ipod Library is suppoprted on this platform.
			if(IpodLibrary.isSupported){	
				//Initialise the Extension
				IpodLibrary.Init();
				//Setup Desktop properties if this is desktop mode
				if(IpodLibrary.isSupported == 2){
					IpodLibrary.ipod.setDesktopDebugProperties("/Users/Ollie/Documents/AudioBrush/AudioBrush-Client/audio");
				}
				
				//Get the users Ipod Library
				currentAvailableTracks = IpodLibrary.ipod.getLibraryOf(ILFilterType.ALL);
				var playlistTracks:Vector.<ILMediaItem> = IpodLibrary.ipod.getLibraryOf(ILFilterType.PLAYLISTS);
				IpodLibrary.ipod.addEventListener(ILEvent.IMPORT_COMPLETE, handleTrackImportComplete);
				IpodLibrary.ipod.addEventListener(ILEvent.IMPORT_EXISTS, handleTrackImportComplete);
				IpodLibrary.ipod.addEventListener(ILEvent.IMPORT_ERROR, handleTrackError);
				trackCollections = new MediaItemCollectionsVO(currentAvailableTracks);
				trackCollections.addPlaylists(playlistTracks);
			}
		}
		
		private function handleTrackImportComplete(e:ILEvent):void{
			var trackID:String = IDCreator.createTrackID(currentTrackDetails.trackTitle, currentTrackDetails.artist)
			
			//Let's see if this track is cached already and if not save it for later.
			if(!audioFileCacher.checkCache(IDCreator.createTrackID(currentTrackDetails.trackTitle, currentTrackDetails.artist))){
				audioFileCacher.addItemToCache(trackID, e.importedFilePath, currentTrackDetails);
			}	
			
			trackStatusSignal.dispatch(AudioEvent.TRACK_IMPORTED);
			trackStatusSignal.add(handleAnalisation);
			
			soundObject = new Sound(new URLRequest(e.importedFilePath));
			soundObject.addEventListener(Event.COMPLETE, soundFileLoaded, false, 0, true);
			soundObject.addEventListener(ProgressEvent.PROGRESS, soundFileLoadProgress, false, 0, true);
			soundObject.addEventListener(IOErrorEvent.IO_ERROR, soundFileLoadError, false, 0, true);
		}
		private function handleTrackError(e:ILEvent):void{
			trackStatusSignal.dispatch(AudioEvent.TRACK_ERROR_IMPORTING);
		}

		
		
		
		private function soundFileLoaded(e:Event):void{
			soundObject.removeEventListener(Event.COMPLETE, soundFileLoaded);
			soundObject.removeEventListener(ProgressEvent.PROGRESS, soundFileLoadProgress);
			soundObject.removeEventListener(IOErrorEvent.IO_ERROR, soundFileLoadError);
			trackStatusSignal.add(handleAnalisation);
			trackStatusSignal.dispatch(AudioEvent.TRACK_LOADED);
		}
		private function soundFileLoadProgress(e:ProgressEvent):void{
			trackStatusSignal.dispatch(AudioEvent.TRACK_IMPORTING, e.bytesLoaded/e.bytesTotal);
		}
		private function soundFileLoadError(e:IOErrorEvent):void{
			soundObject.removeEventListener(Event.COMPLETE, soundFileLoaded);
			soundObject.removeEventListener(ProgressEvent.PROGRESS, soundFileLoadProgress);
			soundObject.removeEventListener(IOErrorEvent.IO_ERROR, soundFileLoadError);
			trackStatusSignal.dispatch(AudioEvent.TRACK_ERROR_IMPORTING);
		}
		
		
		
		
		private function handleAnalisation(type:String, arg:Number = 0):void{
			if(type == AudioEvent.TRACK_LOADED){
				if(isTournament){
					currentTrackDetails = new ILMediaItem();
					currentTrackDetails.trackTitle = tournamentData.TRACK;
					currentTrackDetails.artist = tournamentData.ARTIST;
					currentTrackDetails.duration = soundObject.bytesTotal;
					parser = new MusicParser(soundObject);
				}
				else if(isTutorial){
					currentTrackDetails = new ILMediaItem();
					currentTrackDetails.trackTitle = gettext("tutorial_track_1_name");
					currentTrackDetails.artist = gettext("tutorial_track_1_artist");
					currentTrackDetails.duration = soundObject.bytesTotal;
					parser = new MusicParser(soundObject);
				}
				else{
					currentTrackDetails.duration = soundObject.bytesTotal;
					parser = new MusicParser(soundObject);
				}
				musicAnalyser = new MusicAnalyser(parser);
				if(AudioCacher.getInstance().checkForCachedVersion(currentTrackDetails, true, tournamentData, isTutorial)){
					if(isTournament || isTutorial){
						musicAnalyser.skipFFTAndUsedCachedData(AudioCacher.CachedTrackVO);
						trackStatusSignal.dispatch(AudioEvent.TRACK_ANALYSIS_COMPLETE);
					}
					else{
						try{
							musicAnalyser.skipFFTAndUsedCachedData(AudioCacher.CachedTrackVO);
							trackStatusSignal.dispatch(AudioEvent.TRACK_ANALYSIS_COMPLETE);
						}
						catch(e:Error){
							LOG.fatal("The cache for the current track is corrupted");
							parser.addEventListener(MusicEvent.ON_PARSER_PROGRESS, analysisProgress);
							Control.getUpdateSignal().add(checkParse);
						}
					}
				}
				else{
					parser.addEventListener(MusicEvent.ON_PARSER_PROGRESS, analysisProgress);
					Control.getUpdateSignal().add(checkParse);
				}
			}
		}
		
		private function checkParse():void{
			if(parser.parseMusic()){
				Control.getUpdateSignal().remove(checkParse);
				musicAnalyser.Analyse();
				
				AudioCacher.getInstance().saveAudioData(	currentTrackDetails, 
					JSON.stringify(musicAnalyser.fluxThresholds), 
					JSON.stringify(musicAnalyser.beats),
					JSON.stringify(musicAnalyser.beatsDetected),
					JSON.stringify(musicAnalyser.sections),
					JSON.stringify(musicAnalyser.sectionsAverage),
					JSON.stringify(musicAnalyser.starSections));
				
				trackStatusSignal.dispatch(AudioEvent.TRACK_ANALYSIS_COMPLETE);
			}
		}
		
		private function analysisProgress(e:MusicEvent):void{
			trackStatusSignal.dispatch(AudioEvent.TRACK_ANALISING, e.percentageParsed);
		}
		
		public function loadNewTrack(ipodID:String, isTournament:Boolean = false, isTutorial:Boolean = false):void{
			
			this.isTournament = isTournament;
			this.isTutorial = isTutorial;
			
			trackStatusSignal.dispatch(AudioEvent.TRACK_IMPORTING);
			if(!isTournament && !isTutorial){
				for(var i:int = 0; i < currentAvailableTracks.length; i++){
					if(ipodID == currentAvailableTracks[i].ipodID){
						currentTrackDetails = currentAvailableTracks[i];
					}
				}
				var trackID:String = IDCreator.createTrackID(currentTrackDetails.trackTitle, currentTrackDetails.artist);
				IpodLibrary.ipod.getTrack(currentTrackDetails.ipodID, trackID, trackDirectory, true, true);
			}
			else if(isTournament){
				tournamentData = TournamentData.getInstance().currentActiveTournament;
				var cacheFile:File = new File(CACHE_DIRECTORY + "/audiobrush/tournaments/"+ tournamentData.ID +"/" + tournamentData.ID + ".mp3");
				soundObject = new Sound(new URLRequest(cacheFile.url));
				soundObject.addEventListener(Event.COMPLETE, soundFileLoaded, false, 0, true);
				soundObject.addEventListener(ProgressEvent.PROGRESS, soundFileLoadProgress, false, 0, true);
				soundObject.addEventListener(IOErrorEvent.IO_ERROR, soundFileLoadError, false, 0, true);
			}
			else if(isTutorial){
				TutorialManager.getInstance();
				
				soundObject = new Sound(new URLRequest("audio/Tutorial/tutorial_0.mp3"));
				soundObject.addEventListener(Event.COMPLETE, soundFileLoaded, false, 0, true);
				soundObject.addEventListener(ProgressEvent.PROGRESS, soundFileLoadProgress, false, 0, true);
				soundObject.addEventListener(IOErrorEvent.IO_ERROR, soundFileLoadError, false, 0, true);
			}
		}
		
		public function playTrack():void{
			soundChannel = soundObject.play(0, 0);
			soundChannel.addEventListener(Event.SOUND_COMPLETE, trackFinishedPlaying);
		}
		
		public function getSoundChannelPeaks():SoundChannelPeaksVO{
			soundChannelPeaks.left = soundChannel.leftPeak;
			soundChannelPeaks.right = soundChannel.rightPeak;
			return soundChannelPeaks;
		}
		
		public function pause():void{
			soundChannel.removeEventListener(Event.SOUND_COMPLETE, trackFinishedPlaying);
			pausedTrackPosition = soundChannel.position;
			soundChannel.stop();
		}
		
		public function resume():void{
			soundChannel = soundObject.play(pausedTrackPosition, 0);
			soundChannel.addEventListener(Event.SOUND_COMPLETE, trackFinishedPlaying);
		}
		
		private function trackFinishedPlaying(e:Event):void{
			soundChannel.removeEventListener(Event.SOUND_COMPLETE, trackFinishedPlaying);
			trackStatusSignal.dispatch(AudioEvent.TRACK_COMPLETE);
			trackStatusSignal.removeAll();
			soundChannel = null;
			isTutorial = false;
		}
		
		public function get analyser():MusicAnalyser{
			return musicAnalyser;
		}
		
		public static function getInstance():AudioModel
		{
			if(INSTANCE == null){
				INSTANCE = new AudioModel();
			}
			return INSTANCE;
		}
		
		//-------------------------
		//Other methods for extra cache features
		
		public function updateTrackDifficultyCache():void{
			var trackID:String = IDCreator.createTrackID(currentTrackDetails.trackTitle, currentTrackDetails.artist);
				
			audioFileCacher.updateDifficulty(trackID, difficulty);
		}
	}
}