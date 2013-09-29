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

	public class SoundBGMHandler
	{
		private const VOLUME_LATENCY:Number = 0.6;//Seconds to increase volume
		
		private var BGM_sound:Sound;
		private var BGM_soundChannel:SoundChannel;
		private var BGM_soundTransform:SoundTransform;
		private var BGM_newSound:Sound;
		private var BGM_urlString:String;
		private var BGM_currentSound:String;
		private var BGM_pausedPosition:Number = 0;
		
		private var BGM_volume:Number;
		
		private var BGM_tween:TweenLite;
		
		public function SoundBGMHandler()
		{
			
		}
		
		public function loadAndPlaySound(id:String, volume:Number = 0):void{
			if(BGM_currentSound != id){
				BGM_currentSound = id;
				BGM_volume = volume;
				
				if(BGM_volume != 0){
					BGM_volume = SoundManager.instance._BGMVolume;
				}
				if(BGM_sound != null){
					cleanBMDTween();
					if(BGM_newSound != null){
						BGM_newSound.removeEventListener(IOErrorEvent.IO_ERROR, handleBGMLoadError);
						BGM_newSound.removeEventListener(Event.COMPLETE, newBGMSoundLoaded);
						try{
							BGM_newSound.close();
						}
						catch(e:Error){
							
						}
						BGM_newSound = null;
					}
					BGM_newSound = new Sound();
					BGM_urlString = generateBGMURL(id);
					BGM_newSound.addEventListener(IOErrorEvent.IO_ERROR, handleBGMLoadError, false, 0, true);
					BGM_newSound.addEventListener(Event.COMPLETE, newBGMSoundLoaded, false, 0, true);
					BGM_newSound.load(new URLRequest(BGM_urlString));
				}
				else{
					BGM_sound = new Sound();
					BGM_urlString = generateBGMURL(id);
					BGM_sound.addEventListener(IOErrorEvent.IO_ERROR, handleBGMLoadError, false, 0, true);
					BGM_sound.addEventListener(Event.COMPLETE, newBGMSoundLoaded, false, 0, true);
					BGM_sound.load(new URLRequest(BGM_urlString));
				}
			}
		}
		
		public function pauseBGM():void{
			if(BGM_soundChannel != null){
				BGM_pausedPosition = BGM_soundChannel.position;
				BGM_soundChannel.removeEventListener(Event.SOUND_COMPLETE, BGMLoopComplete);
				BGM_soundChannel.stop();
			}
		}
		
		public function resumeBGM():void{
			if(BGM_soundChannel != null){
				cleanBMDTween();
				BGM_soundChannel = BGM_sound.play(BGM_pausedPosition, 0, BGM_soundTransform);
				BGM_soundChannel.addEventListener(Event.SOUND_COMPLETE, BGMLoopComplete, false, 0, true);
				BGM_tween = TweenLite.to(BGM_soundTransform, VOLUME_LATENCY, {onUpdate:applySoundTransformation, onComplete:soundIsPlaying, startAt:{volume:0}, volume:BGM_volume});
			}				
		}
		
		public function changeBGMVolume(volume:Number = 0):void{
			if(BGM_soundChannel != null){
				BGM_volume = volume;
				if(BGM_volume != 0){
					BGM_volume = SoundManager.instance._BGMVolume;
				}
				cleanBMDTween();
				BGM_tween = TweenLite.to(BGM_soundTransform, VOLUME_LATENCY, {onUpdate:applySoundTransformation, onComplete:soundIsPlaying, volume:BGM_volume});
			}
		}
		
		public function turnOffBGM():void{
			BGM_currentSound = "";
			if(BGM_soundChannel != null){
				BGM_soundChannel.stop();
			}
			BGM_soundChannel = null;
			BGM_sound = null;
			BGM_newSound = null;
		}
		
		private function handleBGMLoadError(e:IOErrorEvent):void{
			e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, handleBGMLoadError);
			e.currentTarget.removeEventListener(Event.COMPLETE, newBGMSoundLoaded);
			trace("Error Loading: " + BGM_urlString);
			turnOffBGM();
		}
		
		private function newBGMSoundLoaded(e:Event):void{
			e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, handleBGMLoadError);
			e.currentTarget.removeEventListener(Event.COMPLETE, newBGMSoundLoaded);
			if(e.currentTarget == BGM_newSound){
				switchBMDTrack();
			}
			else{
				playBMGSound();
			}
		}
		
		private function playBMGSound():void{
			cleanBMDTween();
			BGM_soundTransform = new SoundTransform(0);
			BGM_tween = TweenLite.to(BGM_soundTransform, VOLUME_LATENCY, {onUpdate:applySoundTransformation, onComplete:soundIsPlaying, startAt:{volume:0}, volume:BGM_volume});
			BGM_soundChannel = null;
			BGM_soundChannel = new SoundChannel();
			BGM_soundChannel = BGM_sound.play(0, 0);
			BGM_soundChannel.addEventListener(Event.SOUND_COMPLETE, BGMLoopComplete, false, 0, true);
		}
		
		/**
		 * Manually loop the track so that it always starts in the correct position
		 */
		private function BGMLoopComplete(e:Event):void{
			BGM_soundChannel.removeEventListener(Event.SOUND_COMPLETE, BGMLoopComplete);
			BGM_soundChannel = BGM_sound.play(0, 0, BGM_soundTransform);
			BGM_soundChannel.addEventListener(Event.SOUND_COMPLETE, BGMLoopComplete, false, 0, true);
		}
		
		/**
		 * If there is already BGM playing fade out the old BGM and start the new when complete
		 */
		private function switchBMDTrack():void{
			if(BGM_soundChannel != null){
				BGM_soundChannel.removeEventListener(Event.SOUND_COMPLETE, BGMLoopComplete);
			}
			BGM_tween = TweenLite.to(BGM_soundTransform, VOLUME_LATENCY, {onUpdate:applySoundTransformation, onComplete:volumeIsOff, volume:0});
		}
		
		/**
		 * Clean up after sound has started
		 */
		private function soundIsPlaying():void{
			cleanBMDTween();
		}
		
		private function volumeIsOff():void{
			cleanBMDTween();
			cleanBMDSound();
			playBMGSound();
		}
		
		private function applySoundTransformation():void{
			if(BGM_soundChannel != null){
				BGM_soundChannel.soundTransform = BGM_soundTransform;
			}
		}
		
		private function cleanBMDTween():void{
			if(BGM_tween != null){
				BGM_tween.kill();
				BGM_tween = null;
			}
		}
		
		private function cleanBMDSound():void{
			//BGM_sound.close();
			BGM_sound = null;
			BGM_sound = BGM_newSound;
			//BGM_newSound.close();
			BGM_newSound = null;
		}
		
		private function generateBGMURL(id:String):String{
			var str:String = String(SoundConstants.BGM_DIRECTORY + id);
			return str;
		}
	}
}