package com.edgington.model.calculators
{
	import com.edgington.constants.GameConstants;
	import com.edgington.valueobjects.ScoreCalculationsVO;

	public class ScoreCalculator
	{
		public static function getMaximumScore(numOfBeats:int):ScoreCalculationsVO{
			var scoreForBeats:int = (GameConstants.BEAT_PULSE_SCALE * GameConstants.POINTS_PER_BEAT_FRAME) * numOfBeats;
			var normalStreakBonus:int = (numOfBeats/GameConstants.BEAT_CHAIN_MULTIPLE_BONUS)*GameConstants.BEAT_CHAIN_BONUS_AMOUNT;
			var perfectStreakBonus:int = (numOfBeats/GameConstants.PERFECT_CHAIN_MULTIPLE_BONUS)*GameConstants.PERFECT_CHAIN_BONUS_AMOUNT;
			
			var total:int = (scoreForBeats + normalStreakBonus + perfectStreakBonus)*6;
			
			var scoreVO:ScoreCalculationsVO = new ScoreCalculationsVO();
			scoreVO.star_5 = total*0.65;
			scoreVO.star_4 = total*0.5;
			scoreVO.star_3 = total*0.35;
			scoreVO.star_2 = total*0.2;
			scoreVO.star_1 = total*0.1;
			
			return scoreVO;
		}
		
		
	}
}