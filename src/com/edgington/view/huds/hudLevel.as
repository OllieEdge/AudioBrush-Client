package com.edgington.view.huds
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.GameLevelInformationHandler;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.elements.element_levelUp;
	import com.edgington.view.huds.elements.element_mainButton;
	
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class hudLevel extends AbstractHud
	{
		private var okButton:element_mainButton;
		
		private var readyToRemoveSignal:Signal;
		
		private var buttonOptions:Vector.<String> = new <String>["OK"];
		
		private var level:element_levelUp;
		
		public function hudLevel(removeSignal:Signal)
		{
			super();
			
			readyToRemoveSignal = removeSignal;
			
			addListeners();
			
			setupVisuals();
			
			addElements();
		}
		
		public function addListeners():void{
			LOG.createCheckpoint("MENU: Level");
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			superRemoveSignal.addOnce(readyForRemoval);
		}
		
		public function setupVisuals():void{
			level = new element_levelUp();
			level.x = DynamicConstants.SCREEN_WIDTH * .5 - level.width*.5;
			level.y = DynamicConstants.SCREEN_HEIGHT * .5 - level.height*.5;
			
			okButton = new element_mainButton(gettext("level_screen_ok_button"), buttonOptions[0]);
			okButton.x = DynamicConstants.SCREEN_WIDTH * .5 - okButton.width * .5;
			okButton.y = level.y + level.height;
			
			addButton(okButton);
			
			buttonSignal.add(handleInteraction);
			
			onScreenElements.push(level, okButton);
		}
		
		private function handleInteraction(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_MAIN;
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
			
			GameLevelInformationHandler.deleteInstance();
		}
	}
}