package com.edgington.model
{
	import com.edgington.NativeMediaManager.NativeMediaVO;
	import com.edgington.constants.GameConstants;
	import com.edgington.constants.SoundConstants;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.valueobjects.ScoreCalculationsVO;
	import com.edgington.valueobjects.net.HighscoreServerVO;
	
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
		
		//This is the difficulty stored as a int (See "DifficultyTypes.as" for info)
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
		public var rogueBeatsHit:int = 0;
		
		public var totalBeats:int = 0;
		
		public var longestBeatsInARow:int = 0;
		public var longestPerfectsInARow:int = 0;
		
		public var beatCollectSignal:Signal;
		public var scoreUpdateSignal:Signal;
		
		
		public var currentPerfectHitStreak:int = 0;
		public var currentNormalHitStreak:int = 0;
		
		private var thisBeatScore:int = 0;
		
		public var totalPerfectBeatsScore:int = 0;
		
		public var currentTrackDetails:NativeMediaVO;
		public var currentTrackDifficulty:String;
		public var currentHectiness:int = 0;
		public var currentBeatRatio:int = 0;
		
		
		public var highscoreVO:HighscoreServerVO;
		
		private var currentBeatID:int = 0;
		private var lastBeatID:int = 0;
		private var lastStarBeatID:int = 0;
		
		//This is seperate from the beats streak so that we can deduct beats when a rogue beat is hit.
		//If a good beat is hit +1 if a rogue beat is hit -1, if the chain is breaken = 0
		public var beatsInARowForMultiplier:int = 0;
		public var maximumBeatsForMaximumMultiplier:int = 0;
		
		//Is true if the beat that has been parsed went off-screen
		private var wentOffscreen:Boolean;
		
		
		public var normalBeatsFromAnalyser:int = 0;
		public var rogueBeatsFromAnalyser:int = 0;
		
		//All the scores required to get a certain star rating for the track being played.
		public var scoreCalculations:ScoreCalculationsVO;
		
		//When posting to the server we will post the precise star rating so that we can calculate the XP rewarded.
		public var preciseStarRating:Number = 0;
		//This is the star rating to show in the game at the end of a track.
		public var starRating:int = 0;
		public var percentageOfBeatsHit:int; //ranges from 0 - 100;
		
		public var activeGame:Boolean = false;
		
		public function GameProxy()
		{
			LOG.create(this);
			addListeners();
			
			activeGame = true;
			
			maximumBeatsForMaximumMultiplier = (GameConstants.BEATS_PER_MULTIPLIER * GameConstants.MAXIMUM_MULTIPLIER) - GameConstants.BEATS_PER_MULTIPLIER*.6;
		}
		
		private function calculateEndGameResults():void{
			activeGame = false;
			if(score < scoreCalculations.star_1){
				preciseStarRating = score / scoreCalculations.star_1;
				starRating = 0;
			}
			else if(score < scoreCalculations.star_2){
				preciseStarRating = (score-scoreCalculations.star_1) / (scoreCalculations.star_2-scoreCalculations.star_1);
				preciseStarRating += 1;
				starRating = 1;
			}
			else if(score < scoreCalculations.star_3){
				preciseStarRating = (score-scoreCalculations.star_2) / (scoreCalculations.star_3-scoreCalculations.star_2);
				preciseStarRating += 2;
				starRating = 2;
			}
			else if(score < scoreCalculations.star_4){
				preciseStarRating = (score-scoreCalculations.star_3) / (scoreCalculations.star_4-scoreCalculations.star_3);
				preciseStarRating += 3;
				starRating = 3;
			}
			else if(score < scoreCalculations.star_5){
				preciseStarRating = (score-scoreCalculations.star_4) / (scoreCalculations.star_5-scoreCalculations.star_4);
				preciseStarRating += 4;
				starRating = 4;
			}
			else{
				preciseStarRating = 5;
				starRating = 5;
				if(hitsAllHits >= totalBeats){
					starRating = 6;
					if(rogueBeatsHit == 0){
						starRating = 7;
						if(hitsPerfectHits == hitsAllHits){
							starRating = 8;
						}
					}
				}
			}
			
			percentageOfBeatsHit = Math.floor((hitsAllHits / totalBeats)*100);
		}
		
		private function addListeners():void{
			activeStarPowerSignal = new Signal();
			starPowerFailedSignal = new Signal();
			beatCollectSignal = new Signal();
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
			if(rogueBeat && beatScale != -2){
				SoundManager.instance.loadAndPlaySFX(SoundConstants.getGameThemeSFXDirectory(SoundConstants.SFX_COLLECT_ROGUE_BEAT), "", 1);
				beatScale = 0;
				rogueBeatsHit++;
				wentOffscreen = false;
			}
			else if(rogueBeat && beatScale == -2){//A rogue beat has just left the screen.
				return;
			}
			else if(beatScale == -2){
				beatScale = 0;
				wentOffscreen = true;
			}
			else{
				wentOffscreen = false;
			}
			
			var thisBeatScore:int = 0; 
			currentBeatID = beatID;
			notificationString = "";
			
			if(starBeat){
				lastStarBeatID = beatID;
			}
			else{
				
			}
			
			//Generic scoring (without multipliers);
			if(!rogueBeat){
				thisBeatScore += addBeatScore(beatScale);
			}
			thisBeatScore += checkStreak(beatScale);
			thisBeatScore += checkPerfectStreak(beatScale);		
			checkMultiplierBeatStreak(beatScale, rogueBeat);
			
				
			
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
			if(beatScale == -5){
				calculateEndGameResults();
			}
		}
		
		/**
		 * Handles the multiplier
		 */
		private function checkMultiplier():void{
			if(starPowerActive){
				if(multiplier < (GameConstants.MAXIMUM_MULTIPLIER*2) || (Math.ceil(beatsInARowForMultiplier / GameConstants.BEATS_PER_MULTIPLIER)*2) < multiplier){
					multiplier = Math.ceil(beatsInARowForMultiplier / GameConstants.BEATS_PER_MULTIPLIER) * 2;
				}
				else{
					multiplier = GameConstants.MAXIMUM_MULTIPLIER*2;
				}
			}
			else{
				if(multiplier < GameConstants.MAXIMUM_MULTIPLIER || Math.ceil(beatsInARowForMultiplier / GameConstants.BEATS_PER_MULTIPLIER) < multiplier){
					multiplier = Math.ceil(beatsInARowForMultiplier / GameConstants.BEATS_PER_MULTIPLIER);
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
		 * Checks the length of the streak and deducts if a rogue beat is hit.
		 */
		private function checkMultiplierBeatStreak(beatScale:int, isRogue:Boolean):void{
			if(beatScale >= GameConstants.GOOD_THRESHOLD && maximumBeatsForMaximumMultiplier > beatsInARowForMultiplier){
				beatsInARowForMultiplier++;
			}
			else if(isRogue && !wentOffscreen){
				beatsInARowForMultiplier -= GameConstants.BEATS_PER_MULTIPLIER*.5;
				if(beatsInARowForMultiplier < 0){
					beatsInARowForMultiplier = 0;
				}
			}
			if(beatsInARowForMultiplier > 0 && beatScale < GameConstants.GOOD_THRESHOLD && !isRogue){
				beatsInARowForMultiplier = 0;
			}
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
				longestBeatsInARow = Math.max(currentNormalHitStreak, longestBeatsInARow);
			}
			if(currentNormalHitStreak > 0 && beatScale < GameConstants.GOOD_THRESHOLD){
				var streakBonus:int = Math.floor(currentNormalHitStreak/GameConstants.BEAT_CHAIN_MULTIPLE_BONUS)*GameConstants.BEAT_CHAIN_BONUS_AMOUNT;
				currentNormalHitStreak = 0;
				scoreNormalStreaks += streakBonus*multiplier;
				streaksNormal++;
				if(streakBonus != 0){
					notificationString = gettext("game_streak_bonus_notification", {points:streakBonus*multiplier});
				}
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
				longestPerfectsInARow = Math.max(currentPerfectHitStreak, longestPerfectsInARow);
			}
			if(currentPerfectHitStreak > 0 && beatScale < GameConstants.PERFECT_THRESHOLD){
				var perfectStreakBonus:int = Math.floor(currentPerfectHitStreak/GameConstants.PERFECT_CHAIN_MULTIPLE_BONUS)*GameConstants.PERFECT_CHAIN_BONUS_AMOUNT;
				if(currentPerfectHitStreak > 1){
					scorePerfectStreaks += perfectStreakBonus*multiplier;
					streaksPerfect++;
					if(perfectStreakBonus != 0){
						notificationString = gettext("game_perfect_streak_bonus_notification", {points:perfectStreakBonus*multiplier});
					}
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
			if(beatScale > 0){
				hitsAllHits++;
				scoreNormalBeatHits += ((beatScale / 0.05)*GameConstants.POINTS_PER_BEAT_FRAME)*multiplier;
			}
			else{
				return 0;
			}
			
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