package com.edgington.constants{
	import com.edgington.model.SettingsProxy;
	import com.edgington.util.debug.LOG;
	
	public class SoundConstants
	{
		
		//-------BGM
		public static const BGM_DIRECTORY:String = "audio/BGM/";
		
		public static const BGM_MENU:String = "MenuTheme.mp3";
		public static const BGM_SMOKING:String = "SmokingTheme.mp3";
		public static const BGM_ALCOHOL:String = "DrinkingTheme.mp3";
		public static const BGM_EATING:String = "EatingTheme.mp3";
		public static const BGM_CAFFEINE:String = "AlcoholTheme.mp3";
		
		public static const BGM_MENU_VOLUME:Number = 1;
		public static const BGM_SMOKING_VOLUME:Number = 1;
		public static const BGM_ALCOHOL_VOLUME:Number = 1;
		public static const BGM_EATING_VOLUME:Number = 1;
		public static const BGM_CAFFEINE_VOLUME:Number = 1;
		
		
		//-------SFX
		public static const SFX_DIRECTORY:String = "audio/SFX/";
		public static const GAME_SFX:String = "game/";
		
		public static const THEME_NORMAL_SFX_DIRECTORY:String = "normal/";
		public static const THEME_FIRE_SFX_DIRECTORY:String = "fire/";
		public static const THEME_ICE_SFX_DIRECTORY:String = "ice/";
		
		public static const SFX_STAR_1:String = "star_1.mp3";
		public static const SFX_STAR_2:String = "star_2.mp3";
		public static const SFX_STAR_3:String = "star_3.mp3";
		public static const SFX_STAR_4:String = "star_4.mp3";
		public static const SFX_STAR_5:String = "star_5.mp3";
		public static const SFX_STAR_6:String = "star_6.mp3";
		
		public static const SFX_STAR_POWER_ON:String = "star_power_on.mp3";
		public static const SFX_STAR_POWER_OFF:String = "star_power_off.mp3";
		
		public static const SFX_COLLECT_BEAT_1:String = "collect_beat_1.mp3";
		public static const SFX_COLLECT_BEAT_2:String = "collect_beat_2.mp3";
		public static const SFX_COLLECT_ROGUE_BEAT:String = "rogue_beat.mp3";
		
		public static const SFX_MULTIPLIER_1:String = "multiplier_1.mp3";
		public static const SFX_MULTIPLIER_2:String = "multiplier_2.mp3";
		public static const SFX_MULTIPLIER_3:String = "multiplier_3.mp3";
		public static const SFX_MULTIPLIER_4:String = "multiplier_4.mp3";
		public static const SFX_MULTIPLIER_LOST:String = "multiplier_lost.mp3";
		
		public static const SFX_WIPER:String = "wiper.mp3";
		public static const SFX_ON_SCREEN_DETAILS:String = "onscreen_info_appear.mp3";
		
		
		//-------Voice Overs
		public static const VO_DIRECTORY:String = "audio/GrandWizard/";
		public static const GAME_INTRO_DIRECTORY:String = "GameIntros/";
		public static const BOSS_INTRO_DIRECTORY:String = "BossIntros/";

		
		public static function getGameThemeSFXDirectory(sfxToLoad:String):String{
			try{
				return  GAME_SFX + SoundConstants[SettingsProxy.getInstance().currentTheme.toUpperCase() + "_SFX_DIRECTORY"] + sfxToLoad;
			}
			catch(e:Error){
				LOG.fatal("There was a error getting the directory for theme: " + SettingsProxy.getInstance().currentTheme);
			}
			return "";
		}
	}
}