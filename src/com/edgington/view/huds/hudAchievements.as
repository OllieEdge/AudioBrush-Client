package com.edgington.view.huds
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_achievementsListing;
	import com.edgington.view.huds.elements.element_mainButton;
	
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class hudAchievements extends AbstractHud implements IAbstractHud
	{
		
		private var readyToRemoveSignal:Signal;
		
		private var backButton:element_mainButton;
		
		private var buttonOptions:Vector.<String> = new <String>["BACK"];
		
		private var achievementsListing:element_achievementsListing;
		
		public function hudAchievements(removeSignal:Signal)
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
			achievementsListing = new element_achievementsListing();
				
			backButton = new element_mainButton(gettext("achievements_screen_back_button"), buttonOptions[0]);
			backButton.x = DynamicConstants.SCREEN_MARGIN;
			backButton.y = achievementsListing._height + DynamicConstants.SCREEN_MARGIN + DynamicConstants.BUTTON_SPACING;
			
			addButton(backButton);
			
			buttonSignal.add(handleInteraction);
			
			onScreenElements.push(achievementsListing, backButton);
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
			achievementsListing = null;
			backButton = null;
		}
	}
}