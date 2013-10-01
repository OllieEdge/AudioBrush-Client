package com.edgington.model.audio
{
	import com.edgington.NativeMediaManager.NativeMediaVO;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.control.Control;
	import com.edgington.media.MediaManager;
	import com.edgington.model.audio.analysis.MusicAnalyser;
	import com.edgington.model.audio.analysis.MusicEvent;
	import com.edgington.model.audio.analysis.MusicParser;
	import com.edgington.model.events.AudioEvent;
	import com.edgington.net.TournamentData;
	import com.edgington.util.debug.LOG;
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

	public class AudioMainModel
	{
		
		protected static var INSTANCE:AudioMainModel;
		
		private var CACHE_DIRECTORY:String;
		
		private var soundFileRef:File;
		
		public var soundObject:Sound;
		public var soundChannel:SoundChannel;
		
		private var soundChannelPeaks:SoundChannelPeaksVO;
		
		public var trackStatusSignal:Signal;
		
		public var parser:MusicParser;
		public var musicAnalyser:MusicAnalyser;
		
		public var currentTrackDetails:NativeMediaVO;
		public var difficulty:String;
		public var hecticness:int;
		public var beatRatio:Number;
		
		private var pausedTrackPosition:Number;
		
		private var isTournament:Boolean;
		
		private var tournamentData:TournamentVO
		
		public function AudioMainModel(e:SingletonEnforcer)
		{
			LOG.create(AudioMainModel);
			soundChannelPeaks = new SoundChannelPeaksVO();
			
			CACHE_DIRECTORY = File.cacheDirectory.url;
			
			AudioCacher.getInstance();
		}
		
		
		//------@@@@@@ DESKTOP SOUND LOADING
		/**
		 * Desktop Only
		 * Select the track to load from the default operating system open dialog
		 */
		public function selectTrackToLoad(isTournament:Boolean = false):void{
			this.isTournament = isTournament;
			if(!isTournament){
				if(DynamicConstants.isIOSPlatform()){
					trackStatusSignal = MediaManager.OpenMediaPicker();
				}
				else{
					soundFileRef = new File();
					soundFileRef.browse();
					soundFileRef.addEventListener(Event.SELECT, desktopFileSelected, false, 0, true);
					soundFileRef.addEventListener(Event.CANCEL, desktopOpenCanceled, false, 0, true);
					trackStatusSignal = new Signal();
				}
			}
			else{
				tournamentData = TournamentData.getInstance().currentActiveTournament;
				var cacheFile:File = new File(CACHE_DIRECTORY + "/tournaments/"+ tournamentData.ID +"/" + tournamentData.ID + ".mp3");
				soundObject = new Sound(new URLRequest(cacheFile.url));
				soundObject.addEventListener(Event.COMPLETE, desktopLoadedSoundFile, false, 0, true);
				soundObject.addEventListener(ProgressEvent.PROGRESS, desktopLoadProgress, false, 0, true);
				soundObject.addEventListener(IOErrorEvent.IO_ERROR, desktopOpenError, false, 0, true);
				trackStatusSignal = new Signal();
			}
			//TODO can be removed when there is a menu at the end of a track
			trackStatusSignal.add(onTrackLoaded);
		}
		
		private function desktopOpenError(e:IOErrorEvent):void{
			soundObject.removeEventListener(IOErrorEvent.IO_ERROR, desktopOpenError);
			trackStatusSignal.dispatch(AudioEvent.TRACK_ERROR_IMPORTING);
		}
		
		private function desktopOpenCanceled(e:Event):void{
			soundFileRef.removeEventListener(Event.SELECT, desktopFileSelected);
			soundFileRef.removeEventListener(Event.CANCEL, desktopOpenCanceled);
			trackStatusSignal.dispatch(AudioEvent.TRACK_SELECTION_CANCELED);
		}
		
		private function desktopFileSelected(e:Event):void{
			soundFileRef.removeEventListener(Event.SELECT, desktopFileSelected);
			soundFileRef.removeEventListener(Event.CANCEL, desktopOpenCanceled);
			soundObject = new Sound(new URLRequest(soundFileRef.url));
			soundObject.addEventListener(Event.COMPLETE, desktopLoadedSoundFile, false, 0, true);
			soundObject.addEventListener(ProgressEvent.PROGRESS, desktopLoadProgress, false, 0, true);
			soundObject.addEventListener(IOErrorEvent.IO_ERROR, desktopOpenError, false, 0, true);
		}

		private function desktopLoadProgress(e:ProgressEvent):void{
			trackStatusSignal.dispatch(AudioEvent.TRACK_IMPORTING, e.bytesLoaded/e.bytesTotal);
		}
		
		private function desktopLoadedSoundFile(e:Event):void{
			soundObject.removeEventListener(Event.COMPLETE, desktopLoadedSoundFile);
			soundObject.removeEventListener(ProgressEvent.PROGRESS, desktopLoadProgress);
			soundObject.removeEventListener(IOErrorEvent.IO_ERROR, desktopOpenError);
			trackStatusSignal.dispatch(AudioEvent.TRACK_LOADED);
		}
		
		public function playTrack():void{
			if(!isTournament){
				if(DynamicConstants.isIOSPlatform()){
					soundChannel = MediaManager.INSTANCE.sound.play(0, 0);
				}
				else{
					soundChannel = soundObject.play(0, 0);
				}
			}
			else{
				soundChannel = soundObject.play(0, 0);
			}
			soundChannel.addEventListener(Event.SOUND_COMPLETE, trackFinishedPlaying);
		}
		//------@@@@@@ DESKTOP SOUND LOADING
		
		private function onTrackLoaded(type:String, arg:Number = 0):void{
			if(type == AudioEvent.TRACK_LOADED){
				if(isTournament){
					currentTrackDetails = new NativeMediaVO();
					currentTrackDetails.trackTitle = tournamentData.TRACK;
					currentTrackDetails.artistName = tournamentData.ARTIST;
					currentTrackDetails.duration = soundObject.bytesTotal;
					parser = new MusicParser(soundObject);
				}
				else if(DynamicConstants.isIOSPlatform()){
					currentTrackDetails = MediaManager.INSTANCE.trackData;
					currentTrackDetails.duration = MediaManager.INSTANCE.sound.bytesTotal;
					parser = new MusicParser(MediaManager.INSTANCE.sound);
				}
				else{
					currentTrackDetails = new NativeMediaVO();
					currentTrackDetails.trackTitle = soundObject.id3.songName;
					currentTrackDetails.artistName = soundObject.id3.artist;
					currentTrackDetails.duration = soundObject.bytesTotal;
					parser = new MusicParser(soundObject);
				}
				musicAnalyser = new MusicAnalyser(parser);
				if(AudioCacher.getInstance().checkForCachedVersion(currentTrackDetails, true, tournamentData)){
					if(isTournament){
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
			if(DynamicConstants.isIOSPlatform()){
				soundChannel = MediaManager.INSTANCE.sound.play(pausedTrackPosition, 0);
			}
			else{
				soundChannel = soundObject.play(pausedTrackPosition, 0);
			}
			soundChannel.addEventListener(Event.SOUND_COMPLETE, trackFinishedPlaying);
		}
		
		private function trackFinishedPlaying(e:Event):void{
			soundChannel.removeEventListener(Event.SOUND_COMPLETE, trackFinishedPlaying);
			trackStatusSignal.dispatch(AudioEvent.TRACK_COMPLETE);
			trackStatusSignal.removeAll();
			soundChannel = null;
		}
		
		public function get analyser():MusicAnalyser{
			return musicAnalyser;
		}
		
		public static function getInstance():AudioMainModel{
			if(INSTANCE == null){
				INSTANCE = new AudioMainModel(new SingletonEnforcer);
			}
			return INSTANCE;
		}
	}
}

class SingletonEnforcer{
	
}