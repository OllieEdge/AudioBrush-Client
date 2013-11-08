package com.edgington.view.huds
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.FacebookConstants;
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.net.GiftData;
	import com.edgington.types.DeviceTypes;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_inbox;
	import com.edgington.view.huds.elements.element_mainButton;
	import com.edgington.view.huds.elements.element_sendItemsScreen;
	import com.edgington.view.huds.elements.element_tabContainer;
	import com.edgington.view.huds.events.TabContainerEvent;
	import com.milkmangames.nativeextensions.GoViral;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class hudInboxMenu extends AbstractHud implements IAbstractHud
	{
		
		private var readyToRemoveSignal:Signal;
		
		private var tabDescriptions:Vector.<String>;
		private var tabLabels:Vector.<String>;
		
		private var currentTab:int = 0;
		private var tabChangedSignal:Signal;
		
		private var inboxItems:element_inbox;
		private var sendItems:element_sendItemsScreen;
		
		private var tabContainer:element_tabContainer;
		
		private var backButton:element_mainButton;
		
		private var sendButton:element_mainButton;
		private var sendButtonSignal:Signal;
		
		private var buttonOptions:Vector.<String> = new <String>["NAVIGATE_NEW_GAME", "TOURNAMENT", "LEADERBOARDS", "BETA_FEEDBACK", "PROFILE"];
		
		public function hudInboxMenu(removeSignal:Signal)
		{
			super();
			
			readyToRemoveSignal = removeSignal;
			
			addListeners();
			
			setupVisuals();
			
			addElements();
		}
		
		public function addListeners():void{
			LOG.createCheckpoint("MENU: Inbox");
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			superRemoveSignal.addOnce(readyForRemoval);
			
			tabChangedSignal = new Signal();
			tabChangedSignal.add(handleTabChanged);
			
			sendButtonSignal = new Signal();
			sendButtonSignal.add(sendButtonHandler);
		}
		
		public function setupVisuals():void{
			tabLabels = new Vector.<String>;
			tabDescriptions = new Vector.<String>;
			tabLabels.push(gettext("inbox_tab_inbox"), gettext("inbox_tab_send"), gettext("inbox_tab_invite"));
			tabDescriptions.push(gettext("inbox_tab_description_inbox"), gettext("inbox_tab_description_send"), gettext("inbox_tab_description_invite"));
			
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPAD){
				tabContainer = new element_tabContainer(tabLabels, tabChangedSignal, tabDescriptions, DynamicConstants.SCREEN_HEIGHT*.6);	
			}
			else{
				tabContainer = new element_tabContainer(tabLabels, tabChangedSignal, tabDescriptions, DynamicConstants.SCREEN_HEIGHT*.5);	
			}
			tabContainer.x = DynamicConstants.SCREEN_WIDTH*.5 - tabContainer.width*.5;
			tabContainer.y = DynamicConstants.SCREEN_MARGIN;
			
			backButton = new element_mainButton(gettext("highscores_back_button"), buttonOptions[0]);
			backButton.x = DynamicConstants.SCREEN_MARGIN;
			backButton.y = tabContainer.y + tabContainer.height + DynamicConstants.BUTTON_SPACING;
			
			addButton(backButton);
			
			buttonSignal.add(handleInteraction);
			
			onScreenElements.push(tabContainer, backButton);
			
			handleTabChanged(TabContainerEvent.TAB_CHANGED, tabLabels[currentTab]);
		}
		
		private function handleInteraction(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_MAIN;
					cleanButtons();
					break;
				case buttonOptions[1]:
					var friends:Vector.<String> = new Vector.<String>;
					for(var i:int = 0; i < sendItems.friendsSelectedList.itemList.length; i++){
						friends.push(sendItems.friendsSelectedList.itemList[i].id);
					}
					GiftData.getInstance().giftDataSignal.addOnce(handleGiftsResponse);
					GiftData.getInstance().postGifts(friends, 1);
					sendButtonHandler(false);
					break;
			}
		}
		
		private function handleGiftsResponse():void{
			if(GiftData.getInstance().giftsSent){
				tabContainer.overrideTabSelection(0);
			}
			else{
				sendButtonHandler(true);
			}
		}
		
		private function handleTabChanged(eventType:String, tabLabel:String = ""):void{
			switch(eventType){
				case TabContainerEvent.TAB_CHANGED:
					currentTab = tabLabels.indexOf(tabLabel);
					switch(tabLabel)
					{
						case tabLabels[0]:
							LOG.createCheckpoint("MENU: Inbox");
							if(sendItems != null){
								removeSeperateElements(sendItems);
								sendItems = null;
								sendButtonHandler(false);
							}
							if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
								inboxItems = new element_inbox(tabContainer.tabDescription.width, tabContainer.getTabBodyHeight, 4);	
							}
							else{
								inboxItems = new element_inbox(tabContainer.tabDescription.width, tabContainer.getTabBodyHeight, 8);	
							}
							inboxItems.x = tabContainer.x + tabContainer.tabDescription.x;
							inboxItems.y = tabContainer.y + tabContainer.getTabBodyYOrigin;
							addAdditionalElements(new <Sprite>[inboxItems]);
							break;
						case tabLabels[1]:
							LOG.createCheckpoint("MENU: Send Gifts");
							if(inboxItems != null){
								inboxItems.readyForRemoval();
								removeSeperateElements(inboxItems);
								inboxItems = null;
							}
							sendItems = new element_sendItemsScreen(tabContainer.width, tabContainer.getTabBodyHeight, sendButtonSignal);
							sendItems.x = tabContainer.x;
							sendItems.y = tabContainer.y + tabContainer.getTabBodyYOrigin;
							
							addAdditionalElements(new <Sprite>[sendItems]);
							break;
						case tabLabels[2]:
							if(inboxItems != null){
								inboxItems.readyForRemoval();
								removeSeperateElements(inboxItems);
								inboxItems = null;
							}
							if(sendItems != null){
								removeSeperateElements(sendItems);
								sendItems = null;
								sendButtonHandler(false);
							}
							
							if(FacebookManager.getInstance().checkIfUserIsLoggedIn()){
								LOG.createCheckpoint("MENU: Invite Friends");
								GoViral.goViral.showFacebookRequestDialog(gettext("facebook_invite_friends_message"), gettext("facebook_invite_friends_dialog_title"));
							}
							
							break;
					}
				break;
			}
		}
		
		private function sendButtonHandler(showSendButton:Boolean):void{
			if(showSendButton && sendButton == null){
				sendButton = new element_mainButton(gettext("send_freinds_button_send"), buttonOptions[1]);
				sendButton.x = tabContainer.x + tabContainer.width - sendButton.width;
				sendButton.y = tabContainer.y + tabContainer.height + DynamicConstants.BUTTON_SPACING;
				addButton(sendButton);
				addAdditionalElements(new <Sprite>[sendButton]);
			}
			else{
				if(sendButton != null){
					removeButton(sendButton);
					removeSeperateElements(sendButton);
					sendButton = null;
				}
			}
		}
		
		public function readyForRemoval():void{
			super.destroy();
			readyToRemoveSignal.dispatch();
		}
		
		private function destroy(e:Event):void{
			tabChangedSignal.removeAll();
			sendButtonSignal.removeAll();
			tabChangedSignal = null;
			sendButtonSignal = null;
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			backButton = null;
			tabContainer = null;
			sendButton = null;
			inboxItems = null;
			sendItems = null;
		}
	}
}