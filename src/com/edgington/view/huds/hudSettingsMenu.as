package com.edgington.view.huds
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.types.DeviceTypes;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_mainButton;
	import com.edgington.view.huds.elements.element_mainMiniButton;
	
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class hudSettingsMenu extends AbstractHud implements IAbstractHud
	{
		
		private var readyToRemoveSignal:Signal;
		
		private var playButton:element_mainButton;
		private var howToPlay:element_mainButton;
		private var profileButton:element_mainButton;
		private var themesButton:element_mainButton;
		
		private var creditsButton:element_mainMiniButton;
		private var redeemCodeButton:element_mainMiniButton;
		private var facebookLogoutButton:element_mainMiniButton;
		
		private var buttonOptions:Vector.<String> = new <String>["NAVIGATE_MAIN_MENU", "HAND_DIRECTION", "THEMES", "HOWTOPLAY", "REDEEM", "CREDITS", "LOGOUT"];
		
		public function hudSettingsMenu(removeSignal:Signal)
		{
			super();
			
			readyToRemoveSignal = removeSignal;
			
			addListeners();
			
			setupVisuals();
			
			addElements();
		}
		
		public function addListeners():void{
			LOG.createCheckpoint("MENU: Settings");
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			superRemoveSignal.addOnce(readyForRemoval);
		}
		
		public function setupVisuals():void{
			playButton = new element_mainButton(gettext("settings_menu_canvas"), buttonOptions[1]);
			playButton.x = DynamicConstants.SCREEN_MARGIN;
			playButton.y = DynamicConstants.SCREEN_MARGIN;
			
			themesButton = new element_mainButton(gettext("settings_menu_palettes"), buttonOptions[2]);
			themesButton.x = playButton.x;
			themesButton.y = playButton.y + playButton.height + DynamicConstants.BUTTON_SPACING;
			
			howToPlay = new element_mainButton(gettext("settings_menu_howtoplay"), buttonOptions[3]);
			howToPlay.x = playButton.x;
			howToPlay.y = themesButton.y + themesButton.height + DynamicConstants.BUTTON_SPACING;
			
			profileButton = new element_mainButton(gettext("settings_menu_back"), buttonOptions[0]);
			profileButton.x = playButton.x
			profileButton.y = howToPlay.y + howToPlay.height + DynamicConstants.BUTTON_SPACING;
			
			redeemCodeButton = new element_mainMiniButton(gettext("settings_menu_redeem"), buttonOptions[4]);
			redeemCodeButton.x = DynamicConstants.SCREEN_WIDTH - DynamicConstants.SCREEN_MARGIN - redeemCodeButton.width;
			redeemCodeButton.y = playButton.y;
			
			creditsButton = new element_mainMiniButton(gettext("settings_menu_credits"), buttonOptions[5]);
			creditsButton.x = DynamicConstants.SCREEN_WIDTH - DynamicConstants.SCREEN_MARGIN - creditsButton.width;
			creditsButton.y = playButton.y;//redeemCodeButton.y + redeemCodeButton.height + DynamicConstants.BUTTON_SPACING;
			
			facebookLogoutButton = new element_mainMiniButton(gettext("settings_facebook_logout"), buttonOptions[6]);
			facebookLogoutButton.x = DynamicConstants.SCREEN_WIDTH - DynamicConstants.SCREEN_MARGIN - facebookLogoutButton.width;
			facebookLogoutButton.y = creditsButton.y + creditsButton.height + DynamicConstants.BUTTON_SPACING;
			
			if(DeviceTypes.IPHONE == DynamicConstants.DEVICE_TYPE){
				creditsButton.x = DynamicConstants.SCREEN_WIDTH - DynamicConstants.SCREEN_MARGIN - creditsButton.width;
				creditsButton.y = DynamicConstants.SCREEN_HEIGHT - DynamicConstants.SCREEN_MARGIN - creditsButton.height;
				
				facebookLogoutButton.x = DynamicConstants.SCREEN_WIDTH - DynamicConstants.SCREEN_MARGIN - facebookLogoutButton.width;
				facebookLogoutButton.y = creditsButton.y - facebookLogoutButton.height - DynamicConstants.BUTTON_SPACING;
				
				//redeemCodeButton.x = DynamicConstants.SCREEN_WIDTH - DynamicConstants.SCREEN_MARGIN - redeemCodeButton.width;
				//redeemCodeButton.y = creditsButton.y - redeemCodeButton.height - DynamicConstants.BUTTON_SPACING;
			}
			
			addButton(playButton);
			addButton(profileButton);
			addButton(themesButton);
			addButton(howToPlay);
			addButton(redeemCodeButton);
			addButton(facebookLogoutButton);
			addButton(creditsButton);
			
			buttonSignal.add(handleInteraction);
			
			onScreenElements.push(playButton, themesButton, profileButton, howToPlay, creditsButton, facebookLogoutButton);
		}
		
		private function handleInteraction(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_MAIN;
					cleanButtons();
					break;
				case buttonOptions[1]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.SETTINGS_HAND_SELECTION;
					cleanButtons();
					break;
				case buttonOptions[2]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.PROFILE_THEME_SELECTION;
					cleanButtons();
					break;
				case buttonOptions[3]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.TUTORIAL_BEGIN;
					cleanButtons();
					break;
				case buttonOptions[4]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_REDEEM;
					cleanButtons();
					break;
				case buttonOptions[5]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_CREDITS;
					cleanButtons();
					break;
				case buttonOptions[6]:
					FacebookManager.getInstance().logout();
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MESSAGE_FACEBOOK_LOGIN;
					cleanButtons();
					break;
			}
		}
		
		public function readyForRemoval():void{
			super.destroy();
			readyToRemoveSignal.dispatch();
		}
		
		private function destroy(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
		}
	}
}

