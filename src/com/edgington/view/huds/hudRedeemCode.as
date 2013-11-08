package com.edgington.view.huds
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_mainButton;
	import com.edgington.view.huds.elements.element_redeemCode;
	
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class hudRedeemCode extends AbstractHud implements IAbstractHud
	{
		
		private var redeem:element_redeemCode;
		
		private var redeemButton:element_mainButton;
		private var backButton:element_mainButton;
		
		private var buttonOptions:Vector.<String> = new <String>["BACK", "REDEEM"];
		private var readyToRemoveSignal:Signal;
		
		private var redeemSignal:Signal;
		
		public function hudRedeemCode(removeSignal:Signal)
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
			redeemSignal = new Signal();
			redeemSignal.add(redeemCodeHandler);
		}
		
		public function setupVisuals():void{
			redeem = new element_redeemCode(redeemSignal);
			redeem.x = DynamicConstants.SCREEN_WIDTH *.5 - redeem.width*.5;
			redeem.y = DynamicConstants.SCREEN_HEIGHT *.5 - redeem.height*.5;
			
			redeemButton = new element_mainButton(gettext("redeem_code_redeem_button"), buttonOptions[1]);
			redeemButton.x = redeem.x + redeem.width - redeemButton.width;
			redeemButton.y = redeem.y + redeem.height + DynamicConstants.BUTTON_SPACING;
			
			backButton = new element_mainButton(gettext("redeem_code_back_button"), buttonOptions[0]);
			backButton.x = redeem.x;
			backButton.y = redeem.y + redeem.height + DynamicConstants.BUTTON_SPACING;
			
			buttonSignal.add(handleInteraction);
			
			addButton(redeemButton);
			addButton(backButton);
			
			onScreenElements.push(redeem, redeemButton, backButton);
		}
		
		private function redeemCodeHandler(code:String):void{
			LOG.debug("Redeem Code: " + code);
		}
		
		private function handleInteraction(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_SETTINGS;
					cleanButtons();
					break;
				case buttonOptions[1]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_SETTINGS;
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
			
			redeem = null;
			redeemButton = null;
			backButton = null;
		}
	}
}