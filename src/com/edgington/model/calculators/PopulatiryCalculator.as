package com.edgington.model.calculators
{
	public class PopulatiryCalculator
	{
		//Popularity must range from 1 - 11, 11 being the highest possible.
		private static var MAX_POPULARITY:int = 11;
		
		private static var PLAY_STEPPER:int = 2;
		
		private static var DAY_STEPPER:int = 11;
		
		public static function calculatePopularity(plays:int, lastPlayed:Date):int{
			var popularity:int = 1;
			
			var playCount:int = plays;
			var playPopularity:int = 1;
			
			while(playCount){
				if(playCount / (PLAY_STEPPER*playPopularity) > 1){
					playCount -= Math.floor(PLAY_STEPPER*playPopularity); 
					popularity++;
					playPopularity++;
				}
				else{
					playCount = 0;
				}
			}
			
			var daysSincePlayed:int = Math.ceil((new Date().time - lastPlayed.time) / 86400000);
			var dayPopularity:int = 1;
			while(daysSincePlayed){
				if(daysSincePlayed / (DAY_STEPPER*dayPopularity) > 1){
					daysSincePlayed -= Math.floor(DAY_STEPPER*dayPopularity); 
					popularity--;
					dayPopularity++;
				}
				else{
					daysSincePlayed = 0;
				}
			}
			
			popularity = Math.min(11, popularity);
			popularity = Math.max(1, popularity);
			
			
			return popularity;
		}
	}
}