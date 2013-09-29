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

	public class SoundSFXHandler
	{
		
		private var currentSoundObjects:Vector.<SoundObject> = new Vector.<SoundObject>;
		
		public function SoundSFXHandler()
		{
			
		}
		
		/**
		 * Plays new sound, if Loop is -1 sound will loop until stopAllSounds(); is called.
		 */
		public function playNewSFX(id:String, type:String, volume:Number, loop:int = 0, pan:Number = 0, pitchShifter:Boolean = false):void{
			var soundObject:SoundObject = new SoundObject();
			soundObject.sound = new Sound();
			soundObject.URL = getSFXURL(id, type);
			soundObject.ID = id;
			soundObject.type = type;
			soundObject.loop = loop;
			soundObject.volume = volume;
			if(soundObject.volume != 0){
				soundObject.volume = soundObject.volume * SoundManager.instance._SFXVolume;
			}
			soundObject.pan = pan;
			soundObject.hasPitchShifter = pitchShifter;
			soundObject.sound.addEventListener(IOErrorEvent.IO_ERROR, handleSFXLoadError, false, 0, true);
			soundObject.sound.addEventListener(Event.COMPLETE, newSFXSoundLoaded, false, 0, true);
			currentSoundObjects.push(soundObject)
			soundObject.sound.load(new URLRequest(soundObject.URL));
		}
		
		private function handleSFXLoadError(e:IOErrorEvent):void{
			e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, handleSFXLoadError);
			e.currentTarget.removeEventListener(Event.COMPLETE, newSFXSoundLoaded);
			trace("Error Loading SFX");
		}
		
		private function newSFXSoundLoaded(e:Event):void{
			e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, handleSFXLoadError);
			e.currentTarget.removeEventListener(Event.COMPLETE, newSFXSoundLoaded);
			for each(var so:SoundObject in currentSoundObjects){
				if(so.sound == e.currentTarget){
					if(so.hasPitchShifter){
						so.pitchShifter = new SoundPitchShifter(so.sound);
						so.pitchShifter.volume = so.volume;
						if(isNaN(so.pitchRate)){
							so.pitchShifter.rate = so.pitchRate = 1;
						}
						else{
							so.pitchShifter.rate = so.pitchRate;
						}
					}
					else{
						playSound(so);
					}
				}
			}
		}
		
		private function playSound(so:SoundObject):void{
			so.soundChannel = so.sound.play(so.pausedPosition, 0, new SoundTransform(so.volume, so.pan));
			so.soundChannel.addEventListener(Event.SOUND_COMPLETE, soundComplete, false, 0, true);
		}
		
		public function pauseAllSFX():void{
			for each(var so:SoundObject in currentSoundObjects){
				if(so.hasPitchShifter){
					so.pitchShifter.rate = 0;	
				}
				else{
					if(so.soundChannel){
						so.pausedPosition = so.soundChannel.position;
						so.soundChannel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
						so.soundChannel.stop();
					}
				}
			}
		}
		
		public function resumeAllSFX():void{
			for each(var so:SoundObject in currentSoundObjects){
				if(so.hasPitchShifter){
					so.pitchShifter.rate = so.pitchRate;	
				}
				else{
					if(so.soundChannel){
						playSound(so);
					}
				}
			}
		}
		
		public function stopSFXSoundWithID(id:String, type:String):void{
			for each(var so:SoundObject in currentSoundObjects){
				if(so.ID == id && so.type == type){
					if(so.hasPitchShifter){
						so.pitchShifter.destroy();
						so.pitchShifter = null;
						so.soundChannel = null;
						so.sound = null;
						so.soundTransform = null;
					}
					else{
						so.soundChannel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
						so.soundChannel.stop();
						so.soundChannel = null;
						so.sound = null;
						so.soundTransform = null;
					}
					currentSoundObjects.splice(currentSoundObjects.indexOf(so), 1);
					break;
				}
			}
		}
		
		public function stopAllSounds():void{
			for each(var so:SoundObject in currentSoundObjects){
				if(so.hasPitchShifter){
					so.pitchShifter.destroy();
					so.pitchShifter = null;
					so.soundChannel = null;
					so.sound = null;
					so.soundTransform = null;
				}
				else{
					if(so.soundChannel != null){
						so.soundChannel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
						so.soundChannel.stop();
						so.soundChannel = null;
						so.sound = null;
						so.soundTransform = null;
					}
				}
			}
			currentSoundObjects = new Vector.<SoundObject>;
		}
		
		public function changePitchOfSound(id:String, type:String, pitchValue:Number):void{
			for each(var so:SoundObject in currentSoundObjects){
				if(so.ID == id && so.type == type){
					so.pitchRate = pitchValue;
					if(so.pitchShifter){
						so.pitchShifter.rate = pitchValue;
					}
				}
			}
		}
		
		private function soundComplete(e:Event):void{
			e.currentTarget.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
			for each(var so:SoundObject in currentSoundObjects){
				if(so.soundChannel == e.currentTarget){
					if(so.loop != 0){
						if(so.loop != -1){
							so.loop--;
						}
						playSound(so);
					}
					else{
						currentSoundObjects.splice(currentSoundObjects.indexOf(so), 1);
					}
					break;
				}
			}
		}
		
		private function getSFXURL(id:String, type:String):String{
			var str:String = SoundConstants.SFX_DIRECTORY + id;
			return str;
		}
	}
}


import com.edgington.model.sound.SoundPitchShifter;
import com.greensock.TweenLite;

import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;

internal class SoundObject{
	public var sound:Sound;
	public var soundChannel:SoundChannel;
	public var soundTransform:SoundTransform;
	public var URL:String;
	public var ID:String;
	public var volume:Number;
	public var loop:int = 0;
	public var type:String;
	public var pan:Number = 0;
	public var pausedPosition:Number = 0;
	public var hasPitchShifter:Boolean = false;
	public var pitchShifter:SoundPitchShifter;
	public var pitchTween:TweenLite;
	public var pitchRate:Number;
}

