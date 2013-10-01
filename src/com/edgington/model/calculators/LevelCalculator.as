package com.edgington.model.calculators
{
	import com.edgington.util.debug.LOG;

	public class LevelCalculator
	{
		//This is the xp required for the first level so from level 0 -> 1
		private static const startingLevelXP:int = 300;
		private static const xpCurveValue:Number = 0.0385;
		
		private static var maxLevel:int = 50;
		
		//This holds all the xp needed to get from the previous level to the next.
		public static var levelXPRequiredPerLevelArray:Vector.<uint>;
		
		//This holds all the xp required for a specific level.
		public static var levelXPRequiredArray:Vector.<uint>;
		
		public static function calculateLevels():void{
			levelXPRequiredPerLevelArray = new Vector.<uint>;
			levelXPRequiredArray = new Vector.<uint>;
			
			var accumilation:int = 0;
			for(var i:int = 0; i < maxLevel; i++){
				if(i == 0){
					levelXPRequiredPerLevelArray.push(startingLevelXP);
				}
				else{
					levelXPRequiredPerLevelArray.push(Math.ceil(levelXPRequiredPerLevelArray[i-1]+(levelXPRequiredPerLevelArray[i-1]*(i*(xpCurveValue-((Math.min(i, 37))*0.001))))));
				}
				accumilation += levelXPRequiredPerLevelArray[i];
				levelXPRequiredArray.push(accumilation);
			}
			
			LOG.debug("level calculations complete");
			
		}
		
		//Returns the level based on the xp parsed.
		public static function getLevel(xp:uint):uint{
			for(var i:uint = 0; i < maxLevel; i++){
				if(levelXPRequiredArray[i] > xp){
					return i;
					break;
				}
			}
			return 0;
		}
		
		public static function getNextLevelPercentage(xp:uint):int{
			var percentage:int = 0;
			var currentLevel:uint = getLevel(xp);
			var nextLevel:uint = currentLevel+1;
			
			var currentXPForLevel:uint = 0;
			if(currentLevel != 0){
				currentXPForLevel = levelXPRequiredArray[currentLevel-1];
			}
			var xpOverLevel:uint = xp - currentXPForLevel;
			
			percentage = Math.floor((xpOverLevel / levelXPRequiredPerLevelArray[currentLevel])*100);
			
			return percentage;
		}
	}
}