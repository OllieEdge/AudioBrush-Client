package com.edgington.view
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.debug.LOG;
	import com.edgington.view.game.analysis.ViewLoadAndAnalysisProgress;
	import com.edgington.view.game.analysis.ViewTrackAnalysis;
	import com.edgington.view.huds.hudBackground;
	import com.edgington.view.huds.hudDownloadTournamentData;
	import com.edgington.view.huds.hudInboxMenu;
	import com.edgington.view.huds.hudLeaderboardsMain;
	import com.edgington.view.huds.hudMainMenu;
	import com.edgington.view.huds.hudPurchase;
	import com.edgington.view.huds.hudSettingsMenu;
	import com.edgington.view.huds.hudSummaryScreen;
	import com.edgington.view.huds.hudThemesMenu;
	import com.edgington.view.huds.hudTournamentEntry;
	import com.edgington.view.huds.miniHudFacebookLogin;
	import com.edgington.view.huds.miniHudHandSelection;
	import com.edgington.view.huds.miniHudSocialHighscores;
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
		
		private var removeInterfaceSignal:Signal;
		
		private var background:hudBackground;
		private var userHud:element_user_hud;
		
		public function GameStateHandler(_appRoot:Sprite)
		{
			LOG.create(this);
			this.appRoot = _appRoot;
			removeInterfaceSignal = new Signal();
			removeInterfaceSignal.add(removeOnScreenState);
			
			setupBackground();
			
			loadState();
		}
		
		private function loadState():void{
			LOG.info("Changing game state to: " + DynamicConstants.CURRENT_GAME_STATE);
			changeQuality(StageQuality.LOW);
			switch(DynamicConstants.CURRENT_GAME_STATE){
				case GameStateTypes.MESSAGE_FACEBOOK_LOGIN:
					onScreenState = new miniHudFacebookLogin(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.MENU_MAIN:
					checkMainHud();
					userHud.animate(true);
					onScreenState = new hudMainMenu(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.MENU_SETTINGS:
					onScreenState = new hudSettingsMenu(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.GAME_LOADING:
					removeUserHud();
					onScreenState = new ViewLoadAndAnalysisProgress(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.GAME_ANALYSIS:
					removeUserHud();
					onScreenState = new ViewTrackAnalysis(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.GAME_MAIN:
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
					onScreenState = new hudTournamentEntry(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.TOURNAMENT_DOWNLOAD:
					onScreenState = new hudDownloadTournamentData(removeInterfaceSignal);
					positionHudAtRandom();
					background.newHudActive(onScreenState);
					break;
				case GameStateTypes.MENU_INBOX:
					onScreenState = new hudInboxMenu(removeInterfaceSignal);
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
			TweenMax.to(onScreenState, 1, {x:0, y:0, ease:Quad.easeInOut, onStart:background.newHudActive, onStartParams:[onScreenState], onComplete:changeQuality, onCompleteParams:[StageQuality.BEST]});
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
			appRoot.stage.quality = quality;
		}
		
		private function destroyBackground():void{
			if(background){
				appRoot.removeChild(background);
				background = null;
			}
		}
	}
}