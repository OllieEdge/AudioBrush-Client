package com.edgington.constants
{
	import com.edgington.view.huds.vo.AchievementVO;

	public class AchievementConstants
	{
		
		public static var achievements:Vector.<AchievementVO>; 
		
		public static var ach_1:Boolean = false;
		public static var ach_2:Boolean = false;
		public static var ach_3:Boolean = false;
		public static var ach_4:Boolean = false;
		public static var ach_5:Boolean = false;
		public static var ach_6:Boolean = false;
		public static var ach_7:Boolean = false;
		public static var ach_8:Boolean = false;
		public static var ach_9:Boolean = false;
		public static var ach_10:Boolean = false;
		public static var ach_11:Boolean = false;
		public static var ach_12:Boolean = false;
		public static var ach_13:Boolean = false;
		public static var ach_14:Boolean = false;
		public static var ach_15:Boolean = false;
		public static var ach_16:Boolean = false;
		public static var ach_17:Boolean = false;
		public static var ach_18:Boolean = false;
		public static var ach_19:Boolean = false;
		public static var ach_20:Boolean = false;
		public static var ach_21:Boolean = false;
		public static var ach_22:Boolean = false;
		
		public static function populateAchievements():void{
			achievements = new Vector.<AchievementVO>;
			achievements.push(
				new AchievementVO(1, 0, "", 3),
				new AchievementVO(2, 0, "", 5),
				new AchievementVO(3, 0, "", 7),
				new AchievementVO(4, 0, "", 0),
				new AchievementVO(5, 0, "", 2),
				new AchievementVO(6, 0, "", 7),
				new AchievementVO(7, 0, "", 15),
				new AchievementVO(8, 0, "", 50),
				new AchievementVO(9, 0, "", 3),
				new AchievementVO(10, 0, "", 10),
				new AchievementVO(11, 0, "", 50, true),
				new AchievementVO(12, 0, "", 2),
				new AchievementVO(13, 0, "", 2),
				new AchievementVO(14, 0, "", 5),
				new AchievementVO(15, 0, "", 5),
				new AchievementVO(16, 0, "", 5),
				new AchievementVO(17, 0, "", 30),
				new AchievementVO(18, 0, "", 5),
				new AchievementVO(19, 0, "", 3),
				new AchievementVO(20, 0, "", 5),
				new AchievementVO(21, 0, "", 5),
				new AchievementVO(22, 0, "", 0)
				);
		}
		
		public static function getAppleAchievementID(achievementID:int):String{
			var str:String;
			
			switch(achievementID){
				case 1:
					str = "com.edgington.audiobrush.achievement.500k";
					break;
				case 2:
					str = "com.edgington.audiobrush.achievement.1mill";
					break;
				case 3:
					str = "com.edgington.audiobrush.achievement.2mill";
					break;
				case 4:
					str = "com.edgington.audiobrush.achievement.5fingers";
					break;
				case 5:
					str = "com.edgington.audiobrush.achievement.5toes";
					break;
				case 6:
					str = "com.edgington.audiobrush.achievement.5senses";
					break;
				case 7:
					str = "com.edgington.audiobrush.achievement.5alive";
					break;
				case 8:
					str = "com.edgington.audiobrush.achievement.5hundredmiles";
					break;
				case 9:
					str = "com.edgington.audiobrush.achievement.perfect";
					break;
				case 10:
					str = "com.edgington.audiobrush.achievement.ninja";
					break;
				case 11:
					str = "com.edgington.audiobrush.achievement.davinci";
					break;
				case 12:
					str = "com.edgington.audiobrush.achievement.100streak";
					break;
				case 13:
					str = "com.edgington.audiobrush.achievement.500streak";
					break;
				case 14:
					str = "com.edgington.audiobrush.achievement.100perfect";
					break;
				case 15:
					str = "com.edgington.audiobrush.achievement.5tracks";
					break;
				case 16:
					str = "com.edgington.audiobrush.achievement.10tracks";
					break;
				case 17:
					str = "com.edgington.audiobrush.achievement.50tracks";
					break;
				case 18:
					str = "com.edgington.audiobrush.achievement.thismighttakeawhile";
					break;
				case 19:
					str = "com.edgington.audiobrush.achievement.hendrix";
					break;
				case 20:
					str = "com.edgington.audiobrush.achievement.starryeyed";
					break;
				case 21:
					str = "com.edgington.audiobrush.achievement.artistatheart";
					break;
				case 22:
					str = "com.edgington.audiobrush.achievement.imin";
					break;
			}
			
			return str;
		}
	}
}