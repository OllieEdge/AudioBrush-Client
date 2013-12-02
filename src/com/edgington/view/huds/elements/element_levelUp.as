package com.edgington.view.huds.elements
{
	import com.edgington.constants.Constants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.SoundConstants;
	import com.edgington.model.GameLevelInformationHandler;
	import com.edgington.model.SoundManager;
	import com.edgington.model.calculators.LevelCalculator;
	import com.edgington.net.UserData;
	import com.edgington.types.FontFaceType;
	import com.edgington.util.NumberFormat;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.getfont;
	import com.edgington.util.localisation.gettext;
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class element_levelUp extends Sprite
	{
		
		private var level:ui_level_up_screen;
		
		private var currentUserXP:int = 0;
		private var newUserXP:int = 0;
		private var currentReportedLevel:int;
		
		private var tweenLevelBar:TweenMax;
		
		private var currentCreditsRewarded:int = 0;
		
		public function element_levelUp()
		{
			super();
			
			addListeners();
			
			setupVisuals();
			
		}
		
		private function addListeners():void{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		private function setupVisuals():void{
			level = new ui_level_up_screen();
			
			getfont(level.txt_credits, FontFaceType.REGULAR);
			//getfont(level.txt_currentLevel, FontFaceType.BOLD);
			getfont(level.txt_currentXP, FontFaceType.REGULAR);
			getfont(level.txt_levelup, FontFaceType.BOLD);
			getfont(level.txt_nextLevel, FontFaceType.BOLD);
			getfont(level.txt_nextLvlXP, FontFaceType.REGULAR);
			getfont(level.txt_prevLevel, FontFaceType.BOLD);
			
			level.scaleX = level.scaleY = DynamicConstants.MESSAGE_SCALE;
			level.txt_levelup.text = gettext("level_screen_level_up");
			level.txt_levelup.visible = false;
			level.credits_background.visible = false;
			level.txt_credits.visible = false;
			level.txt_prevLevel.text = gettext("level_screen_previous_level", {level:GameLevelInformationHandler.getInstance().levelBeforeGame});
			level.txt_nextLevel.text = gettext("level_screen_next_level", {level:GameLevelInformationHandler.getInstance().levelBeforeGame+1});
			level.txt_nextLvlXP.text = NumberFormat.addThreeDigitCommaSeperator(LevelCalculator.levelXPRequiredArray[GameLevelInformationHandler.getInstance().levelBeforeGame]);
			level.txt_currentXP.text = NumberFormat.addThreeDigitCommaSeperator(UserData.getInstance().userProfile.xp);
			level.txt_currentLevel.text = String(GameLevelInformationHandler.getInstance().levelBeforeGame);
			
			currentUserXP = UserData.getInstance().userProfile.xp;
			currentReportedLevel = GameLevelInformationHandler.getInstance().levelBeforeGame;
			
			var currentLevelXP:int = 0;
			var startTotalDivider:Number;
			if(currentReportedLevel == 0){
				currentLevelXP = 0;
				startTotalDivider = 0;
			}
			else{
				startTotalDivider = LevelCalculator.levelXPRequiredPerLevelArray[Math.max(currentReportedLevel-1, 0)]
				currentLevelXP = LevelCalculator.levelXPRequiredArray[currentReportedLevel-1];	
			}
			
			var startBarScale:Number = (GameLevelInformationHandler.getInstance().xpBeforeGame-currentLevelXP) / LevelCalculator.levelXPRequiredPerLevelArray[currentReportedLevel];
			var endBarScale:Number = (currentUserXP-currentLevelXP) / LevelCalculator.levelXPRequiredPerLevelArray[currentReportedLevel];
			
			level.ui_progressbar.bar.scaleX = startBarScale;
			tweenLevelBar = TweenMax.to(level.ui_progressbar.bar, 1, {delay:1.5, scaleX:endBarScale, ease:Quad.easeOut, onUpdate:checkBarScale, onStart:playSound});
			
			this.addChild(level);
		}
		
		private function checkBarScale():void{
			if(level.ui_progressbar.bar.scaleX >= 1){
				SoundManager.instance.loadAndPlaySFX(SoundConstants.SFX_LEVEL, "", 1);
				tweenLevelBar.kill();
				currentReportedLevel++;
				
				LOG.createCheckpoint("LEVEL: " + currentReportedLevel);
				
				level.txt_currentLevel.text = String(currentReportedLevel);
				level.ui_progressbar.bar.scaleX = 0;
				var currentLevelXP:int = 0;
				
				currentCreditsRewarded += Math.ceil(Constants.CREDITS_PER_LEVEL + (Constants.CREDITS_PER_LEVEL*(currentReportedLevel*0.3)));

				level.credits_background.visible = true;
				level.txt_credits.text = gettext("level_screen_credits_rewarded", {credits:currentCreditsRewarded});
				level.txt_credits.visible = true;
				level.txt_levelup.visible = true;
				
				level.txt_prevLevel.text = gettext("level_screen_previous_level", {level:currentReportedLevel});
				level.txt_nextLevel.text = gettext("level_screen_next_level", {level:currentReportedLevel+1});
				
				level.txt_currentXP.text = NumberFormat.addThreeDigitCommaSeperator(LevelCalculator.levelXPRequiredArray[currentReportedLevel-1]);
				level.txt_nextLvlXP.text = NumberFormat.addThreeDigitCommaSeperator(LevelCalculator.levelXPRequiredArray[currentReportedLevel]);
				
				
				currentLevelXP = LevelCalculator.levelXPRequiredArray[currentReportedLevel-1];
				var endBarScale:Number = (currentUserXP-currentLevelXP) / LevelCalculator.levelXPRequiredPerLevelArray[currentReportedLevel];
				
				level.ui_progressbar.bar.scaleX = 0;
				tweenLevelBar = TweenMax.to(level.ui_progressbar.bar, 1, {scaleX:endBarScale, ease:Quad.easeOut, onUpdate:checkBarScale});
			}
		}
		
		private function playSound():void{
			SoundManager.instance.loadAndPlaySFX(SoundConstants.SFX_LEVELING, "", 1);
		}
		
		private function animateLeveling():void{
			
		}
		
		private function destroy(e:Event):void{
			if(currentCreditsRewarded > 0){
				UserData.getInstance().addCredits(currentCreditsRewarded);
			}
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
		}
	}
}