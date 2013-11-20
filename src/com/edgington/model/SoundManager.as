package com.edgington.model
{
	
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.sound.SoundBGMHandler;
	import com.edgington.model.sound.SoundSFXHandler;
	import com.edgington.model.sound.SoundVOHandler;
	
	import flash.media.AudioPlaybackMode;
	import flash.media.SoundMixer;
	import flash.net.SharedObject;
	
	public class SoundManager
	{
		
		private var soundPreferences:SharedObject;
		
		private const VOLUME_LATENCY:Number = 1.2;//Seconds to increase volume
		
		public static var instance:SoundManager;
		
		private var backgroundHandler:SoundBGMHandler;
		private var sfxHandler:SoundSFXHandler;
		private var voHandler:SoundVOHandler;
		
		public var BGM:Boolean;
		public var SFX:Boolean;
		public var VO:Boolean;
		
		public var _BGMVolume:Number = 1;
		public var _SFXVolume:Number = 1;
		public var _VOVolume:Number = 1;
		
		public var languageDirectory:String = "";//"en_GB/";
		
		public function SoundManager(e:SingletonEnforcer)
		{
			soundPreferences = SharedObject.getLocal("ngSoundPrefs");
			if(soundPreferences.data.BGMOn == null){
				soundPreferences.data.BGMVolume = 1;
				soundPreferences.data.SFXVolume = 1;
				soundPreferences.data.VOVolume = 1;
				soundPreferences.data.BGMOn = true;
				soundPreferences.data.SFXOn = true;
				soundPreferences.data.VOOn = true;
				soundPreferences.flush();
			}
			
			BGMVolume = soundPreferences.data.BGMVolume;
			SFXVolume = soundPreferences.data.SFXVolume;
			VOVolume = soundPreferences.data.VOVolume;
			BGM = soundPreferences.data.BGMOn;
			SFX = soundPreferences.data.SFXOn;
			VO = soundPreferences.data.VOOn;
			
			backgroundHandler = new SoundBGMHandler();
			sfxHandler = new SoundSFXHandler();
			voHandler = new SoundVOHandler();
		}
		
		public function setMutedChannels(BGM:Boolean, SFX:Boolean, VO:Boolean, VOVol:Number, SFXVol:Number, BGMVol:Number):void{
			this.BGM = BGM;
			this.SFX = SFX;
			this.VO = VO;
			_BGMVolume = BGMVol;
			_SFXVolume = SFXVol;
			_VOVolume = VOVol;
		}
		
		public function loadAndPlayVOSound(id:String, type:String, volume:Number = 0):void{
			if(VO){
				voHandler.loadAndPlaySound(id, type, volume);
			}
		}
		
		public function turnOffVO():void{
			voHandler.turnOffVO();
		}
		
		public function loadAndPlaySound(id:String, volume:Number = 0):void{
			if(BGM){
				backgroundHandler.loadAndPlaySound(id, volume);
			}
		}
		
		public function loadAndPlaySFX(id:String, type:String, volume:Number, loop:int = 0, pan:Number = 0, pitchShifter:Boolean = false):void{
			if(SFX){
				if(DynamicConstants.isMobileOS()){
					pitchShifter = false;
				}
				sfxHandler.playNewSFX(id, type, volume, loop, pan, pitchShifter);
			}
		}
		
		public function pitchShift(id:String, type:String, pitch:Number):void{
			if(SFX && !DynamicConstants.isMobileOS()){
				sfxHandler.changePitchOfSound(id, type, pitch);
			}
		}
		
		public function pauseBGM():void{
			if(SFX){
				sfxHandler.pauseAllSFX();
			}
			if(BGM){
				backgroundHandler.pauseBGM();
			}
		}
		
		public function resumeBGM():void{
			if(SFX){
				sfxHandler.resumeAllSFX();
			}
			if(BGM){
				backgroundHandler.resumeBGM();
			}
		}
		
		public function stopSFXSoundWithID(id:String, type:String):void{
			sfxHandler.stopSFXSoundWithID(id, type);
		}
		
		public function stopAllSFX():void{
			sfxHandler.stopAllSounds();
		}
		
		public function changeBGMVolume(volume:Number = 0):void{
			if(BGM){
				backgroundHandler.changeBGMVolume(volume);
			}
		}
		
		public function turnOffBGM():void{
			backgroundHandler.turnOffBGM();
		}
		
		public static function getInstance():SoundManager{
			if(instance == null){
				instance = new SoundManager(new SingletonEnforcer);
			}
			return instance;
		}
		
		public function set BGMVolume(volume:Number):void{
			if(volume != 0){
				_BGMVolume = volume;
				saveVolumes();
			}
		}
		
		public function set SFXVolume(volume:Number):void{
			if(volume != 0){
				_SFXVolume = volume;
				saveVolumes();
			}
		}
		
		public function set VOVolume(volume:Number):void{
			if(volume != 0){
				_VOVolume = volume;	
				saveVolumes();
			}
		}
		
		public function set isBGM_ON(mute:Boolean):void{
			BGM = mute;
			saveMutes();
		}
		
		public function set isSFX_ON(mute:Boolean):void{
			SFX = mute;
			saveMutes();
		}
		
		public function set isVO_ON(mute:Boolean):void{
			VO = mute;
			saveMutes();
		}
		
		private function saveVolumes():void{
			soundPreferences.data.BGMVolume = _BGMVolume;
			soundPreferences.data.SFXVolume = _SFXVolume;
			soundPreferences.data.VOVolume = _VOVolume;
			soundPreferences.flush();
		}
		
		private function saveMutes():void{
			soundPreferences.data.BGMOn = BGM;
			soundPreferences.data.SFXOn = SFX;
			soundPreferences.data.VOOn = VO;
			soundPreferences.flush();
		}
	}
}

class SingletonEnforcer{
	
}