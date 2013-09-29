package com.edgington.model
{
	import com.edgington.NativeMediaManager.NativeMediaVO;
	import com.edgington.constants.GameConstants;
	import com.edgington.constants.SoundConstants;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.valueobjects.net.HighscoreServerVO;
	
	import flash.media.Sound;
	
	import org.osflash.signals.Signal;

	public class GameProxy
	{
		
		public static var INSTANCE:GameProxy;
		
		public var isTournament:Boolean;
		
		public var pauseSignal:Signal;
		public var killGameEarlySignal:Signal;
		
		//If there is a event to report to the user dispatch this with a string
		public var notificationSignal:Signal;
		public var notificationString:String = "";
		
		//When star power beats are going to appear this star power signal will dispatch
		public var starPowerSignal:Signal;
		//GameProxy dispatches this signal if a star power beat is not perfect.
		public var starPowerFailedSignal:Signal;
		//When star power is activated
		public var starPowerActive:Boolean = false;
		
		//Star power active signal, dispatch this when either star power is on or off
		public var activeStarPowerSignal:Signal;
		
		//Multiplier signal, when the multiplier is updated this is dispatched
		public var multiplierSignal:Signal;
		
		//Multiplier signal, when the multiplier is updated this is dispatched
		public var colourChange:Signal;
		
		//If the current beats on the screen are star power beats
		public var starPowerBeatsRemainingBeforeActivation:int = 0;
		//Counts the number of star beats hit, if all beats are hit then it will add star power to the star power meter
		private var starPowerStarBeatsCollected:int = 0;
		private var starPowerBeatsAreOnScreen:Boolean = false;
		
		//Number of beats hit during star power
		public var beatsHitDuringStarPower:int = 0;
		
		
		public var score:int = 0;
		
		public var difficulty:int = 0;
		
		public var multiplier:int = 1;
		
		public var scorePerfectHits:int = 0;
		public var scorePerfectStreaks:int = 0;
		public var scoreNormalBeatHits:int = 0;
		public var scoreNormalStreaks:int = 0;
		
		public var scoreStarPowerBonus:int = 0;
		
		public var streaksPerfect:int = 0;
		public var streaksNormal:int = 0;
		
		public var hitsPerfectHits:int = 0;
		public var hitsAllHits:int = 0;
		
		public var totalBeats:int = 0;
		
		public var longestBeatsInARow:int = 0;
		public var longestPerfectsInARow:int = 0;
		
		public var beatCollectSignal:Signal;
		public var chainSignal:Signal;
		public var scoreUpdateSignal:Signal;
		
		
		public var currentPerfectHitStreak:int = 0;
		public var currentNormalHitStreak:int = 0;
		
		private var thisBeatScore:int = 0;
		
		public var totalPerfectBeatsScore:int = 0;
		
		public var currentTrackDetails:NativeMediaVO;
		
		public var highscoreVO:HighscoreServerVO;
		
		private var currentBeatID:int = 0;
		private var lastBeatID:int = 0;
		private var lastStarBeatID:int = 0;
		
		public function GameProxy()
		{
			LOG.create(this);
			addListeners();
		}
		
		private function addListeners():void{
			activeStarPowerSignal = new Signal();
			starPowerFailedSignal = new Signal();
			beatCollectSignal = new Signal();
			chainSignal = new Signal();
			scoreUpdateSignal = new Signal();
			pauseSignal = new Signal();
			killGameEarlySignal = new Signal();
			multiplierSignal = new Signal();
			colourChange = new Signal();
			notificationSignal = new Signal();
		}
		
		private function removeListeners():void{
			activeStarPowerSignal.removeAll();
			starPowerFailedSignal.removeAll();
			beatCollectSignal.removeAll();
			chainSignal.removeAll();
			scoreUpdateSignal.removeAll();
			pauseSignal.removeAll();
			multiplierSignal.removeAll();
			colourChange.removeAll();
			notificationSignal.removeAll();
		}
		
		public function addAdditonalListeners(colourSignal:Signal, starPowerSignal:Signal, addBeatSignal:Signal):void{
			colourSignal.add(handleColourChange);
			starPowerSignal.add(starPowerBeatsAreActive);
			addBeatSignal.add(beatAddedToScreen);
		}
		
		public function beatAddedToScreen(beatID:int):void{
			totalBeats++;
		}
		
		public function beatCollected(beatScale:Number, starBeat:Boolean, beatID:int, rogueBeat:Boolean):void{
			if(beatScale == -2){
				return;
			}
			var thisBeatScore:int = 0;
			currentBeatID = beatID;
			notificationString = "";
			
			if(starBeat){
				lastStarBeatID = beatID;
			}
			else{
				SoundManager.instance.loadAndPlaySFX(SoundConstants.getGameThemeSFXDirectory(SoundConstants.SFX_COLLECT_BEAT_1), "", 1);
			}
			
			//Generic scoring (without multipliers);
			thisBeatScore += addBeatScore(beatScale);
			thisBeatScore += checkStreak(beatScale);
			thisBeatScore += checkPerfectStreak(beatScale);			
			
			//Checks if there are stars on screen and handles.
			if(starPowerBeatsAreOnScreen){
				checkStarPower(beatScale, starBeat, beatID);
			}
			
			//Checks if star power has run out.
			if(starPowerActive){
				beatsHitDuringStarPower++;
				if(beatsHitDuringStarPower == 0){
					SoundManager.instance.loadAndPlaySFX(SoundConstants.getGameThemeSFXDirectory(SoundConstants.SFX_STAR_POWER_OFF), "", 1);
					starPowerActive = false;
					activeStarPowerSignal.dispatch()
				}
			}
			
			checkMultiplier();
			
			//Apply multiplier to score
			thisBeatScore = thisBeatScore*multiplier;
			score += thisBeatScore;
			
			//Dispatch appropriate events
			scoreUpdateSignal.dispatch();
			beatCollectSignal.dispatch(beatScale);
			
			if(notificationString != ""){
				notificationSignal.dispatch(notificationString);
			}
		}
		
		/**
		 * Handles the multiplier
		 */
		private function checkMultiplier():void{
			if(starPowerActive){
				if(multiplier < (GameConstants.MAXIMUM_MULTIPLIER*2) || (Math.ceil(currentNormalHitStreak / GameConstants.BEATS_PER_MULTIPLIER)*2) < multiplier){
					multiplier = Math.ceil(currentNormalHitStreak / GameConstants.BEATS_PER_MULTIPLIER) * 2;
				}
				else{
					multiplier = GameConstants.MAXIMUM_MULTIPLIER*2;
				}
			}
			else{
				if(multiplier < GameConstants.MAXIMUM_MULTIPLIER || Math.ceil(currentNormalHitStreak / GameConstants.BEATS_PER_MULTIPLIER) < multiplier){
					multiplier = Math.ceil(currentNormalHitStreak / GameConstants.BEATS_PER_MULTIPLIER);
				}
				else{
					multiplier = GameConstants.MAXIMUM_MULTIPLIER;
				}
			}
			
			if(multiplier == 0){
				multiplier++;
			}
			multiplierSignal.dispatch();
		}
		
		/**
		 * If there are star beats on the screen, this will handle it
		 */
		private function checkStarPower(beatScale:Number, starBeat:Boolean, beatID:int):void{
			if(!starBeat && lastStarBeatID > beatID){
				starPowerActivationFailed();
			}
			if(starBeat && beatScale < GameConstants.GOOD_THRESHOLD){
				starPowerActivationFailed();
			}
			if(!starBeat && starPowerStarBeatsCollected > 0){
				starPowerActivationFailed();
			}
			if(starBeat){
				starPowerStarBeatsCollected++;
				SoundManager.instance.loadAndPlaySFX(SoundConstants.getGameThemeSFXDirectory(SoundConstants["SFX_STAR_"+starPowerStarBeatsCollected]), "", 1);
				if(starPowerStarBeatsCollected == GameConstants.STAR_POWER_BEATS_TO_COLLECT){
					activeStarPower();
				}
			}
		}
		
		/**
		 * Checks the streak for a chain of beats
		 */
		private function checkStreak(beatScale:Number):int{
			if(beatScale >= GameConstants.GOOD_THRESHOLD){
				currentNormalHitStreak++;
			}
			if(currentNormalHitStreak > 0 && beatScale < GameConstants.GOOD_THRESHOLD){
				var streakBonus:int = Math.floor(currentNormalHitStreak/GameConstants.BEAT_CHAIN_MULTIPLE_BONUS)*GameConstants.BEAT_CHAIN_BONUS_AMOUNT;
				currentNormalHitStreak = 0;
				scoreNormalStreaks += streakBonus*multiplier;
				streaksNormal++;
				notificationString = gettext("game_streak_bonus_notification", {points:streakBonus*multiplier});
				return streakBonus;
			}
			return 0;
		}
		
		/**
		 * Checks the streak for a chain of perfect beats
		 */
		private function checkPerfectStreak(beatScale:Number):int{
			if(beatScale >= GameConstants.PERFECT_THRESHOLD){
				currentPerfectHitStreak++;
			}
			if(currentPerfectHitStreak > 0 && beatScale < GameConstants.PERFECT_THRESHOLD){
				var perfectStreakBonus:int = Math.floor(currentPerfectHitStreak/GameConstants.PERFECT_CHAIN_MULTIPLE_BONUS)*GameConstants.PERFECT_CHAIN_BONUS_AMOUNT;
				if(currentPerfectHitStreak > 1){
					scorePerfectStreaks += perfectStreakBonus*multiplier;
					streaksPerfect++;
					notificationString = gettext("game_perfect_streak_bonus_notification", {points:perfectStreakBonus*multiplier});
					currentPerfectHitStreak = 0;
					return perfectStreakBonus;
				}
				currentPerfectHitStreak = 0;
			}
			return 0;
		}
		
		/**
		 * Calculate the beat score
		 */
		private function addBeatScore(beatScale:Number):int{
			if(beatScale >= GameConstants.PERFECT_THRESHOLD){
				hitsPerfectHits++;
				scorePerfectHits += ((beatScale / 0.05)*GameConstants.POINTS_PER_BEAT_FRAME)*multiplier;
			}
			hitsAllHits++;
			scoreNormalBeatHits += ((beatScale / 0.05)*GameConstants.POINTS_PER_BEAT_FRAME)*multiplier;
			
			return ((beatScale / 0.05)*GameConstants.POINTS_PER_BEAT_FRAME);
		}
		
		private function starPowerBeatsAreActive():void{
			starPowerBeatsRemainingBeforeActivation = GameConstants.STAR_POWER_BEATS_TO_COLLECT;
			starPowerBeatsAreOnScreen = true;
		}
		
		private function handleColourChange():void{
			colourChange.dispatch();
		}
		
		/**
		 * If there are stars on the screen but they were missed or collected incorrectly, fire this method.
		 */
		private function starPowerActivationFailed():void{
			starPowerFailedSignal.dispatch();
			starPowerStarBeatsCollected = 0;
			starPowerBeatsRemainingBeforeActivation = 0;
			starPowerBeatsAreOnScreen = false;
		}
		
		private function activeStarPower():void{
			starPowerBeatsRemainingBeforeActivation = 0;
			starPowerStarBeatsCollected = 0;
			starPowerBeatsAreOnScreen = false;
			beatsHitDuringStarPower -= Math.max(GameConstants.STAR_POWER_ACTIVE_FOR_X_BEATS, -GameConstants.STAR_POWER_MAXIMUM_ALLOWED);
			starPowerActive = true;
			SoundManager.instance.loadAndPlaySFX(SoundConstants.getGameThemeSFXDirectory(SoundConstants.SFX_STAR_POWER_ON), "", 1);
			activeStarPowerSignal.dispatch();
			checkMultiplier();
		}
		
		public static function deleteInstance():void{
			if(INSTANCE != null){
				LOG.destroy(INSTANCE);
				INSTANCE.removeListeners();
				INSTANCE = null;
			}
		}
		
		public static function getInstance():GameProxy{
			if(INSTANCE == null){
				INSTANCE = new GameProxy();
			}
			return INSTANCE;
		}
	}
}