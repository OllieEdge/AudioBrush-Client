package com.edgington.view.huds
{
	import com.edgington.constants.Constants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.SoundConstants;
	import com.edgington.model.SoundManager;
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.net.TournamentData;
	import com.edgington.net.UserData;
	import com.edgington.types.DeviceTypes;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_bonus;
	import com.edgington.view.huds.elements.element_mainButton;
	import com.edgington.view.huds.elements.element_mainMenuProfileIphone;
	import com.edgington.view.huds.elements.element_mainMenuProfileiPad;
	import com.edgington.view.huds.elements.element_mainMiniButton;
	import com.edgington.view.huds.elements.element_user_hud;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.osflash.signals.Signal;

	public class hudMainMenu extends AbstractHud implements IAbstractHud
	{
		
		private var readyToRemoveSignal:Signal;
		
		private var playButton:element_mainButton;
		private var howToPlayButton:element_mainButton;
		private var settingsButton:element_mainButton;
		
		private var profileButton:element_mainMiniButton;
		private var feedbackButton:element_mainMiniButton;
		
		private var inboxButton:element_mainMiniButton;
		
		private var ipadProfileInfo:element_mainMenuProfileiPad;
		private var iphoneProfileInfo:element_mainMenuProfileIphone;
		
		private var bonus:element_bonus;
		
		private var buttonOptions:Vector.<String> = new <String>["NAVIGATE_NEW_GAME", "TOURNAMENT", "LEADERBOARDS", "BETA_FEEDBACK", "PROFILE", "INBOX"];
		
		public function hudMainMenu(removeSignal:Signal)
		{
			super();
			
			FacebookManager.getInstance().requestPostPermissions();
			
			readyToRemoveSignal = removeSignal;
			
			addListeners();
			
			setupVisuals();
			
			addElements();
		}
		
		public function addListeners():void{
			SoundManager.getInstance().loadAndPlaySound(SoundConstants.BGM_MENU, SoundConstants.BGM_MENU_VOLUME);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			superRemoveSignal.addOnce(readyForRemoval);
		}
		
		public function setupVisuals():void{
			playButton = new element_mainButton(gettext("menu_main_button_play"), buttonOptions[0]);
			playButton.x = DynamicConstants.SCREEN_MARGIN;
			playButton.y = element_user_hud.HEIGHT + DynamicConstants.BUTTON_SPACING;
			
			howToPlayButton = new element_mainButton(gettext("menu_main_button_tournaments"), buttonOptions[1]);
			howToPlayButton.x = playButton.x
			howToPlayButton.y = playButton.y + playButton.height + DynamicConstants.BUTTON_SPACING;
			
			settingsButton = new element_mainButton(gettext("menu_main_button_leaderboards"), buttonOptions[2]);
			settingsButton.x = playButton.x
			settingsButton.y = howToPlayButton.y + howToPlayButton.height + DynamicConstants.BUTTON_SPACING;
			
			profileButton = new element_mainMiniButton(gettext("menu_main_button_achievements"), buttonOptions[4]);
			profileButton.x = playButton.x
			profileButton.y = settingsButton.y + settingsButton.height + DynamicConstants.BUTTON_SPACING*2;
			
			feedbackButton = new element_mainMiniButton(gettext("menu_main_button_inbox"), buttonOptions[3]);
			feedbackButton.x = playButton.x;
			feedbackButton.y = profileButton.y + profileButton.height + DynamicConstants.BUTTON_SPACING;
			
			addButton(profileButton);
			addButton(feedbackButton);
			
			if(DeviceTypes.IPHONE == DynamicConstants.DEVICE_TYPE){
				feedbackButton.y = DynamicConstants.SCREEN_HEIGHT - DynamicConstants.SCREEN_MARGIN - feedbackButton.height;
				profileButton.y = feedbackButton.y - DynamicConstants.BUTTON_SPACING - profileButton.height;
				settingsButton.y = profileButton.y - (DynamicConstants.BUTTON_SPACING*2) - settingsButton.height;
				howToPlayButton.y = settingsButton.y - DynamicConstants.BUTTON_SPACING - howToPlayButton.height;
				playButton.y = howToPlayButton.y - DynamicConstants.BUTTON_SPACING - playButton.height;
			}
			
			bonus = new element_bonus();
			
			addButton(playButton);
			addButton(howToPlayButton);
			addButton(settingsButton);
			
			
			buttonSignal.add(handleInteraction);
			
			onScreenElements.push(playButton, howToPlayButton, settingsButton, bonus);
				onScreenElements.push(profileButton, feedbackButton);
		}
		
		private function handleInteraction(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
					if(UserData.getInstance().getCredits() < Constants.TRACK_PLAY_COST && !UserData.getInstance().unlimited){
						DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.PURCHASES;
					}
					else{
						TournamentData.getInstance().isThisGameATournamentGame = false;
						DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.GAME_TRACK_SELECTION;
					}
					cleanButtons();
					break;
				case buttonOptions[1]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.TOURNAMENT_ENTRY;
					cleanButtons();
					break;
				case buttonOptions[2]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.HIGHSCORES_MAIN;
					cleanButtons();
					break;
				case buttonOptions[3]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_INBOX;
					cleanButtons();
					break;
				case buttonOptions[4]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_ACHIEVEMENTS;
					cleanButtons();
					break;
			}
		}
		
		private function purchasesClicked(e:MouseEvent):void{
			e.currentTarget.removeEventListener(MouseEvent.MOUSE_UP, purchasesClicked);
			DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.PURCHASES;
			cleanButtons();
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
			playButton = null;
			howToPlayButton = null;
			settingsButton = null;
			profileButton = null;
			
			feedbackButton = null;
			
			ipadProfileInfo = null;
			iphoneProfileInfo = null;
		}
	}
}