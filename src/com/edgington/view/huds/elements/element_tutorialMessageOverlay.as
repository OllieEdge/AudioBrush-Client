package com.edgington.view.huds.elements
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.GameProxy;
	import com.edgington.model.TutorialManager;
	import com.edgington.model.audio.AudioModel;
	import com.edgington.model.events.ButtonEvent;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class element_tutorialMessageOverlay extends Sprite
	{
		
		private var message:element_mainMessage;
		
		private var okButton:element_mainButton;
		
		public function element_tutorialMessageOverlay()
		{
			super();
			
			addListeners();
			
			setupVisuals();
		}
		
		private function addListeners():void{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);		
		}
		
		private function setupVisuals():void{
			
		}
		
		public function displayNewTutorialMessage(tutorialID:int):void{
			if(message != null){
				removeCurrentMessage();
			}
			message = new element_mainMessage(gettext("tutorial_gameplay_message_" + tutorialID), false, new ui_message_iumage_tutorial());
			okButton = new element_mainButton(gettext("tutorial_ok_button"), "tutorial");
			switch(tutorialID){
				case 0:
					message.x = DynamicConstants.SCREEN_WIDTH * .5 - message.width*.5;
					message.y = DynamicConstants.SCREEN_HEIGHT * .5 - message.height*.5;
					break;
				case 2:
					message.x = DynamicConstants.SCREEN_WIDTH * .5 - message.width*.5;
					message.y = DynamicConstants.SCREEN_HEIGHT * .5 - message.height*.5;
					break;
				case 4:
					message.x = DynamicConstants.SCREEN_WIDTH * .5 - message.width*.5;
					message.y = DynamicConstants.SCREEN_HEIGHT * .5 - message.height*.5;
					break;
				case 6:
					message.x = DynamicConstants.SCREEN_WIDTH * .5 - message.width*.5;
					message.y = DynamicConstants.SCREEN_HEIGHT * .5 - message.height*.5;
					break;
				case 7:
					message.x = DynamicConstants.SCREEN_WIDTH * .1;
					message.y = DynamicConstants.SCREEN_HEIGHT * .1;
					break;
				case 8:
					message.x = DynamicConstants.SCREEN_WIDTH * .9 - message.width;
					message.y = DynamicConstants.SCREEN_HEIGHT * .1;
					break;
				case 9:
					message.x = DynamicConstants.SCREEN_WIDTH * .5 - message.width*.5;
					message.y = DynamicConstants.SCREEN_HEIGHT * .1;
					break;
				case 10:
					message.x = DynamicConstants.SCREEN_WIDTH * .1;
					message.y = DynamicConstants.SCREEN_HEIGHT * .9 - message.height;
					break;
				case 11:
					message.x = DynamicConstants.SCREEN_WIDTH * .5 - message.width*.5;
					message.y = DynamicConstants.SCREEN_HEIGHT * .5 - message.height*.5;
					break;
			}
			okButton.x = message.x + message.width - okButton.width;
			okButton.y = message.y + message.height + DynamicConstants.BUTTON_SPACING;
			
			okButton.buttonSignal.add(handleButtonPress);
			
			this.addChild(okButton);
			this.addChild(message);
		}
		
		private function handleButtonPress(eventType:String, buttonOption:String = ""):void{
			if(eventType == ButtonEvent.BUTTON_PRESSED){
				if(buttonOption == "tutorial"){
					TutorialManager.getInstance().currentTutorialStage++;
					LOG.debug("TUTORIAL: Increased tutorial stage to - " + TutorialManager.getInstance().currentTutorialStage);
					if(TutorialManager.getInstance().currentTutorialStage == 7){
						GameProxy.INSTANCE.tutorialSignal.dispatch(true, 7);
					}
					if(TutorialManager.getInstance().currentTutorialStage == 8){
						GameProxy.INSTANCE.tutorialSignal.dispatch(true, 8);
					}
					if(TutorialManager.getInstance().currentTutorialStage == 9){
						GameProxy.INSTANCE.tutorialSignal.dispatch(true, 9);
					}
					if(TutorialManager.getInstance().currentTutorialStage == 10){
						GameProxy.INSTANCE.tutorialSignal.dispatch(true, 10);
					}
					if(TutorialManager.getInstance().currentTutorialStage == 11){
						GameProxy.INSTANCE.tutorialSignal.dispatch(true, 11);
					}
					if(TutorialManager.getInstance().currentTutorialStage >= 12){
						AudioModel.getInstance().pausedTrackPosition = TutorialManager.getInstance().soundPositionStage_4 * AudioModel.getInstance().soundObject.length;
						GameProxy.INSTANCE.tutorialSignal.dispatch(false);
					}
					if(TutorialManager.getInstance().currentTutorialStage < 7){
						GameProxy.INSTANCE.tutorialSignal.dispatch(false);
					}
				}
			}
		}
		
		public function removeMessage():void{
			removeCurrentMessage();
		}
		
		private function removeCurrentMessage():void{
			this.removeChild(message);
			message = null;
		}
		
		private function destroy(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0 ){
				this.removeChildAt(0);
			}
		}
	}
}