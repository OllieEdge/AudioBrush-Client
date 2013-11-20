package com.edgington.model
{
	import com.edgington.constants.SoundConstants;
	import com.edgington.util.debug.LOG;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.media.AudioPlaybackMode;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import org.osflash.signals.Signal;

	public class TournamentTrackPreviewer
	{
		private static var INSTANCE:TournamentTrackPreviewer;
		
		private var soundObject:Sound;
		private var soundChannel:SoundChannel;
		private var soundTimer:Timer;
		public var currentTime:int = 0;
		public var isPlaying:Boolean = false;
		
		private var previewSignal:Signal;
		
		public function TournamentTrackPreviewer()
		{
			LOG.create(TournamentTrackPreviewer);
		}
		
		public function previewTrack(tournamentID:String, previewSignal:Signal):void{
			isPlaying = true;
			this.previewSignal = previewSignal;
			SoundManager.instance.turnOffBGM();
			SoundMixer.audioPlaybackMode = AudioPlaybackMode.MEDIA;
			var cacheFile:File = new File(File.cacheDirectory.url + "/audiobrush/tournaments/"+ tournamentID +"/" + tournamentID + ".mp3");
			soundObject = new Sound(new URLRequest(cacheFile.url));
			soundObject.addEventListener(Event.COMPLETE, soundFileLoaded, false, 0, true);
		}
		
		public function stopTrack(e:Event = null):void{
			if(soundTimer != null){
				stopTimer();
			}
			if(soundChannel != null){
				stopPlayback();
			}
			if(e == null ){
				previewSignal.dispatch(30);
			}
			previewSignal = null;
			currentTime = 0;
			soundObject = null;
			SoundMixer.audioPlaybackMode = AudioPlaybackMode.AMBIENT;
			SoundManager.getInstance().loadAndPlaySound(SoundConstants.BGM_MENU, SoundConstants.BGM_MENU_VOLUME);
			isPlaying = false;
		}
		
		private function soundFileLoaded(e:Event):void{
			soundChannel = soundObject.play(30000, 0);
			soundTimer = new Timer(1000, 30);
			soundTimer.start();
			soundTimer.addEventListener(TimerEvent.TIMER, tickTimer);
			soundTimer.addEventListener(TimerEvent.TIMER_COMPLETE, stopTrack);
			currentTime = 0;
		}
		
		private function tickTimer(e:TimerEvent):void{
			currentTime++;
			previewSignal.dispatch(currentTime);
		}
		
		private function stopTimer():void{
			soundTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, stopTrack);
			soundTimer.removeEventListener(TimerEvent.TIMER, tickTimer);
			soundTimer.stop();
			soundTimer = null;
		}
		
		private function stopPlayback():void{
			soundChannel.stop();
			soundChannel = null;
		}
		
		public static function getInstance():TournamentTrackPreviewer{
			if(INSTANCE == null){
				INSTANCE = new TournamentTrackPreviewer();
			}
			return INSTANCE;
		}
	}
}