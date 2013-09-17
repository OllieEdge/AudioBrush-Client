package com.edgington.view.huds
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.SettingsProxy;
	import com.edgington.types.DeviceTypes;
	import com.edgington.types.GameStateTypes;
	import com.edgington.types.HandDirectionType;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_handSelection;
	import com.edgington.view.huds.elements.element_mainButton;
	
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class miniHudHandSelection extends AbstractHud implements IAbstractHud
	{
		
		private var readyToRemoveSignal:Signal;
		
		private var message:element_handSelection;
		
		private var leftButton:element_mainButton;
		private var rightButton:element_mainButton;
		
		private var buttonOptions:Vector.<String> = new <String>["right", "left"];
		
		public function miniHudHandSelection(removeSignal:Signal)
		{
			super();
			
			readyToRemoveSignal = removeSignal;
			
			addListeners();
			
			setupVisuals();
			
			addElements();
		}
		
		public function addListeners():void
		{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			superRemoveSignal.addOnce(readyForRemoval);
		}
		
		public function setupVisuals():void
		{
			message = new element_handSelection();
			message.x = DynamicConstants.SCREEN_WIDTH*.5 - message.width*.5;
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
				message.y = DynamicConstants.SCREEN_MARGIN;
			}
			else{
				message.y = DynamicConstants.SCREEN_HEIGHT*.5 - message.height*.5;
			}
			
			leftButton = new element_mainButton(gettext("settings_hand_selection_left_button"), buttonOptions[1]);
			leftButton.x = message.x;
			leftButton.y = message.y + message.height + DynamicConstants.BUTTON_SPACING;
			
			rightButton = new element_mainButton(gettext("settings_hand_selection_right_button"), buttonOptions[0]);
			rightButton.x = message.x + message.width - rightButton.width;
			rightButton.y = message.y + message.height + DynamicConstants.BUTTON_SPACING;
			
			addButton(leftButton);
			addButton(rightButton);
			
			buttonSignal.add(handleInteraction);
			
			onScreenElements.push(message, leftButton, rightButton);
		}
		
		private function handleInteraction(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
					SettingsProxy.getInstance().changeHandSelection(HandDirectionType.RIGHT_HAND);
					break;
				case buttonOptions[1]:
					SettingsProxy.getInstance().changeHandSelection(HandDirectionType.LEFT_HAND);
					break;
			}
			cleanButtons();
		}
		
		public function readyForRemoval():void
		{
			DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_MAIN;
			super.destroy();
			readyToRemoveSignal.dispatch();
		}
		
		private function destroy(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
	}
}