package com.edgington.net
{
	import com.edgington.constants.AchievementConstants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.FacebookConstants;
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.model.gamecenter.GameCenterManager;
	import com.edgington.net.helpers.NetResponceHandler;
	import com.edgington.util.debug.LOG;
	import com.edgington.valueobjects.net.ServerAchievementVO;
	import com.edgington.view.huds.vo.AchievementVO;
	import com.milkmangames.nativeextensions.GoViral;
	
	import flash.net.SharedObject;
	
	import org.osflash.signals.Signal;

	public class AchievementData extends BaseData
	{
		private static var INSTANCE:AchievementData;
		
		private var achievementData:SharedObject = SharedObject.getLocal("ab_achievementData");
		
		public var userAchievements:Vector.<AchievementVO>;
		public var achievementUpdateSignal:Signal;
		
		public var achievememtUnlockedSignal:Signal;
		
		public function AchievementData()
		{
			LOG.create(this);
			super("achievement", "achievements");
			
			achievememtUnlockedSignal = new Signal();
			achievementUpdateSignal = new Signal();
			
			AchievementConstants.populateAchievements();
			
			var achievements:Vector.<AchievementVO>;
			if(achievementData.data.achievements == null || achievementData.data.achievements.length < AchievementConstants.achievements.length){
				achievementData.data.achievements = AchievementConstants.achievements.concat();
				achievements = achievementData.data.achievements;
				LOG.info("Created a new achievements SharedObejct");
				saveData();
			}
			else{
				//If the user exists in the cache, load the user in to the userData variable.
				achievements = new Vector.<AchievementVO>;
				for(var i:int = 0; i < achievementData.data.achievements.length; i++){
					achievements.push(new AchievementVO(
						achievementData.data.achievements[i].ID,
						achievementData.data.achievements[i].progress,
						achievementData.data.achievements[i].reward,
						achievementData.data.achievements[i].credits,
						achievementData.data.achievements[i].secret));
					AchievementConstants["ach_"+i+1] = (achievementData.data.achievements[i].progress == 100);
				}
			}
			userAchievements = achievements;
		}
		
		public static function UnlockAchievement(achievementID:int):void{
			for(var i:int = 0; i < INSTANCE.userAchievements.length; i++){
				if(INSTANCE.userAchievements[i].ID == achievementID){
					if(INSTANCE.userAchievements[i].progress < 100 || INSTANCE.userAchievements[i].completed == null){
						LOG.createCheckpoint("ACHIEVEMENT: " + INSTANCE.userAchievements[i].name);
						INSTANCE.updateAchievement(achievementID, 100);
					}
					break;
				}
			}
		}
		
		/**
		 * Get products for user
		 */
		public function getAchievements():void{
			if(DynamicConstants.IS_CONNECTED && FacebookManager.getInstance().checkIfUserIsLoggedIn()|| FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
				GET(new NetResponceHandler(onAchievementsRecevied, onAchievementsFailed), false, UserData.getInstance().userProfile._id);
			}
		}
		
		private function onAchievementsRecevied(e:Object = null):void{
			if(e != null && e.length > 0){
				if(ServerAchievementVO.checkObject(e[0])){
					var serverAchievementVOs:Vector.<ServerAchievementVO> = new Vector.<ServerAchievementVO>;
					for(var i:int = 0; i < e.length; i++){
						serverAchievementVOs.push(new ServerAchievementVO(e[i]));
					}
					for(i = 0; i < serverAchievementVOs.length; i++){
						for(var a:int = 0; a < userAchievements.length; a++){
							if(userAchievements[a].ID == serverAchievementVOs[i].achievementID){
								userAchievements[a].credits = serverAchievementVOs[i].credits;
								userAchievements[a].progress = serverAchievementVOs[i].progress;
								userAchievements[a].reward = serverAchievementVOs[i].reward;
								userAchievements[a].credits = serverAchievementVOs[i].credits;
								if(serverAchievementVOs[i].completed != null){
									AchievementConstants["ach_"+i+1] = true;
									userAchievements[a].completed = serverAchievementVOs[i].completed;		
								}
								userAchievements[a].lastUpdated = serverAchievementVOs[i].updated;
								break;
							}
						}
					}
					saveData();
					achievementUpdateSignal.dispatch();
				}
				else{
					LOG.error("What was returned from the server is not an Achievements Object");
				}
			}
			else{
				achievementUpdateSignal.dispatch();
			}
		}
		private function onAchievementsFailed(e:Object = null):void{
			LOG.error("There was an error downloading the achievements for the specified user");
		}
		
		/**
		 * Parse the achievementID and the TOTAL progress to update the achievement.
		 */
		public function updateAchievement(achievementID:int, progress:int):void{
			if(DynamicConstants.IS_CONNECTED && FacebookManager.getInstance().checkIfUserIsLoggedIn()|| FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
				var obj:Object = new Object();
				obj.userID = UserData.getInstance().userProfile._id;
				obj.progress = progress;
				obj.achievementID = achievementID;
				POST(new NetResponceHandler(onAchievementUpdated, onAchievementUpdateFailed), "", obj);				
			}
		}
		
		private function onAchievementUpdated(e:Object = null):void{
			if(e != null && ServerAchievementVO.checkObject(e)){
				var serverAchievementVO:ServerAchievementVO = new ServerAchievementVO(e);
				for(var i:int = 0; i < userAchievements.length; i++){
					if(serverAchievementVO.achievementID == userAchievements[i].ID){
						userAchievements[i].credits = serverAchievementVO.credits;
						if(userAchievements[i].progress != serverAchievementVO.progress){
							GameCenterManager.getInstance().reportAchievement(AchievementConstants.getAppleAchievementID(serverAchievementVO.achievementID), serverAchievementVO.progress);
							if(serverAchievementVO.progress == 100){
								AchievementConstants["ach_"+i+1] = true;
								achievememtUnlockedSignal.dispatch(serverAchievementVO.achievementID);
								LOG.server("New Achievement Unlocked: " + userAchievements[i].name);
								updateFacebookAchievements(i+1);
							}
						}
						userAchievements[i].progress = serverAchievementVO.progress;
						userAchievements[i].reward = serverAchievementVO.reward;
						userAchievements[i].credits = serverAchievementVO.credits;
						if(serverAchievementVO.completed != null){
							userAchievements[i].completed = serverAchievementVO.completed;		
						}
						userAchievements[i].lastUpdated = serverAchievementVO.updated;
						break;
					}
				}
			}
			else{
				if(e){
					LOG.error("What was returned from the server is not an Achievements Object");
				}
				else{
					LOG.warning("The data returned from the server was invalid.");
				}
			}
			achievementUpdateSignal.dispatch();
		}
		private function onAchievementUpdateFailed(e:Object = null):void{
			LOG.error("There was a problem when trying to update the user achievement");
		}
		
		private function updateFacebookAchievements(facebookAchievementID:int):void{
			if(FacebookManager.getInstance().checkIfUserIsLoggedIn()){
				GoViral.goViral.facebookGraphRequest("me/achievements", "POST", {achievement:"http://audiobrush.com/achievements/achievement_"+facebookAchievementID+".html"});
			}
		}
		
		public function syncGamecenterAchievements():void{
			if(userAchievements != null && userAchievements.length > 0){
				if(achievementData.data.synced == null){
					for(var i:int = 0; i < userAchievements.length; i++){
						GameCenterManager.getInstance().reportAchievement(AchievementConstants.getAppleAchievementID(userAchievements[i].ID), userAchievements[i].progress);	
					}
					achievementData.data.synced = true;
					saveData();
				}
			}
		}
		
		private function saveData():void{
			achievementData.data.achievements = userAchievements;
			achievementData.flush();
		}
		
		public static function getInstance():AchievementData{
			if(INSTANCE == null){
				INSTANCE = new AchievementData();
			}
			return INSTANCE;
		}
	}
}