package com.edgington.net
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.FacebookConstants;
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.net.helpers.NetResponceHandler;
	import com.edgington.types.ThemeTypes;
	import com.edgington.util.debug.LOG;
	import com.edgington.valueobjects.net.ServerUserVO;
	
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.net.SharedObject;
	import flash.net.URLVariables;
	
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
		private var userProfile:ServerUserVO;
		
		public var unlimited:Boolean = false;
		
		public function UserData()
		{
			super("user", "users");
			LOG.create(this);
			
			var serverUserVO:ServerUserVO;
			if(userData.data.profile == null){
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
		}
		
		
		public function purchaseTheme(themeID:String):void{
			if(!ProductsData.getInstance().doesUserHaveProduct(themeID)){
				useCredits(ThemeTypes[themeID.toUpperCase()+"_THEME_COST"]);
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
			if(DynamicConstants.IS_CONNECTED && FacebookManager.getInstance().checkIfUserIsLoggedIn() || FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
				if(FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
					GET(new NetResponceHandler(onUserDataRecevied, onUserDataFailed), false, FacebookConstants.DEBUG_USER_ID);
				}
				else{
					GET(new NetResponceHandler(onUserDataRecevied, onUserDataFailed), false, FacebookManager.getInstance().currentLoggedInUser.profileID);
				}
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
			if(e && e.length > 0){
				userProfile = new ServerUserVO(e[0]);
				saveProfile();
				ProductsData.getInstance().getProducts();
				userDataSignal.dispatch();
			}
			else{
				if(FacebookManager.getInstance().checkIfUserIsLoggedIn() || FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
					LOG.info("User doesn't exist - creating new user now");
					
					var urlVariables:Object = new Object();
					
					if(FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
						
						urlVariables.fb_id = FacebookConstants.DEBUG_USER_ID;
						urlVariables.username = FacebookConstants.DEBUG_USER_NAME;
						
						PUT(new NetResponceHandler(onNewUserCreated, onNewUserCreatedFailed), FacebookConstants.DEBUG_USER_ID, urlVariables);
					}
					else{
						
						urlVariables.fb_id = FacebookManager.getInstance().currentLoggedInUser.profileID;
						urlVariables.username = FacebookManager.getInstance().currentLoggedInUser.firstName;
						
						PUT(new NetResponceHandler(onNewUserCreated, onNewUserCreatedFailed), FacebookManager.getInstance().currentLoggedInUser.profileID, urlVariables);
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
		 * When the server response as successful after creating a new user
		 */
		private function onNewUserCreated(e:Object = null):void{
			if(e && DynamicConstants.IS_CONNECTED && FacebookManager.getInstance().checkIfUserIsLoggedIn() || FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
				if(FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
					GET(new NetResponceHandler(onUserDataRecevied, onUserDataFailed), false, FacebookConstants.DEBUG_USER_ID);
				}
				else{
					GET(new NetResponceHandler(onUserDataRecevied, onUserDataFailed), false, FacebookManager.getInstance().currentLoggedInUser.profileID);
				}
			}
			else{
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
		 * Update the credits
		 */
		public function addCredits(creditsAmount:int):void{
			userProfile.credits += creditsAmount;
			saveProfile();
			if(DynamicConstants.IS_CONNECTED && FacebookManager.getInstance().checkIfUserIsLoggedIn() || FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
				POST(new NetResponceHandler(onCreditsUpdated, onCreditsUpdateFailed), userProfile.fb_id, JSON.parse(JSON.stringify(userProfile)));
			}
		}
		public function useCredits(creditsAmount:int):void{
			userProfile.credits -= creditsAmount;
			saveProfile();
			if(DynamicConstants.IS_CONNECTED && FacebookManager.getInstance().checkIfUserIsLoggedIn() || FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
				POST(new NetResponceHandler(onCreditsUpdated, onCreditsUpdateFailed), userProfile.fb_id, JSON.parse(JSON.stringify(userProfile)));
			}
		}
		
		private function onCreditsUpdated(e:Object = null):void{
			if(e && e.length > 0){
				userProfile = new ServerUserVO(e[0]);
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
				POST(new NetResponceHandler(onUnlimitedEditSuccess, onUnlimitedEditFailed), userProfile.fb_id, JSON.parse(JSON.stringify(userProfile)));
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