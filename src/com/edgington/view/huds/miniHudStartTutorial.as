package com.edgington.view.huds
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.audio.AudioModel;
	import com.edgington.types.DeviceTypes;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_mainButton;
	import com.edgington.view.huds.elements.element_mainMessage;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class miniHudStartTutorial extends AbstractHud implements IAbstractHud
	{
		
		private var readyToRemoveSignal:Signal;
		
		private var message:element_mainMessage;
		
		private var backButton:element_mainButton;
		private var okButton:element_mainButton;
		
		private var buttonOptions:Vector.<String> = new <String>["CANCEL", "OK"];
		
		public function miniHudStartTutorial(removeSignal:Signal)
		{
			super();
			
			readyToRemoveSignal = removeSignal;
			
			addListeners();
			
			setupVisuals();
			
			addElements();
		}
		
		public function addListeners():void{
			LOG.createCheckpoint("TUTORIAL: Started");
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			superRemoveSignal.addOnce(readyForRemoval);
		}
		
		public function setupVisuals():void{
			
			message = new element_mainMessage(gettext("tutorial_start_message"), false, new ui_message_iumage_tutorial() as MovieClip);
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
				message.x = DynamicConstants.SCREEN_WIDTH*.5 - message.width*.5;
				message.y = DynamicConstants.SCREEN_MARGIN;
			}
			else{
				message.x = DynamicConstants.SCREEN_WIDTH*.5 - message.width*.5;
				message.y = DynamicConstants.SCREEN_HEIGHT*.5 - message.height*.5;	
			}
			
			backButton = new element_mainButton(gettext("tutorial_start_button_skip"), buttonOptions[0]);
			backButton.x = message.x;
			backButton.y = message.y + message.height + DynamicConstants.BUTTON_SPACING;
			
			okButton = new element_mainButton(gettext("tutorial_start_button_ok"), buttonOptions[1]);
			okButton.x = message.x + message.width - okButton.width;
			okButton.y = message.y + message.height + DynamicConstants.BUTTON_SPACING;
			
			addButton(backButton);
			addButton(okButton);
			
			buttonSignal.add(handleInteraction);
			
			onScreenElements.push(message, backButton, okButton);
		}
		
		
		private function handleInteraction(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_MAIN;
					cleanButtons();
					break;
				case buttonOptions[1]:
					AudioModel.getInstance().isTutorial = true;
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.GAME_LOADING;
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