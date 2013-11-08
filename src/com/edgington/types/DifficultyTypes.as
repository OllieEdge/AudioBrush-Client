package com.edgington.types
{
	import com.edgington.util.debug.LOG;
	
	public class DifficultyTypes
	{
		public static const DIFFICULTY_EASY:String = "DifficultyTypes::DIFFICULTY_EASY";
		public static const DIFFICULTY_NORMAL:String = "DifficultyTypes::DIFFICULTY_NORMAL";
		public static const DIFFICULTY_HARD:String = "DifficultyTypes::DIFFICULTY_HARD";
		public static const DIFFICULTY_EXTREME:String = "DifficultyTypes::DIFFICULTY_EXTREME";
		public static const DIFFICULTY_INSANE:String = "DifficultyTypes::DIFFICULTY_INSANE";
		
		public static function getDifficultyOfGame(hecticness:Number, beatRatio:Number):String{
			
			var hecticnessScore:int = getHecticnessRating(hecticness);
			var beatRatioScore:int = getBeatRatioRating(beatRatio);
			
			var overallScore:Number = (hecticnessScore + beatRatioScore) * .5;
			var difficulty:String;	
			
			
			if(overallScore >= 4.5){
				difficulty = DifficultyTypes.DIFFICULTY_INSANE;
			}
			else if(overallScore >= 3.5){
				difficulty = DifficultyTypes.DIFFICULTY_EXTREME;
			}
			else if(overallScore >= 2.5){
				difficulty = DifficultyTypes.DIFFICULTY_HARD;
			}
			else if(overallScore >= 1.5){
				difficulty = DifficultyTypes.DIFFICULTY_NORMAL;
			}
			else{
				difficulty = DifficultyTypes.DIFFICULTY_EASY;
			}
			
			return difficulty;
		}
		
		
		/**
		 * Returns a rating of hecticness between 0 - 5, 0 is calm, and 5 is extreme
		 */
		public static function getHecticnessRating(hecticness:Number):int{
			var hecticnessScore:int = 0;
			if(hecticness > 15000){
				hecticnessScore = 5;
			}
			else if(hecticness > 10000){
				hecticnessScore = 4;
			}
			else if(hecticness > 8000){
				hecticnessScore = 3;
			}
			else if(hecticness > 6000){
				hecticnessScore = 2;
			}
			else if(hecticness > 4000){
				hecticnessScore = 1;
			}
			else{
				hecticnessScore= 0;
			}
			return hecticnessScore;
		}
		
		/**
		 * Returns a beat ratio rating between 0 - 5, 0 means not a lot of rogue beats, and 5 means LOTS
		 */
		public static function getBeatRatioRating(beatRatio:Number):int{
			var beatRatioScore:int = 0;
			if(beatRatio > 1.5){
				beatRatioScore = 5;
			}
			else if(beatRatio > 0.7){
				beatRatioScore = 4;
			}
			else if (beatRatio > 0.5){
				beatRatioScore = 3;
			}
			else if(beatRatio > 0.3){
				beatRatioScore = 2;
			}
			else if(beatRatio > 0.2){
				beatRatioScore = 1;
			}
			else{
				beatRatioScore = 0;
			}
			return beatRatioScore;
		}
		
		//Converts a String ID to a Integer ID
		public static function difficultyStringIDToID(difficultyString:String):int{
			var difficulty:int = 0;
			switch(difficultyString){
				case DifficultyTypes.DIFFICULTY_EASY:
					difficulty = 1;
					break;
				case DifficultyTypes.DIFFICULTY_NORMAL:
					difficulty = 2;
					break;
				case DifficultyTypes.DIFFICULTY_HARD:
					difficulty = 3;
					break;
				case DifficultyTypes.DIFFICULTY_EXTREME:
					difficulty = 4;
					break;
				case DifficultyTypes.DIFFICULTY_INSANE:
					difficulty = 5;
					break;
			}
			if(difficulty == 0){
				LOG.fatal("Difficulty ID not correct, Difficulty StringID parsed: " + difficultyString);
			}
			return difficulty;
		}
		
		//Converts a Integer ID to a String ID
		public static function difficultyIDToStringID(difficulty:int):String{
			var difficultyString:String;
			switch(difficulty){
				case 1:
					difficultyString = DifficultyTypes.DIFFICULTY_EASY;
					break;
				case 2:
					difficultyString = DifficultyTypes.DIFFICULTY_NORMAL;
					break;
				case 3:
					difficultyString = DifficultyTypes.DIFFICULTY_HARD;
					break;
				case 4:
					difficultyString = DifficultyTypes.DIFFICULTY_EXTREME;
					break;
				case 5:
					difficultyString = DifficultyTypes.DIFFICULTY_INSANE;
					break;
			}
			if(difficultyString == null){
				LOG.fatal("Difficulty String not correct, Difficulty ID parsed: " + difficulty);
			}
			return difficultyString;
		}
	}
}