package com.edgington.view.huds
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_mainButton;
	
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class miniHudPauseMenu extends AbstractHud implements IAbstractHud
	{
		
		private var readyToRemoveSignal:Signal;
		
		private var resumeButton:element_mainButton;
		private var quitButton:element_mainButton;
		
		private var buttonOptions:Vector.<String> = new <String>["QUIT", "RESUME"];
		
		public function miniHudPauseMenu(removeSignal:Signal)
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
			resumeButton = new element_mainButton(gettext("pause_menu_resume_button"), buttonOptions[1]);
			resumeButton.x = DynamicConstants.SCREEN_WIDTH*.5 - resumeButton.width*.5;
			resumeButton.y = DynamicConstants.SCREEN_HEIGHT*.5 - resumeButton.height;
			
			quitButton = new element_mainButton(gettext("pause_menu_quit_button"), buttonOptions[0]);
			quitButton.x = resumeButton.x;
			quitButton.y = DynamicConstants.SCREEN_HEIGHT*.5 + DynamicConstants.BUTTON_SPACING;
			
			addButton(resumeButton);
			addButton(quitButton);
			
			buttonSignal.add(handleInteraction);
			
			onScreenElements.push(resumeButton, quitButton);
		}
		
		private function handleInteraction(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_MAIN;
					cleanButtons();
					break;
				case buttonOptions[1]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.GAME_MAIN;
					cleanButtons();
					break;
			}
		}
		
		public function readyForRemoval():void
		{
			super.destroy();
			readyToRemoveSignal.dispatch();
		}
		
		private function destroy(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			resumeButton = null;
			quitButton = null;
		}
	}
}