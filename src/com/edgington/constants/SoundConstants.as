package com.edgington.constants{
	import com.edgington.model.SettingsProxy;
	import com.edgington.util.debug.LOG;
	
	public class SoundConstants
	{
		
		//-------BGM
		public static const BGM_DIRECTORY:String = "audio/BGM/";
		
		public static const BGM_MENU:String = "menu.mp3";
		public static const BGM_LOADING:String = "loading.mp3";
		
		public static const BGM_MENU_VOLUME:Number = 0.4;
		public static const BGM_LOADING_VOLUME:Number = 0.4;
		
		
		//-------SFX
		public static const SFX_DIRECTORY:String = "audio/SFX/";
		public static const GAME_SFX:String = "game/";
		
		public static const SFX_BUTTON_CLICK:String = "buttonclick.mp3";
		public static const SFX_OPTION_SELECT:String = "optionselect.mp3";
		public static const SFX_TAB_SELECT:String = "tabswitch.mp3";
		public static const SFX_MENU_TRANSITION:String = "menutransition.mp3";
		
		public static const SFX_LEVELING:String = "levelingup.mp3";
		public static const SFX_LEVEL:String = "levelup.mp3";
		
		public static const THEME_NORMAL_SFX_DIRECTORY:String = "normal/";
		public static const THEME_FIRE_SFX_DIRECTORY:String = "fire/";
		public static const THEME_ICE_SFX_DIRECTORY:String = "ice/";
		
		public static const VOICE_SFX_DIRECTORY:String = "voice/";
		
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
		
		
		public static const SFX_GOOD_LEVEL_1_1:String = "Cool.mp3";
		public static const SFX_GOOD_LEVEL_1_2:String = "Great.mp3";
		public static const SFX_GOOD_LEVEL_1_3:String = "Okay.mp3";
		public static const SFX_GOOD_LEVEL_1_4:String = "Skillful.mp3";
		public static const SFX_GOOD_LEVEL_1_5:String = "Smooth.mp3";
		
		public static const SFX_GOOD_LEVEL_2_1:String = "Brilliant.mp3";
		public static const SFX_GOOD_LEVEL_2_2:String = "Excelent.mp3";
		public static const SFX_GOOD_LEVEL_2_3:String = "Fantastic.mp3";
		public static const SFX_GOOD_LEVEL_2_4:String = "OMG.mp3";
		public static const SFX_GOOD_LEVEL_2_5:String = "Stunning.mp3";
		public static const SFX_GOOD_LEVEL_2_6:String = "Sweet.mp3";
		
		public static const SFX_GOOD_LEVEL_3_1:String = "Divine.mp3";
		public static const SFX_GOOD_LEVEL_3_2:String = "Impressive.mp3";
		public static const SFX_GOOD_LEVEL_3_3:String = "Outstanding.mp3";
		public static const SFX_GOOD_LEVEL_3_4:String = "OutstandingBritish.mp3";
		public static const SFX_GOOD_LEVEL_3_5:String = "Sensational.mp3";
		
		public static const SFX_GOOD_LEVEL_4_1:String = "GodLike.mp3";
		public static const SFX_GOOD_LEVEL_4_2:String = "Invincible.mp3";
		public static const SFX_GOOD_LEVEL_4_3:String = "Legendary.mp3";
		public static const SFX_GOOD_LEVEL_4_4:String = "Outrageous.mp3";
		public static const SFX_GOOD_LEVEL_4_5:String = "Unbelievable.mp3";

		
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