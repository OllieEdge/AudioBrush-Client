package com.edgington.view.huds.elements
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.GameProxy;
	import com.edgington.types.FontFaceType;
	import com.edgington.util.NumberFormat;
	import com.edgington.util.localisation.getfont;
	import com.edgington.util.localisation.gettext;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class element_summaryDetailsOutcome extends Sprite
	{
		
		private var details:ui_summaryOutcomeDetails;
		
		public function element_summaryDetailsOutcome()
		{
			super();
			details = new ui_summaryOutcomeDetails();
			
			getfont(details.txt_beatsHit, FontFaceType.BOLD);
			getfont(details.txt_beatsHitText, FontFaceType.REGULAR);
			getfont(details.txt_comp_level_title, FontFaceType.BOLD);
			getfont(details.txt_hect_level_title, FontFaceType.BOLD);
			getfont(details.txt_longestStreak, FontFaceType.BOLD);
			getfont(details.txt_longestStreakText, FontFaceType.REGULAR);
			getfont(details.txt_perfectBonusTotal, FontFaceType.BOLD);
			getfont(details.txt_perfectBonusTotalText, FontFaceType.REGULAR);
			getfont(details.txt_perfectHits, FontFaceType.BOLD);
			getfont(details.txt_perfectHitsText, FontFaceType.REGULAR);
			getfont(details.txt_rogueHits, FontFaceType.BOLD);
			getfont(details.txt_rogueHitsText, FontFaceType.REGULAR);
			
			details.txt_beatsHitText.text = gettext("summary_screen_detail_beats_hit");
			details.txt_rogueHitsText.text = gettext("summary_screen_detail_rogue_beats_hit");
			details.txt_longestStreakText.text = gettext("summary_screen_detail_longest_streak");
			
			details.txt_perfectHitsText.text = gettext("summary_screen_detail_perfect_hits");
			details.txt_perfectBonusTotalText.text = gettext("summary_screen_detail_perfect_bonuses");
			
			details.txt_beatsHit.text = String(NumberFormat.addThreeDigitCommaSeperator(GameProxy.INSTANCE.hitsAllHits) + "/" + NumberFormat.addThreeDigitCommaSeperator(GameProxy.INSTANCE.totalBeats));
			details.txt_rogueHits.text = String(NumberFormat.addThreeDigitCommaSeperator(GameProxy.INSTANCE.rogueBeatsHit) + "/" + NumberFormat.addThreeDigitCommaSeperator(GameProxy.INSTANCE.rogueBeatsFromAnalyser));
			//details.txt_beatsScore.text = NumberFormat.addThreeDigitCommaSeperator(GameProxy.INSTANCE.scoreNormalBeatHits);
			//details.txt_beatsStreaks.text = NumberFormat.addThreeDigitCommaSeperator(GameProxy.INSTANCE.streaksNormal);
			details.txt_longestStreak.text = NumberFormat.addThreeDigitCommaSeperator(GameProxy.INSTANCE.longestBeatsInARow);
			//details.txt_totalNormalScore.text = NumberFormat.addThreeDigitCommaSeperator(GameProxy.INSTANCE.scoreNormalBeatHits + GameProxy.INSTANCE.scoreNormalStreaks);
			
			details.txt_perfectHits.text = NumberFormat.addThreeDigitCommaSeperator(GameProxy.INSTANCE.hitsPerfectHits);
			//details.txt_perfectStreaks.text = NumberFormat.addThreeDigitCommaSeperator(GameProxy.INSTANCE.streaksPerfect);
			details.txt_perfectBonusTotal.text = NumberFormat.addThreeDigitCommaSeperator(GameProxy.INSTANCE.scorePerfectStreaks);
			//details.txt_starPowerBonusTotal.text = NumberFormat.addThreeDigitCommaSeperator(GameProxy.INSTANCE.scoreStarPowerBonus);
			//details.txt_totalBonusPoints.text = NumberFormat.addThreeDigitCommaSeperator(GameProxy.INSTANCE.scorePerfectStreaks + GameProxy.INSTANCE.scoreStarPowerBonus);
			
			details.txt_comp_level_title.text = gettext("summary_screen_detail_complexity_title");
			details.txt_hect_level_title.text = gettext("summary_screen_detail_hecticness_title");
			
			details.difficulty_comp.gotoAndStop(GameProxy.INSTANCE.currentBeatRatio);
			details.difficulty_hect.gotoAndStop(GameProxy.INSTANCE.currentHectiness);
			
			this.scaleX = this.scaleY = DynamicConstants.MESSAGE_SCALE;
			
			details.cacheAsBitmap = true;
			
			this.addChild(details);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		private function destroy(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			details = null;
		}
	}
}