package com.edgington.view
{
	import com.edgington.constants.Constants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.SoundConstants;
	import com.edgington.model.SoundManager;
	import com.edgington.net.UserData;
	import com.edgington.types.DeviceTypes;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.debug.LOG;
	import com.edgington.view.assets.AssetCacher;
	import com.edgington.view.game.analysis.ViewLoadAndAnalysisProgress;
	import com.edgington.view.game.analysis.ViewTrackAnalysis;
	import com.edgington.view.huds.hudAchievements;
	import com.edgington.view.huds.hudBackground;
	import com.edgington.view.huds.hudCredits;
	import com.edgington.view.huds.hudDownloadTournamentData;
	import com.edgington.view.huds.hudInboxMenu;
	import com.edgington.view.huds.hudLeaderboardsMain;
	import com.edgington.view.huds.hudLevel;
	import com.edgington.view.huds.hudMainMenu;
	import com.edgington.view.huds.hudPurchase;
	import com.edgington.view.huds.hudRedeemCode;
	import com.edgington.view.huds.hudSettingsMenu;
	import com.edgington.view.huds.hudSummaryScreen;
	import com.edgington.view.huds.hudThemesMenu;
	import com.edgington.view.huds.hudTournamentEntry;
	import com.edgington.view.huds.hudTrackHandling;
	import com.edgington.view.huds.miniHudFacebookLogin;
	import com.edgington.view.huds.miniHudHandSelection;
	import com.edgington.view.huds.miniHudSocialHighscores;
	import com.edgington.view.huds.miniHudStartTutorial;
	import com.edgington.view.huds.miniHudSummaryMenuDetails;
	import com.edgington.view.huds.miniHudTrackScores;
	import com.edgington.view.huds.miniHudiPhoneSearch;
	import com.edgington.view.huds.elements.element_user_hud;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	
	import flash.display.Sprite;
	import flash.display.StageQuality;
	
	import org.osflash.signals.Signal;
	
	public class GameStateHandler
	{
		
		private var appRoot:Sprite;
		
		private var onScreenState:Sprite;
		
		public var removeInterfaceSignal:Signal;
		
		private var background:hudBackground;
		private var userHud:element_user_hud;
		
		public function GameStateHandler(_appRoot:Sprite)
		{
			LOG.create(this);
			this.appRoot = _appRoot;
			removeInterfaceSignal = new Signal();
			removeInterfaceSignal.add(removeOnScreenState);
			
			setupBackground();
		}
		
		public function loadState():void{
			LOG.info("Changing game state to: " + DynamicConstants.CURRENT_GAME_STATE);
			changeQuality(StageQuality.LOW);
			switch(DynamicConstants.CURRENT_GAME_STATE){
				case GameStateTypes.MESSAGE_FACEBOOK_LOGIN:
					removeUserHud();
					onScreenState = new miniHudFacebookLogin(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.MENU_MAIN:
					DynamicConstants.DISABLE_RELOAD = false;
					if(UserData.getInstance().firstPlay){
						DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.TUTORIAL_BEGIN;
						removeUserHud();
						onScreenState = new miniHudStartTutorial(removeInterfaceSignal);
						positionHudAtRandom();
						background.newHudActive(onScreenState);
						UserData.getInstance().firstPlay = false;
					}
					else{
						checkMainHud();
						userHud.animate(true);
						onScreenState = new hudMainMenu(removeInterfaceSignal);
						positionHudAtRandom();
						background.newHudActive(onScreenState);
					}
					break;
				case GameStateTypes.MENU_SETTINGS:
					onScreenState = new hudSettingsMenu(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.GAME_TRACK_SELECTION:
					removeUserHud();
					onScreenState = new hudTrackHandling(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.GAME_LOADING:
					AssetCacher.CLEAR_MEMORY();
					removeUserHud();
					onScreenState = new ViewLoadAndAnalysisProgress(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.GAME_ANALYSIS:
					AssetCacher.CLEAR_MEMORY();
					removeUserHud();
					onScreenState = new ViewTrackAnalysis(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.GAME_MAIN:
					AssetCacher.CLEAR_MEMORY();
					onScreenState = new GameView(removeInterfaceSignal);
					destroyBackground();
					break;
				case GameStateTypes.SUMMARY_MENU:
					onScreenState = new hudSummaryScreen(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.SUMMARY_DETAILS:
					onScreenState = new miniHudSummaryMenuDetails(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.SUMMARY_HIGHSCORES:
					onScreenState = new miniHudSocialHighscores(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.SETTINGS_HAND_SELECTION:
					onScreenState = new miniHudHandSelection(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.HIGHSCORES_MAIN:
					onScreenState = new hudLeaderboardsMain(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.HIGHSCORES_IPHONE_SEARCH:
					onScreenState = new miniHudiPhoneSearch(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.HIGHSCORES_TRACK:
					onScreenState = new miniHudTrackScores(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.PURCHASES:
					DynamicConstants.DISABLE_RELOAD = true;
					onScreenState = new hudPurchase(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.PROFILE_THEME_SELECTION:
					onScreenState = new hudThemesMenu(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.TOURNAMENT_ENTRY:
					checkMainHud();
					onScreenState = new hudTournamentEntry(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.TOURNAMENT_DOWNLOAD:
					removeUserHud();
					onScreenState = new hudDownloadTournamentData(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.MENU_INBOX:
					onScreenState = new hudInboxMenu(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.MENU_ACHIEVEMENTS:
					onScreenState = new hudAchievements(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.TUTORIAL_BEGIN:
					removeUserHud();
					onScreenState = new miniHudStartTutorial(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.MENU_REDEEM:
					onScreenState = new hudRedeemCode(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.MENU_CREDITS:
					onScreenState = new hudCredits(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.SUMMARY_LEVEL:
					onScreenState = new hudLevel(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
			}
			if(onScreenState != null){
				appRoot.addChild(onScreenState);
				if(userHud != null){
					if(DynamicConstants.CURRENT_GAME_STATE != GameStateTypes.MENU_MAIN){
						userHud.animate(false);
					}
					else{
						userHud.animate(true);
					}
					appRoot.setChildIndex(userHud, appRoot.numChildren-1);
				}
			}
			else{
				LOG.fatal("No hud for GameStateHandle to load");
			}
		}
		
		private function checkMainHud():void{
			if(userHud == null){
				userHud = new element_user_hud();
				userHud.currentHudSignal = removeInterfaceSignal;
				appRoot.addChild(userHud);
			}
		}
		
		private function removeUserHud():void{
			if(userHud != null){
				appRoot.removeChild(userHud);
				userHud = null;
			}
		}
		
		private function positionHudAtRandom():void{
			switch(Math.round(Math.random())){
				case 0:
					switch(Math.floor(Math.random())){
						case 0:
								onScreenState.x = Math.round(Math.random()*200)+DynamicConstants.SCREEN_WIDTH;
								onScreenState.y = Math.round(Math.random()*(DynamicConstants.SCREEN_HEIGHT*2));
							break;
						case 1:
								onScreenState.x = Math.round(Math.random()*-200)-onScreenState.width;
								onScreenState.y = Math.round(Math.random()*(DynamicConstants.SCREEN_HEIGHT*2));
							break;
					}
					break;
				case 1:
					switch(Math.floor(Math.random())){
						case 0:
							onScreenState.x = Math.round(Math.random()*(DynamicConstants.SCREEN_WIDTH*2))-DynamicConstants.SCREEN_WIDTH;
							onScreenState.y = Math.round((Math.random()*-200) - onScreenState.height);
							break;
						case 1:
							onScreenState.x = Math.round(Math.random()*(DynamicConstants.SCREEN_WIDTH));
							onScreenState.y = Math.round((Math.random()*200) + DynamicConstants.SCREEN_HEIGHT);
							break;
					}
					break;
			}
			SoundManager.getInstance().loadAndPlaySFX(SoundConstants.SFX_MENU_TRANSITION, "", 1);
			TweenMax.to(onScreenState, 1, {x:0, y:0, ease:Quad.easeInOut, onStart:background.newHudActive, onStartParams:[onScreenState], onComplete:changeQuality, onCompleteParams:[StageQuality.HIGH]});
		}
		
		private function removeOnScreenState():void{
			appRoot.removeChild(onScreenState);
			onScreenState = null;
			if(background == null && DynamicConstants.CURRENT_GAME_STATE != GameStateTypes.GAME_MAIN){
				setupBackground();
				TweenLite.delayedCall(2, loadState);
			}
			else{
				TweenMax.killAll();
				loadState();
			}
		}
		
		private function setupBackground():void{
			background = new hudBackground();
			appRoot.addChild(background);
		}
		
		private function changeQuality(quality:String):void{
			if(DynamicConstants.CURRENT_GAME_STATE == GameStateTypes.GAME_ANALYSIS){
				//appRoot.stage.quality = StageQuality.LOW;
			}
			else{
				if(quality == StageQuality.HIGH){
					if(DynamicConstants.DEVICE_NAME == Constants.IPHONE_4 || DynamicConstants.DEVICE_NAME == Constants.IPAD_2){
						appRoot.stage.quality = StageQuality.LOW;	
					}
					else if(DynamicConstants.DEVICE_NAME == Constants.IPAD_3 || DynamicConstants.DEVICE_NAME == Constants.IPHONE_4S){
						appRoot.stage.quality = StageQuality.MEDIUM;	
					}
					else{
						appRoot.stage.quality = quality;	
					}
				}
				else{
					appRoot.stage.quality = quality;	
				}
			}
		}
		
		private function destroyBackground():void{
			if(background){
				appRoot.removeChild(background);
				background = null;
			}
		}
	}
}