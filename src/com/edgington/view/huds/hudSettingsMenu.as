package com.edgington.view.huds
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.debug.LOG;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_mainButton;
	
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class hudSettingsMenu extends AbstractHud implements IAbstractHud
	{
		
		private var readyToRemoveSignal:Signal;
		
		private var playButton:element_mainButton;
		private var settingsButton:element_mainButton;
		private var profileButton:element_mainButton;
		private var themesButton:element_mainButton;
		
		private var buttonOptions:Vector.<String> = new <String>["NAVIGATE_MAIN_MENU", "HAND_DIRECTION", "THEMES"];
		
		public function hudSettingsMenu(removeSignal:Signal)
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
			playButton = new element_mainButton("Canvas Direction", buttonOptions[1]);
			playButton.x = 100;
			playButton.y = 100;
			
			themesButton = new element_mainButton("Themes", buttonOptions[2]);
			themesButton.x = playButton.x;
			themesButton.y = playButton.y + playButton.height + DynamicConstants.BUTTON_SPACING;
			
			profileButton = new element_mainButton("Back", buttonOptions[0]);
			profileButton.x = playButton.x
			profileButton.y = themesButton.y + themesButton.height + DynamicConstants.BUTTON_SPACING;
			
			
			
			addButton(playButton);
			addButton(profileButton);
			addButton(themesButton);
			
			buttonSignal.add(handleInteraction);
			
			onScreenElements.push(playButton, themesButton, profileButton);
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
			}
		}
		
		public function readyForRemoval():void{
			super.destroy();
			readyToRemoveSignal.dispatch();
		}
		
		private function destroy(e:Event):void{
			LOG.createCheckpoint("Settings Viewed");
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
		}
	}
}

