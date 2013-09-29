package com.edgington.model.sound
{
	import com.edgington.constants.SoundConstants;
	import com.edgington.model.SoundManager;
	import com.greensock.TweenLite;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	public class SoundVOHandler
	{
		private const VOLUME_LATENCY:Number = 0.1;//Seconds to increase volume
		
		private var VO_sound:Sound;
		private var VO_soundChannel:SoundChannel;
		private var VO_soundTransform:SoundTransform;
		private var VO_newSound:Sound;
		private var VO_urlString:String;
		private var VO_currentSound:String;
		private var VO_pausedPosition:Number = 0;
		
		private var VO_volume:Number;
		
		private var VO_tween:TweenLite;
		
		public function SoundVOHandler()
		{
			
		}
		
		public function loadAndPlaySound(id:String, type:String, volume:Number = 0):void{
			if(VO_currentSound != id){
				VO_currentSound = id;
				if(volume == 0){
					VO_volume = SoundConstants["VO_VOLUME_" + id.toUpperCase()];
				}
				else{
					VO_volume = volume;
				}
				if(VO_volume != 0){
					VO_volume = VO_volume * SoundManager.instance._VOVolume;
				}
				if(VO_sound != null){
					cleanVOTween();
					if(VO_newSound != null){
						VO_newSound.removeEventListener(IOErrorEvent.IO_ERROR, handleVOLoadError);
						VO_newSound.removeEventListener(Event.COMPLETE, newVOSoundLoaded);
						VO_newSound.close();
						VO_newSound = null;
					}
					VO_newSound = new Sound();
					VO_urlString = generateVOURL(id, type);
					VO_newSound.addEventListener(IOErrorEvent.IO_ERROR, handleVOLoadError, false, 0, true);
					VO_newSound.addEventListener(Event.COMPLETE, newVOSoundLoaded, false, 0, true);
					VO_newSound.load(new URLRequest(VO_urlString));
				}
				else{
					VO_sound = new Sound();
					VO_urlString = generateVOURL(id, type);
					VO_sound.addEventListener(IOErrorEvent.IO_ERROR, handleVOLoadError, false, 0, true);
					VO_sound.addEventListener(Event.COMPLETE, newVOSoundLoaded, false, 0, true);
					VO_sound.load(new URLRequest(VO_urlString));
				}
			}
		}
		
		public function pauseVO():void{
			if(VO_soundChannel != null){
				VO_pausedPosition = VO_soundChannel.position;
				VO_soundChannel.removeEventListener(Event.SOUND_COMPLETE, VOLoopComplete);
				VO_soundChannel.stop();
			}
		}
		
		public function resumeVO():void{
			if(VO_soundChannel != null){
				cleanVOTween();
				VO_soundChannel = VO_sound.play(VO_pausedPosition, 0, VO_soundTransform);
				VO_soundChannel.addEventListener(Event.SOUND_COMPLETE, VOLoopComplete, false, 0, true);
				VO_tween = TweenLite.to(VO_soundTransform, VOLUME_LATENCY, {onUpdate:applySoundTransformation, onComplete:soundIsPlaying, startAt:{volume:0}, volume:VO_volume});
			}				
		}
		
		public function turnOffVO():void{
			VO_currentSound = "";
			if(VO_soundChannel != null){
				VO_soundChannel.stop();
			}
			VO_soundChannel = null;
			VO_sound = null;
			VO_newSound = null;
		}
		
		private function handleVOLoadError(e:IOErrorEvent):void{
			e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, handleVOLoadError);
			e.currentTarget.removeEventListener(Event.COMPLETE, newVOSoundLoaded);
			trace("Error Loading: " + VO_urlString);
			turnOffVO();
		}
		
		private function newVOSoundLoaded(e:Event):void{
			e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, handleVOLoadError);
			e.currentTarget.removeEventListener(Event.COMPLETE, newVOSoundLoaded);
			if(e.currentTarget == VO_newSound){
				switchBMDTrack();
			}
			else{
				playBMGSound();
			}
		}
		
		private function playBMGSound():void{
			cleanVOTween();
			VO_soundTransform = new SoundTransform(0);
			VO_tween = TweenLite.to(VO_soundTransform, VOLUME_LATENCY, {onUpdate:applySoundTransformation, onComplete:soundIsPlaying, startAt:{volume:0}, volume:VO_volume});
			VO_soundChannel = null;
			VO_soundChannel = new SoundChannel();
			VO_soundChannel = VO_sound.play(0, 0);
			VO_soundChannel.addEventListener(Event.SOUND_COMPLETE, VOLoopComplete, false, 0, true);
		}

		
		private function VOLoopComplete(e:Event):void{
			VO_soundChannel.removeEventListener(Event.SOUND_COMPLETE, VOLoopComplete);
			turnOffVO();
		}
		
		/**
		 * If there is already VO playing fade out the old VO and start the new when complete
		 */
		private function switchBMDTrack():void{
			if(VO_soundChannel != null){
				VO_soundChannel.removeEventListener(Event.SOUND_COMPLETE, VOLoopComplete);
			}
			VO_tween = TweenLite.to(VO_soundTransform, VOLUME_LATENCY, {onUpdate:applySoundTransformation, onComplete:volumeIsOff, volume:0});
		}
		
		/**
		 * Clean up after sound has started
		 */
		private function soundIsPlaying():void{
			cleanVOTween();
		}
		
		private function volumeIsOff():void{
			cleanVOTween();
			cleanBMDSound();
			playBMGSound();
		}
		
		private function applySoundTransformation():void{
			if(VO_soundChannel != null){
				VO_soundChannel.soundTransform = VO_soundTransform;
			}
		}
		
		private function cleanVOTween():void{
			if(VO_tween != null){
				VO_tween.kill();
				VO_tween = null;
			}
		}
		
		private function cleanBMDSound():void{
			//VO_sound.close();
			VO_sound = null;
			VO_sound = VO_newSound;
			//VO_newSound.close();
			VO_newSound = null;
		}
		
		private function generateVOURL(id:String, type:String):String{
			trace("ID Parsed to VO URL Generator: " + id);
			trace("TYPE Parsed to VO URL Generator: " + type);
			var str:String = String(SoundConstants.VO_DIRECTORY + type + SoundManager.instance.languageDirectory + SoundConstants["VO_"+id.toUpperCase()]);
			trace("VO Sound to load: " + str);
			return str;
		}
	}
}

