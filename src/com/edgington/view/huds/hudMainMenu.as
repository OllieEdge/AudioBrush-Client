package com.edgington.view.huds
{
	import com.edgington.constants.Constants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.net.TournamentData;
	import com.edgington.net.UserData;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.debug.LOG;
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
		private var profileButton:element_mainButton;
		
		private var feedbackButton:element_mainButton;
		
		private var inboxButton:element_mainMiniButton;
		
		private var ipadProfileInfo:element_mainMenuProfileiPad;
		private var iphoneProfileInfo:element_mainMenuProfileIphone;
		
		private var bonus:element_bonus;
		
		private var buttonOptions:Vector.<String> = new <String>["NAVIGATE_NEW_GAME", "TOURNAMENT", "LEADERBOARDS", "BETA_FEEDBACK", "PROFILE", "INBOX"];
		
		public function hudMainMenu(removeSignal:Signal)
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
		}
		
		public function setupVisuals():void{
			playButton = new element_mainButton("Play", buttonOptions[0]);
			playButton.x = DynamicConstants.SCREEN_MARGIN;
			playButton.y = element_user_hud.HEIGHT + DynamicConstants.BUTTON_SPACING;
			
			howToPlayButton = new element_mainButton("Tournament", buttonOptions[1]);
			howToPlayButton.x = playButton.x
			howToPlayButton.y = playButton.y + playButton.height + DynamicConstants.BUTTON_SPACING;
			
			settingsButton = new element_mainButton("Leaderboards", buttonOptions[2]);
			settingsButton.x = playButton.x
			settingsButton.y = howToPlayButton.y + howToPlayButton.height + DynamicConstants.BUTTON_SPACING;
			
			profileButton = new element_mainButton("Achievements", buttonOptions[4]);
			profileButton.x = playButton.x
			profileButton.y = settingsButton.y + settingsButton.height + DynamicConstants.BUTTON_SPACING;
			
//			feedbackButton = new element_mainButton("Achievements", buttonOptions[3]);
//			feedbackButton.x = playButton.x;
//			feedbackButton.y = profileButton.y + profileButton.height + DynamicConstants.BUTTON_SPACING;
//			
//			inboxButton = new element_mainMiniButton("Messages", buttonOptions[5]);
//			inboxButton.x = playButton.x;
//			inboxButton.y = feedbackButton.y + feedbackButton.height  + DynamicConstants.BUTTON_SPACING;
			
//			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPAD){
//				ipadProfileInfo = new element_mainMenuProfileiPad();
//				ipadProfileInfo.x = DynamicConstants.SCREEN_WIDTH - ipadProfileInfo.width - DynamicConstants.SCREEN_MARGIN;
//				ipadProfileInfo.y = DynamicConstants.SCREEN_MARGIN;
//				ipadProfileInfo.addEventListener(MouseEvent.MOUSE_UP, purchasesClicked);
//			}
//			else{
//				iphoneProfileInfo = new element_mainMenuProfileIphone();
//				iphoneProfileInfo.scaleX = iphoneProfileInfo.scaleY = DynamicConstants.MESSAGE_SCALE;
//				iphoneProfileInfo.x = DynamicConstants.SCREEN_WIDTH - iphoneProfileInfo.width - DynamicConstants.SCREEN_MARGIN;
//				iphoneProfileInfo.y = DynamicConstants.SCREEN_MARGIN;
//				iphoneProfileInfo.addEventListener(MouseEvent.MOUSE_UP, purchasesClicked);
//			}
			
			bonus = new element_bonus();
			
			addButton(playButton);
			addButton(howToPlayButton);
			addButton(settingsButton);
			//addButton(profileButton);
			//addButton(feedbackButton);
			//addButton(inboxButton);
			
			buttonSignal.add(handleInteraction);
			
			onScreenElements.push(playButton, howToPlayButton, settingsButton, bonus);
//			if(ipadProfileInfo){
//				onScreenElements.push(ipadProfileInfo);
//			}
//			else if(iphoneProfileInfo){
//				onScreenElements.push(iphoneProfileInfo);
//			}
		}
		
		private function handleInteraction(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
					if(UserData.getInstance().getCredits() < Constants.TRACK_PLAY_COST && !UserData.getInstance().unlimited){
						DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.PURCHASES;
					}
					else{
						TournamentData.getInstance().isThisGameATournamentGame = false;
						DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.GAME_LOADING;
					}
					cleanButtons();
					break;
				case buttonOptions[1]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.TOURNAMENT_ENTRY;
					cleanButtons();
					break;
				case buttonOptions[2]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.HIGHSCORES_MAIN;
					//navigateToURL(new URLRequest("https://trello.com/board/audiobrush-development/517dc37959cfd16d03001813"));
					cleanButtons();
					break;
				case buttonOptions[3]:
					LOG.provideFeedback();
					cleanButtons();
					break;
				case buttonOptions[4]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_ACHIEVEMENTS;
					cleanButtons();
					break;
				case buttonOptions[5]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_INBOX;
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