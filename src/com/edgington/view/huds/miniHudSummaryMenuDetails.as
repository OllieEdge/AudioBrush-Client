package com.edgington.view.huds
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.types.DeviceTypes;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_mainButton;
	import com.edgington.view.huds.elements.element_summaryDetailsOutcome;
	import com.edgington.view.huds.elements.element_summaryDetailsTitle;
	
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class miniHudSummaryMenuDetails extends AbstractHud implements IAbstractHud
	{
		
		private var readyToRemoveSignal:Signal;
		
		private var title:element_summaryDetailsTitle;
		private var details:element_summaryDetailsOutcome;
		
		private var backButton:element_mainButton;
		
		private var buttonOptions:Vector.<String> = new <String>["BACK"];
		
		public function miniHudSummaryMenuDetails(removeSignal:Signal)
		{
			super();
			
			readyToRemoveSignal = removeSignal;
			
			addListeners();
			
			setupVisuals();
			
			addElements();
		}
		
		public function addListeners():void
		{
			LOG.createCheckpoint("MENU: Summary Details");
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			superRemoveSignal.addOnce(readyForRemoval);
		}
		
		public function setupVisuals():void
		{
			
			title = new element_summaryDetailsTitle();
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
				title.x = DynamicConstants.SCREEN_WIDTH*.5 - title.width*.5;
				title.y = DynamicConstants.SCREEN_MARGIN*.25;
			}
			else{
				title.x = DynamicConstants.SCREEN_WIDTH*.5 - title.width*.5;
				title.y = DynamicConstants.SCREEN_HEIGHT*.4 - title.height;
			}
			details = new element_summaryDetailsOutcome();
			details.x = DynamicConstants.SCREEN_WIDTH*.5 - title.width*.5;
			details.y = title.y + title.height + DynamicConstants.BUTTON_SPACING;
			
			backButton = new element_mainButton(gettext("summary_screen_detail_back_button"), buttonOptions[0]);
			backButton.x = details.x + details.width - backButton.width;
			backButton.y = details.y + details.height + DynamicConstants.BUTTON_SPACING;
			
			addButton(backButton);
			
			buttonSignal.add(handleInteraction);
			
			onScreenElements.push(title, details, backButton);
		}
		
		private function handleInteraction(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.SUMMARY_MENU;
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
			backButton = null;
			details = null;
			title = null;
		}
	}
}