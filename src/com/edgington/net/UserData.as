package com.edgington.net
{
	import com.edgington.constants.AchievementConstants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.FacebookConstants;
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.net.helpers.NetResponceHandler;
	import com.edgington.util.ObjectLength;
	import com.edgington.util.PushNotificationsManager;
	import com.edgington.util.debug.LOG;
	import com.edgington.valueobjects.net.ServerUserVO;
	
	import flash.net.Responder;
	import flash.net.SharedObject;
	import flash.system.Capabilities;
	
	import org.osflash.signals.Signal;

	public class UserData extends BaseData
	{
		private static var INSTANCE:UserData;
		
		private const CALL_GET_USER:String = "user.UserManager.getUser";
		private const CALL_CREATE_USER:String = "user.UserManager.createUser";
		private const CALL_UPDATE_USER_CREDITS:String = "user.UserManager.updateCredits";
		private const CALL_UPDATE_UNLIMITED:String = "user.UserManager.unlimitedPurchased";
		
		private var userData:SharedObject = SharedObject.getLocal("ab_userData");
		
		private var userDataResponder:Responder;
		
		public var userDataSignal:Signal;
		
		//Actual live user data;
		public var userProfile:ServerUserVO;
		
		public var unlimited:Boolean = false;
		
		public var isLogin:Boolean = true;
		
		public var bonusSignal:Signal;
		public var bonusTime:Number = 0;
		
		//This is a complicated boolean, make sure it's tru ewhen the user data has downloaded properly.
		private var newUserBeingCreated:Boolean = false;
		public var firstPlay:Boolean = false;
		
		public function UserData()
		{
			super("user", "users");
			LOG.create(this);
			
			var serverUserVO:ServerUserVO;
			if(userData.data.profile == null){
				firstPlay = true;
				userData.data.profile = new ServerUserVO();
				serverUserVO = userData.data.profile;
				LOG.info("Created a new user");
				saveData();
			}
			else{
				//If the user exists in the cache, load the user in to the userData variable.
				serverUserVO = new ServerUserVO(JSON.parse(JSON.stringify(userData.data.profile)));
				LOG.info("Previous User - FacebookID: " + serverUserVO.fb_id + " Username: " + serverUserVO.username);
			}
			userProfile = serverUserVO;
		
			userDataSignal = new Signal();
			bonusSignal = new Signal();
		}
		
		
		public function purchaseTheme(themeID:String):void{
			if(!ProductsData.getInstance().doesUserHaveProduct(themeID)){
				//Artist at Heart
				if(!AchievementConstants.ach_21){
					AchievementData.UnlockAchievement(21);
				}
				//useCredits(ThemeTypes[themeID.toUpperCase()+"_THEME_COST"]);
				ProductsData.getInstance().createNewPurchase(themeID, 1);
			}
		}
		
		public function getCredits():int{
			return userProfile.credits;
		}
		
		/**
		 * Ask's the server for the current user information
		 */
		public function getUser():void{
			if(DynamicConstants.IS_CONNECTED && FacebookManager.getInstance().checkIfUserIsLoggedIn()){
				var obj:Object = new Object();
				obj.isLogin = isLogin;
				POST(new NetResponceHandler(onUserDataRecevied, onUserDataFailed), FacebookManager.getInstance().currentLoggedInUser.id, obj);
			}
			else{
				userDataSignal.dispatch();
			}
		}
		
		/**
		 * When the responce from the server containing user data is received
		 * 
		 * If the responce doesn't contain data we need to create the user
		 */
		private function onUserDataRecevied(e:Object = null):void{
			if(e && ObjectLength.count(e) > 0 && ServerUserVO.checkObject(e)){
				userProfile = new ServerUserVO(e);
				
				if(userProfile.last_login != null){
					if(newUserBeingCreated && !firstPlay){
						firstPlay = true;
						newUserBeingCreated = false;
					}
					else if(!newUserBeingCreated && firstPlay){
						firstPlay = false;
					}
					isLogin = false;
					var clientDate:Date = new Date();
					DynamicConstants.SERVER_TIME_DIFFERENCE = userProfile.last_login.time - clientDate.time;
					LOG.server("Server time is " + (DynamicConstants.SERVER_TIME_DIFFERENCE/1000) + " seconds ahead");
				}
				
				
				//If we need to update the user
				if(DynamicConstants.isIOSPlatform()){
					if(userProfile.username != FacebookManager.getInstance().currentLoggedInUser.rawFacebookData.name || userProfile.airship_token != PushNotificationsManager.getInstance().airshipToken){
						if(userProfile.username != FacebookManager.getInstance().currentLoggedInUser.rawFacebookData.name){
							userProfile.username = FacebookManager.getInstance().currentLoggedInUser.rawFacebookData.name
						}
						if(userProfile.airship_token != PushNotificationsManager.getInstance().airshipToken && PushNotificationsManager.getInstance().pushNotificationsEnabled){
							userProfile.airship_token = PushNotificationsManager.getInstance().airshipToken;
						}
						updateProfile("", "", true);
					}
					if(FacebookManager.getInstance().checkIfUserIsLoggedIn()){
						PushNotificationsManager.setUserTag(Capabilities.languages[0]);
						PushNotificationsManager.setUserTag("facebook");
						PushNotificationsManager.updateUserAlias(FacebookManager.getInstance().currentLoggedInUser.name);
					}
				}
				
				ProductsData.getInstance().getProducts();
				//Save
				saveProfile();
				checkAchievements();
				userDataSignal.dispatch();
			}
			else{
				if(FacebookManager.getInstance().checkIfUserIsLoggedIn() || FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
					LOG.info("User doesn't exist - creating new user now");
					newUserBeingCreated = true;
					var urlVariables:Object = new Object();
					
					if(FacebookConstants.DEBUG_FACEBOOK_ALLOWED){

						urlVariables.fb_id = FacebookConstants.DEBUG_USER_ID;
						urlVariables.username = FacebookConstants.DEBUG_USER_NAME;

						PUT(new NetResponceHandler(onNewUserCreated, onNewUserCreatedFailed), FacebookConstants.DEBUG_USER_ID, urlVariables);
					}
					else{
						
						urlVariables.fb_id = FacebookManager.getInstance().currentLoggedInUser.id;
						urlVariables.username = FacebookManager.getInstance().currentLoggedInUser.name;
						if(PushNotificationsManager.getInstance().pushNotificationsEnabled){
							urlVariables.airship_token = PushNotificationsManager.getInstance().airshipToken;
						}
						
						PUT(new NetResponceHandler(onNewUserCreated, onNewUserCreatedFailed), FacebookManager.getInstance().currentLoggedInUser.id, urlVariables);
					}
				}
			}
		}
		/**
		 * When the retrieval of the user data fails for some reason
		 */
		private function onUserDataFailed():void{
			LOG.error("Getting the user data failed");
		}
		
		/**
		 * Just a quick check of any user related achievements
		 */
		private function checkAchievements():void{
			//5 tracks
			if(!AchievementConstants.ach_15){
				var ach15Progress:int  = AchievementData.getInstance().userAchievements[14].progress;
				var calculatedProgress15:int = Math.min(100, Math.floor((userProfile.tracks.length / 5)*100));
				if(ach15Progress != calculatedProgress15){
					AchievementData.getInstance().updateAchievement(15, calculatedProgress15);
				}
			}
			//10 tracks
			if(!AchievementConstants.ach_16){
				var ach16Progress:int  = AchievementData.getInstance().userAchievements[15].progress;
				var calculatedProgress16:int = Math.min(100, Math.floor((userProfile.tracks.length / 10)*100));
				if(ach16Progress != calculatedProgress16){
					AchievementData.getInstance().updateAchievement(16, calculatedProgress16);
				}
			}
			//50 shades of track
			if(!AchievementConstants.ach_17){
				var ach17Progress:int  = AchievementData.getInstance().userAchievements[16].progress;
				var calculatedProgress17:int = Math.min(100, Math.floor((userProfile.tracks.length / 50)*100));
				if(ach16Progress != calculatedProgress17){
					AchievementData.getInstance().updateAchievement(17, calculatedProgress17);
				}
			}
		}
		
		/**
		 * When the server response as successful after creating a new user
		 */
		private function onNewUserCreated(e:Object = null):void{
			if(e && DynamicConstants.IS_CONNECTED && FacebookManager.getInstance().checkIfUserIsLoggedIn() || FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
				LOG.server("New user was created, now re-downloading the profile");
				if(FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
					POST(new NetResponceHandler(onUserDataRecevied, onUserDataFailed), FacebookConstants.DEBUG_USER_ID, null);
				}
				else{
					POST(new NetResponceHandler(onUserDataRecevied, onUserDataFailed), FacebookManager.getInstance().currentLoggedInUser.id, null);
				}
			}
			else{
				LOG.server("New user creation FAILED");
				LOG.fatal("Hmm, this is a problem, not sure what to do just yet.");
				userDataSignal.dispatch();
			}
		}
		/**
		 * If the creation of the user fails.
		 */
		private function onNewUserCreatedFailed(e:Object):void{
			LOG.error("Creating the user data failed");
		}
		
		/**
		 * If neither of the values are filled and the override is false, the request will not be sent.
		 * However if neither are filled and override is true, the request will be sent.
		*/
		public function updateProfile(username:String = "", airshipToken:String = "", override:Boolean = false):void{
			if(username != "" && airshipToken != ""){
				override = true;
				if(username != ""){
					userProfile.username = username;
				}
				else if(airshipToken != ""){
					userProfile.airship_token = airshipToken;
				}
			}
			if(override){
				if(DynamicConstants.IS_CONNECTED && FacebookManager.getInstance().checkIfUserIsLoggedIn() || FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
					POST(new NetResponceHandler(onCreditsUpdated, onCreditsUpdateFailed), "update/"+userProfile.fb_id, JSON.parse(JSON.stringify(userProfile)));
				}
			}
		}
		
		/**
		 * Update the credits
		 */
		public function addCredits(creditsAmount:int):void{
			userProfile.credits += creditsAmount;
			saveProfile();
			if(DynamicConstants.IS_CONNECTED && FacebookManager.getInstance().checkIfUserIsLoggedIn() || FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
				POST(new NetResponceHandler(onCreditsUpdated, onCreditsUpdateFailed), "update/"+userProfile.fb_id, JSON.parse(JSON.stringify(userProfile)));
			}
		}
		public function useCredits(creditsAmount:int):void{
			userProfile.credits -= creditsAmount;
			saveProfile();
			if(DynamicConstants.IS_CONNECTED && FacebookManager.getInstance().checkIfUserIsLoggedIn() || FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
				POST(new NetResponceHandler(onCreditsUpdated, onCreditsUpdateFailed), "update/"+userProfile.fb_id, JSON.parse(JSON.stringify(userProfile)));
			}
		}
		
		private function onCreditsUpdated(e:Object = null):void{
			if(e && ServerUserVO.checkObject(e)){
				userProfile = new ServerUserVO(e);
				saveProfile();
				userDataSignal.dispatch();
			}
		}
		private function onCreditsUpdateFailed():void{
			LOG.error("There was a problem updating the users credits");
		}
		
		
		/**
		 * Unlock the unlimited plays feature for this profile
		 */
		public function unlimitedPurchased():void{
			userProfile.unlimited = "true";
			saveProfile();
			unlimited = true;
			if(DynamicConstants.IS_CONNECTED && FacebookManager.getInstance().checkIfUserIsLoggedIn() || FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
				POST(new NetResponceHandler(onUnlimitedEditSuccess, onUnlimitedEditFailed), "update/"+userProfile.fb_id, JSON.parse(JSON.stringify(userProfile)));
			}
		}
		
		/**
		 * Handlers for the unlimited unlock response
		 */
		private function onUnlimitedEditSuccess(e:Object = null):void{
			if(e && e.length > 0){
				userProfile = new ServerUserVO(e[0]);
				saveProfile();
				userDataSignal.dispatch();
			}
		}
		private function onUnlimitedEditFailed():void{
			LOG.error("There was a problem updating the Users Unlimited status");
		}
		
		public function checkBonusStatus():void{
			if(DynamicConstants.IS_CONNECTED && FacebookManager.getInstance().checkIfUserIsLoggedIn() || FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
				GET(new NetResponceHandler(onBonusStatus, onBonusStatusFailed), false, "bonus/"+userProfile.fb_id);
			}
		}
		public function collectBonus():void{
			if(DynamicConstants.IS_CONNECTED && FacebookManager.getInstance().checkIfUserIsLoggedIn() || FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
				POST(new NetResponceHandler(onBonusCollected, onBonusCollectFailed), "bonus/"+userProfile.fb_id, null);
			}
		}
		
		private function onBonusStatus(e:Object = null):void{
			if(e && ServerUserVO.checkObject(e)){
				var serverUser:ServerUserVO = new ServerUserVO(e);
				userProfile.last_bonus = serverUser.last_bonus;
				bonusSignal.dispatch();
			}
			else{
				LOG.error("There was a problem getting the bonus status");
			}
		}
		private function onBonusStatusFailed(e:Object = null):void{
			LOG.error("ERROR There was a problem getting the bonus status");
		}
		
		private function onBonusCollected(e:Object = null):void{
			if(e && ServerUserVO.checkObject(e)){
				var serverUser:ServerUserVO = new ServerUserVO(e);
				userProfile.last_bonus = serverUser.last_bonus;
				userProfile.credits = serverUser.credits;
				saveProfile();
				userDataSignal.dispatch();
				bonusSignal.dispatch();
			}
			else{
				LOG.error("There was a problem getting the bonus status");
			}
		}
		private function onBonusCollectFailed(e:Object = null):void{
			LOG.error("ERROR There was a problem getting the bonus status");
		}
		
		
		private function connectionErrorHandler():void{
			userDataSignal.dispatch();
		}
		
		private function saveProfile():void{
			userData.data.profile = userProfile;
			saveData();
		}
		
		private function saveData():void{
			userData.flush();
		}
		
		public static function getInstance():UserData{
			if(INSTANCE == null){
				INSTANCE = new UserData();
			}
			return INSTANCE;
		}
	}
}