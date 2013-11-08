package com.edgington.view.huds
{
	import com.adobe.ane.productStore.Product;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.events.TransactionABEvent;
	import com.edgington.model.payments.MobilePurchaseManager;
	import com.edgington.types.DeviceTypes;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_mainButton;
	import com.edgington.view.huds.elements.element_mainMessage;
	import com.edgington.view.huds.elements.element_purchaseButton;
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class hudPurchase extends AbstractHud implements IAbstractHud
	{
		
		private var readyToRemoveSignal:Signal;
		
		private var buttonOptions:Vector.<String> = new <String>["SMALL", "MEDIUM", "UNLIMITED", "LARGE", "BACK", "DISMISS_TRANSACTION_REPORT"];
		
		private var smallCreditsButton:element_purchaseButton;
		private var mediumCreditsButton:element_purchaseButton;
		private var largeCreditsButton:element_purchaseButton;
		private var unlimitedCreditsButton:element_purchaseButton;
		private var backButton:element_mainButton;
		
		private var dismissButton:element_mainButton;
		
		private var reportMessage:element_mainMessage;
		
		public function hudPurchase(removeSignal:Signal)
		{
			super();
			
			readyToRemoveSignal = removeSignal;
			
			addListeners();
			
			setupVisuals();
			
			addElements();
		}
		
		public function addListeners():void
		{
			LOG.createCheckpoint("MENU: Credits Purchase");
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			superRemoveSignal.addOnce(readyForRemoval);
			MobilePurchaseManager.INSTANCE.transactionSignal.add(handleTransactionEvent);
		}
		
		public function setupVisuals():void
		{
			if(MobilePurchaseManager.INSTANCE.avaliable){
				var products:Vector.<Product> = MobilePurchaseManager.INSTANCE.getProducts();
				
				sortProducts(products);
				
				if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
					smallCreditsButton = new element_purchaseButton(products[0], buttonOptions[0], DynamicConstants.SCREEN_WIDTH*.7);
					smallCreditsButton.x = DynamicConstants.SCREEN_MARGIN;
					smallCreditsButton.y = DynamicConstants.SCREEN_MARGIN;
					mediumCreditsButton = new element_purchaseButton(products[1], buttonOptions[1], DynamicConstants.SCREEN_WIDTH*.7);
					mediumCreditsButton.x = smallCreditsButton.x;
					mediumCreditsButton.y = smallCreditsButton.y + smallCreditsButton.height + DynamicConstants.BUTTON_SPACING;
					//unlimitedCreditsButton = new element_purchaseButton(products[2], buttonOptions[2], DynamicConstants.SCREEN_WIDTH*.7);
					//unlimitedCreditsButton.x = smallCreditsButton.x;
					//unlimitedCreditsButton.y = mediumCreditsButton.y + mediumCreditsButton.height + DynamicConstants.BUTTON_SPACING;
					largeCreditsButton = new element_purchaseButton(products[2], buttonOptions[3], DynamicConstants.SCREEN_WIDTH*.7);
					largeCreditsButton.x = smallCreditsButton.x;
					largeCreditsButton.y = mediumCreditsButton.y + mediumCreditsButton.height + DynamicConstants.BUTTON_SPACING;
					
//					profileIpadProfile = new element_mainMenuProfileIphone();
//					profileIpadProfile.scaleX = profileIpadProfile.scaleY = DynamicConstants.MESSAGE_SCALE;
//					profileIpadProfile.x = DynamicConstants.SCREEN_WIDTH - DynamicConstants.SCREEN_MARGIN - profileIpadProfile.width;
//					profileIpadProfile.y = DynamicConstants.SCREEN_MARGIN;
//					onScreenElements.push(profileIpadProfile);
				}
				else{
					smallCreditsButton = new element_purchaseButton(products[0], buttonOptions[0], DynamicConstants.SCREEN_WIDTH*.6);
					smallCreditsButton.x = DynamicConstants.SCREEN_MARGIN;
					smallCreditsButton.y = DynamicConstants.SCREEN_MARGIN;
					mediumCreditsButton = new element_purchaseButton(products[1], buttonOptions[1], DynamicConstants.SCREEN_WIDTH*.6);
					mediumCreditsButton.x = smallCreditsButton.x;
					mediumCreditsButton.y = smallCreditsButton.y + smallCreditsButton.height + DynamicConstants.BUTTON_SPACING;
					//unlimitedCreditsButton = new element_purchaseButton(products[2], buttonOptions[2], DynamicConstants.SCREEN_WIDTH*.6);
					//unlimitedCreditsButton.x = smallCreditsButton.x;
					//unlimitedCreditsButton.y = mediumCreditsButton.y + mediumCreditsButton.height + DynamicConstants.BUTTON_SPACING;
					largeCreditsButton = new element_purchaseButton(products[2], buttonOptions[3], DynamicConstants.SCREEN_WIDTH*.6);
					largeCreditsButton.x = smallCreditsButton.x;
					largeCreditsButton.y = mediumCreditsButton.y + mediumCreditsButton.height + DynamicConstants.BUTTON_SPACING;
					
//					profileIpadProfile = new element_mainMenuProfileIphone();
//					profileIpadProfile.x = DynamicConstants.SCREEN_WIDTH - DynamicConstants.SCREEN_MARGIN - profileIpadProfile.width;
//					profileIpadProfile.y = DynamicConstants.SCREEN_MARGIN;
//					onScreenElements.push(profileIpadProfile);
				}
				
				backButton = new element_mainButton(gettext("purchase_menu_back"), buttonOptions[4]);
				backButton.x = DynamicConstants.SCREEN_MARGIN;
				backButton.y = DynamicConstants.SCREEN_HEIGHT - backButton.height - DynamicConstants.SCREEN_MARGIN;
				
				addButton(smallCreditsButton);
				addButton(mediumCreditsButton);
				//addButton(unlimitedCreditsButton);
				addButton(largeCreditsButton);
				addButton(backButton);
				onScreenElements.push(smallCreditsButton, mediumCreditsButton, largeCreditsButton, backButton);
			}
			else{
				reportMessage = new element_mainMessage(gettext("purchase_error_downloading_options"));
				if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
					reportMessage.x = DynamicConstants.SCREEN_WIDTH*.5 - reportMessage.width*.5;
					reportMessage.y = DynamicConstants.SCREEN_MARGIN;
				}
				else{
					reportMessage.x = DynamicConstants.SCREEN_WIDTH*.5 - reportMessage.width*.5;
					reportMessage.y = DynamicConstants.SCREEN_HEIGHT*.5 - reportMessage.height*.5;	
				}
				dismissButton = new element_mainButton(gettext("purchase_menu_dismiss_transaction_report"), buttonOptions[4]);
				dismissButton.x = reportMessage.x + reportMessage.width - dismissButton.width;
				dismissButton.y = reportMessage.y + reportMessage.height + DynamicConstants.BUTTON_SPACING;
				addButton(dismissButton);
				onScreenElements.push(reportMessage, dismissButton);
			}
			
			buttonSignal.add(handleInteractions);
			
		}
		
		private function addReportMessage():void{
			reportMessage = new element_mainMessage(gettext("purchase_menu_processing_transaction"), true);
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
				reportMessage.x = DynamicConstants.SCREEN_WIDTH*.5 - reportMessage.width*.5;
				reportMessage.y = DynamicConstants.SCREEN_MARGIN;
			}
			else{
				reportMessage.x = DynamicConstants.SCREEN_WIDTH*.5 - reportMessage.width*.5;
				reportMessage.y = DynamicConstants.SCREEN_HEIGHT*.5 - reportMessage.height*.5;	
			}
			
			
			addAdditionalElements(new <Sprite>[reportMessage]);
		}
		
		private function handleInteractions(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
					TweenLite.delayedCall(1.5, MobilePurchaseManager.INSTANCE.purchaseSmallCredits);
					cleanButtons(false);
					addReportMessage();
					break;
				case buttonOptions[1]:
					TweenLite.delayedCall(1.5, MobilePurchaseManager.INSTANCE.purchaseMediumCredits);
					cleanButtons(false);
					addReportMessage();
					break;
				case buttonOptions[3]:
					TweenLite.delayedCall(1.5, MobilePurchaseManager.INSTANCE.purchaseLargeCredits);
					cleanButtons(false);
					addReportMessage();
					break;
				case buttonOptions[4]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_MAIN;
					cleanButtons();
					break;
				case buttonOptions[5]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.PURCHASES;
					cleanButtons();
					break;
			}
		}
		
		public function readyForRemoval():void
		{
			super.destroy();
			readyToRemoveSignal.dispatch();
		}
		
		private function handleTransactionEvent(eventType:String, messageText:String = null):void{
			switch(eventType){
				case TransactionABEvent.TRANSACTION_COMPLETE:
						dismissButton = new element_mainButton(gettext("purchase_menu_dismiss_transaction_report"), buttonOptions[5]);
						dismissButton.x = reportMessage.x + reportMessage.width - dismissButton.width;
						dismissButton.y = reportMessage.y + reportMessage.height + DynamicConstants.BUTTON_SPACING;
						addButton(dismissButton);
						addAdditionalElements(new <Sprite>[dismissButton]);
						reportMessage.changeMessage(messageText);
						buttonSignal.add(handleInteractions);
					break;
				case TransactionABEvent.TRANSACTION_FAILED:
						dismissButton = new element_mainButton(gettext("purchase_menu_dismiss_transaction_report"), buttonOptions[5]);
						dismissButton.x = reportMessage.x + reportMessage.width - dismissButton.width;
						dismissButton.y = reportMessage.y + reportMessage.height + DynamicConstants.BUTTON_SPACING;
						addButton(dismissButton);
						addAdditionalElements(new <Sprite>[dismissButton]);
						reportMessage.changeMessage(messageText);
						buttonSignal.add(handleInteractions);
					break;
			}
			
		}
		
		private function sortProducts(toSort:Vector.<Product>):Vector.<Product>{
			var changed:Boolean = false;
			
			while (!changed)
			{
				changed = true;
				
				for (var i:int = 0; i < toSort.length - 1; i++)
				{
					if (toSort[i].price > toSort[i + 1].price)
					{
						var tmp:Product = toSort[i];
						toSort[i] = toSort[i + 1];
						toSort[i + 1] = tmp;
						
						changed = false;
					}
				}
			}
			
			return toSort;
		}
		
		private function destroy(e:Event):void{
			DynamicConstants.DISABLE_RELOAD = false;
			MobilePurchaseManager.INSTANCE.transactionSignal.remove(handleTransactionEvent);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			smallCreditsButton = null;
			mediumCreditsButton = null;
			largeCreditsButton = null;
			unlimitedCreditsButton = null;
			backButton = null;
			dismissButton = null;
			reportMessage = null;
		}
	}
}