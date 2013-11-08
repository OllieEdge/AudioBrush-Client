package com.edgington.model.gamecenter
{
	import com.adobe.ane.gameCenter.GameCenterAchievement;
	import com.adobe.ane.gameCenter.GameCenterAchievementEvent;
	import com.adobe.ane.gameCenter.GameCenterAuthenticationEvent;
	import com.adobe.ane.gameCenter.GameCenterController;
	import com.edgington.util.debug.LOG;
	
	public class GameCenterManager
	{
		
		private static var INSTANCE:GameCenterManager;
		
		public var isGameCenterAvailable:Boolean = false;
		
		private var gcController:GameCenterController;
		
		public function GameCenterManager()
		{
			LOG.create(GameCenterManager);
			
			if(false/**GameCenterController.isSupported*/){
				isGameCenterAvailable = true;
				gcController = new GameCenterController();
				addListeners();
				if (!gcController.authenticated) {
					gcController.addEventListener(GameCenterAuthenticationEvent.PLAYER_AUTHENTICATED, authTrue);
					gcController.authenticate();
				}
			}
			else{
				LOG.warning("GameCenter not available on this platform");
				isGameCenterAvailable = false;
			}
		}
		
		public function showAchievements():void{
			if(isGameCenterAvailable){
				if(gcController.authenticated){
					gcController.showAchievementsView();
				}
				else{
					gcController.authenticate();
				}
			}
		}
		
		public function reportAchievement(achievementID:String, progress:int):void{
			if(isGameCenterAvailable && gcController.authenticated){
				gcController.submitAchievement(achievementID, progress);
			}
		}
		
		private function addListeners():void{
			//Authenticate 
			gcController.addEventListener(GameCenterAuthenticationEvent.PLAYER_NOT_AUTHENTICATED,authFailed);
			gcController.addEventListener(GameCenterAuthenticationEvent.PLAYER_AUTHENTICATION_CHANGED,authChanged);
			//Achievements
			gcController.addEventListener(GameCenterAchievementEvent.ACHIEVEMENTS_VIEW_FINISHED,achViewFinished);
			gcController.addEventListener(GameCenterAchievementEvent.ACHIEVEMENTS_LOADED,achLoaded);
			gcController.addEventListener(GameCenterAchievementEvent.ACHIEVEMENTS_FAILED,achFailed);
			gcController.addEventListener(GameCenterAchievementEvent.SUBMIT_ACHIEVEMENT_SUCCEEDED,achSubmittedSuccess);
			gcController.addEventListener(GameCenterAchievementEvent.SUBMIT_ACHIEVEMENT_FAILED,achSubmitFailed);
			gcController.addEventListener(GameCenterAchievementEvent.RESET_ACHIEVEMENTS_SUCCEEDED,resetSuccess);
			gcController.addEventListener(GameCenterAchievementEvent.RESET_ACHIEVEMENTS_FAILED,resetUnsuccess);
		}
		
		protected function authTrue(event:GameCenterAuthenticationEvent):void
		{
			gcController.resetAchievements();
			if(gcController.localPlayer!=null)
				LOG.gamecenter("Localplayer:" + gcController.localPlayer.alias+"playerID:"+gcController.localPlayer.id + "playerIsFriend"+gcController.localPlayer.isFriend);
			else LOG.gamecenter("Didn't authenticate.");
		}
		
		protected function achSubmitFailed(event:GameCenterAchievementEvent):void
		{
			LOG.gamecenter(GameCenterAchievementEvent.SUBMIT_ACHIEVEMENT_FAILED);
			
		}
		
		protected function achSubmittedSuccess(event:GameCenterAchievementEvent):void
		{
			LOG.gamecenter(GameCenterAchievementEvent.SUBMIT_ACHIEVEMENT_SUCCEEDED);
		}
		
		protected function achFailed(event:GameCenterAchievementEvent):void
		{
			LOG.gamecenter(GameCenterAchievementEvent.ACHIEVEMENTS_FAILED);
			
		}
		
		protected function achLoaded(event:GameCenterAchievementEvent):void
		{
			LOG.gamecenter(GameCenterAchievementEvent.ACHIEVEMENTS_LOADED);
			for each ( var x:GameCenterAchievement in event.achievements)
			{
				//x.addEventListener(GameCenterAchievementEvent.ACHIEVEMENT_IMAGE_LOADED,achImageLoaded);
				//x.addEventListener(GameCenterAchievementEvent.ACHIEVEMENT_IMAGE_FAILED,achImageFailed);
				//x.requestImage();
				LOG.gamecenter("\nAchieved Description"+x.achievedDescription + " Hidden " + x.hidden + " Identifier " + x.identifier + "MAxpoints  " + 
					x.maximumPoints + " Title " + x.title + " UnachievedDescription " + x.unachievedDescription);
			}
		}
		
		protected function achImageFailed(event:GameCenterAchievementEvent):void
		{
			LOG.gamecenter(GameCenterAchievementEvent.ACHIEVEMENT_IMAGE_FAILED);
		}
		
		protected function achImageLoaded(event:GameCenterAchievementEvent):void
		{
			LOG.gamecenter(GameCenterAchievementEvent.ACHIEVEMENT_IMAGE_LOADED);
		}
		
		protected function achViewFinished(event:GameCenterAchievementEvent):void
		{
			LOG.gamecenter(GameCenterAchievementEvent.ACHIEVEMENTS_VIEW_FINISHED);
		}
		
		protected function resetSuccess(event:GameCenterAchievementEvent):void
		{
			LOG.gamecenter(GameCenterAchievementEvent.RESET_ACHIEVEMENTS_SUCCEEDED);			
		}
		
		protected function resetUnsuccess(event:GameCenterAchievementEvent):void
		{
			LOG.gamecenter(GameCenterAchievementEvent.RESET_ACHIEVEMENTS_FAILED);
		}
		
		protected function authChanged(event:GameCenterAuthenticationEvent):void
		{
			
			LOG.gamecenter(GameCenterAuthenticationEvent.PLAYER_AUTHENTICATION_CHANGED);
		}
		protected function authFailed(event:GameCenterAuthenticationEvent):void
		{
			LOG.gamecenter(GameCenterAuthenticationEvent.PLAYER_NOT_AUTHENTICATED);
		}
		
		
		public static function getInstance():GameCenterManager{
			if(INSTANCE == null){
				INSTANCE = new GameCenterManager();
			}
			return INSTANCE;
		}
	}
}