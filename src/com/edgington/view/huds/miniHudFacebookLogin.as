package com.edgington.view.huds
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.SettingsProxy;
	import com.edgington.model.events.FacebookEvent;
	import com.edgington.model.facebook.FacebookCheckLogin;
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.model.facebook.FacebookProfileVO;
	import com.edgington.net.AchievementData;
	import com.edgington.net.GiftData;
	import com.edgington.net.ProductsData;
	import com.edgington.net.UserData;
	import com.edgington.types.DeviceTypes;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_mainButton;
	import com.edgington.view.huds.elements.element_mainMessage;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class miniHudFacebookLogin extends AbstractHud implements IAbstractHud
	{
		
		private var readyToRemoveSignal:Signal;
		
		private var loginMessage:element_mainMessage;
		
		private var connectButton:element_mainButton;
		private var noThanksButton:element_mainButton;
		
		private var dismissButton:element_mainButton;
		
		private var buttonOptions:Vector.<String> = new <String>["FACEBOOK_CONNECT", "LOGIN_AS_GUEST", "ERROR_DISMISS"];
		
		private var facebookStartupCheck:FacebookCheckLogin;
		private var facebookStartupSignal:Signal;
		
		public function miniHudFacebookLogin(removeSignal:Signal)
		{
			super();
			
			readyToRemoveSignal = removeSignal;
			
			addListeners();
			
			setupVisuals();
			
			addElements();
		}
		
		public function addListeners():void{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			superRemoveSignal.addOnce(readyForRemoval);
			facebookStartupSignal = new Signal();
			facebookStartupSignal.add(loginCheckComplete);
		}
		
		public function setupVisuals():void{
			
			loginMessage = new element_mainMessage(gettext("facebook_auto_sign_in"), true);
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
				loginMessage.x = DynamicConstants.SCREEN_WIDTH*.5 - loginMessage.width*.5;
				loginMessage.y = DynamicConstants.SCREEN_MARGIN;
			}
			else{
				loginMessage.x = DynamicConstants.SCREEN_WIDTH*.5 - loginMessage.width*.5;
				loginMessage.y = DynamicConstants.SCREEN_HEIGHT*.5 - loginMessage.height*.5;	
			}
			
			
			facebookStartupCheck = new FacebookCheckLogin(facebookStartupSignal);
			
			onScreenElements.push(loginMessage);
		}
		
		private function loginCheckComplete(facebookEventType:String, errorMessage:String = null):void{
			switch(facebookEventType){
				case FacebookEvent.FACEBOOK_LOGGED_IN:
					UserData.getInstance().userDataSignal.add(userInformationDownloaded);
					UserData.getInstance().getUser();
					break;
				case FacebookEvent.FACEBOOK_REQUIRES_LOGIN:
					loginMessage.changeMessage(gettext("facebook_sign_in_message"), false);
					loadCompleteAddButtons();
					break;
				case FacebookEvent.FACEBOOK_LOGIN_FAILED:
					loginMessage.changeMessage(errorMessage);
					addDismissButton();
					break;
				case FacebookEvent.FACEBOOK_NO_FACEBOOK:
					userInformationDownloaded();
					break;
			}
		}
		
		private function addDismissButton():void{
			
			cleanMessageButtons();
			
			dismissButton = new element_mainButton(gettext("facebook_ok_button"), buttonOptions[2]);
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
				dismissButton.x = loginMessage.x;
				dismissButton.y = loginMessage.y + loginMessage.height + DynamicConstants.BUTTON_SPACING;
			}
			else{
				dismissButton.x = loginMessage.x + loginMessage.width - dismissButton.width;
				dismissButton.y = loginMessage.y + loginMessage.height + DynamicConstants.BUTTON_SPACING;
			}
			
			addButton(dismissButton);
			
			buttonSignal.add(handleInteraction);
			
			addAdditionalElements(new <Sprite>[dismissButton]);
		}
		
		private function loadCompleteAddButtons():void{
			
			cleanMessageButtons();
			
			connectButton = new element_mainButton(gettext("facebook_connect_button"), buttonOptions[0]);
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
				connectButton.x = loginMessage.x
				connectButton.y = loginMessage.y + loginMessage.height + DynamicConstants.BUTTON_SPACING;
			}
			else{
				connectButton.x = loginMessage.x + loginMessage.width - connectButton.width;
				connectButton.y = loginMessage.y + loginMessage.height + DynamicConstants.BUTTON_SPACING;
			}
			
//			noThanksButton = new element_mainButton("Skip (unstable)", buttonOptions[1]);
//			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
//				noThanksButton.x = loginMessage.x;
//				noThanksButton.y = connectButton.y + connectButton.height + DynamicConstants.BUTTON_SPACING;
//			}
//			else{
//				noThanksButton.x = loginMessage.x;
//				noThanksButton.y = loginMessage.y + loginMessage.height + DynamicConstants.BUTTON_SPACING;
//			}
			
			
			addButton(connectButton);
			//addButton(noThanksButton);
			
			buttonSignal.add(handleInteraction);
			
			addAdditionalElements(new <Sprite>[connectButton]);
		}
		
		private function handleInteraction(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
					LOG.createCheckpoint("Facebook Logged In");
					loginMessage.changeMessage(gettext("facebook_connecting"), true);
					cleanButtons(false);
					facebookStartupCheck.loginToFacebook();
					break;
				case buttonOptions[1]:
					LOG.createCheckpoint("No Facebook Used");
					var fbProfile:FacebookProfileVO = new FacebookProfileVO();
					fbProfile.name = "Guest";
					fbProfile.id = null;
					fbProfile.gender = "male";
					fbProfile.installed = true;
					FacebookManager.getInstance().currentLoggedInUser = fbProfile;
					if(SettingsProxy.getInstance().handSelection == null){
						DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.SETTINGS_HAND_SELECTION;
					}
					else{
						DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_MAIN;
					}
					cleanButtons();
					break;
				case buttonOptions[2]:
					loginCheckComplete(FacebookEvent.FACEBOOK_REQUIRES_LOGIN);
					break;
			}
		}
		
		private function userInformationDownloaded():void{
			UserData.getInstance().userDataSignal.remove(userInformationDownloaded);
			GiftData.getInstance().getGifts();
			ProductsData.getInstance().getProducts();
			AchievementData.getInstance().getAchievements();
			if(SettingsProxy.getInstance().handSelection == null){
				DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.SETTINGS_HAND_SELECTION;
			}
			else{
				DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_MAIN;
			}
			removeElements();
		}
		
		/**
		 * Removes all the buttons currently active in this hud
		 */
		private function cleanMessageButtons():void{
			buttonSignal.removeAll();
			if(connectButton != null){
				removeButton(connectButton);
				connectButton = null;
			}
			if(noThanksButton != null){
				removeButton(noThanksButton);
				noThanksButton = null;
			}
			if(dismissButton != null){
				removeButton(dismissButton);
				dismissButton = null;
			}
		}
		
		public function readyForRemoval():void{
			super.destroy();
			readyToRemoveSignal.dispatch();
		}
		
		private function destroy(e:Event):void{
			
			facebookStartupCheck = null;
			facebookStartupSignal.removeAll();
			facebookStartupSignal = null;
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
		}
	}
}