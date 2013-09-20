package com.edgington.view.huds
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.types.DeviceTypes;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_mainButton;
	import com.edgington.view.huds.elements.element_sendItemsScreen;
	import com.edgington.view.huds.elements.element_tabContainer;
	import com.edgington.view.huds.events.TabContainerEvent;
	
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
		
		private var sendItems:element_sendItemsScreen;
		
		private var tabContainer:element_tabContainer;
		
		private var backButton:element_mainButton;
		
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
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			superRemoveSignal.addOnce(readyForRemoval);
			
			tabChangedSignal = new Signal();
			tabChangedSignal.add(handleTabChanged);
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
		}
		
		private function handleInteraction(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_MAIN;
					cleanButtons();
					break;
			}
		}
		
		private function handleTabChanged(eventType:String, tabLabel:String = ""):void{
			switch(eventType){
				case TabContainerEvent.TAB_CHANGED:
					currentTab = tabLabels.indexOf(tabLabel);
					switch(tabLabel)
					{
						case tabLabels[0]:
							if(sendItems != null){
								removeSeperateElements(sendItems);
								sendItems = null;
							}
							break;
						case tabLabels[1]:
							sendItems = new element_sendItemsScreen(tabContainer.width, tabContainer.getTabBodyHeight);
							sendItems.x = tabContainer.x;
							sendItems.y = tabContainer.y + tabContainer.getTabBodyYOrigin;
							addAdditionalElements(new <Sprite>[sendItems]);
							break;
						case tabLabels[2]:
							if(sendItems != null){
								removeSeperateElements(sendItems);
								sendItems = null;
							}
							break;
					}
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
			backButton = null;
			tabContainer = null;
		}
	}
}