package com.edgington.view.huds.elements
{
	import com.edgington.constants.Constants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.net.GiftData;
	import com.edgington.util.TextFieldManager;
	import com.edgington.util.localisation.gettext;
	import com.edgington.valueobjects.net.ServerGiftVO;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import org.osflash.signals.Signal;
	
	public class element_inbox extends AbstractHud implements IAbstractHud
	{
		
		private var gifts:Vector.<ServerGiftVO>;
		
		private var readyToRemoveSignal:Signal;
		
		private var _width:int;
		private var _height:int;
		private var itemHeight:int;
		
		private var itemContainer:Sprite;
		
		private var inboxItemContainer:Sprite;
		
		private var maxItemsToShow:int;
		
		private var buttons:Vector.<element_mainMiniButton>;
		private var buttonOptions:Vector.<String>;
		private var loading:ui_loading
		
		public function element_inbox(_width:int, _height:int, maxItemsToShow:int)
		{
			super();
			
			readyToRemoveSignal = new Signal();
			
			this._width = _width;
			this._height = _height;
			this.maxItemsToShow = maxItemsToShow
			itemHeight = _height / maxItemsToShow;
			
			
			addListeners();
			
			setupVisuals();
			
			addElements();
		}
		
		public function addListeners():void{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			superRemoveSignal.addOnce(readyForRemoval);
			GiftData.getInstance().giftDataSignal.add(handleGiftsUpdate);
			GiftData.getInstance().getGifts();
		}
		
		public function setupVisuals():void{
			loading = new ui_loading();
			loading.x = _width*.5;
			loading.y = _height*.5;
			
			onScreenElements.push(loading);
			itemContainer = new Sprite();
			for(var i:int = 0; i < maxItemsToShow; i++){
				if(i%2 == 0){
					var listBackground:ui_listItem = new ui_listItem();
					listBackground.width = _width;
					listBackground.height = itemHeight;
					var ct:ColorTransform = new ColorTransform();
					ct.color = Constants.DARK_WHITE_COLOUR;
					listBackground.transform.colorTransform;
					listBackground.y = i*itemHeight
					itemContainer.addChild(listBackground);
				}
			}
		}

		private function generateListing():void{
			if(loading != null){
				removeSeperateElements(loading);
				loading = null;
			}
			
			inboxItemContainer = new Sprite();
			
			for(var i:int = 0; i < Math.min(gifts.length, maxItemsToShow); i++){
				if(gifts[i].credits > 0){
					inboxItemContainer.addChild(generateCreditsItem(gifts[i], i));
				}
			}
			
			this.addAdditionalElements(new <Sprite>[itemContainer, inboxItemContainer]);
			buttonSignal.add(handleInteraction);
		}
		
		private function generateCreditsItem(gift:ServerGiftVO, i:int):Sprite{
			var inboxItem:Sprite = new Sprite();
			var tfSentance:TextField;
			var tfItem:TextField;
			var itemSymbol:MovieClip;
			var button:element_mainMiniButton;
			
			var giftType:int;
			
			if(gift.from != null && !(gift.from is String) && gift.admin == ""){//If the from user is not a string
				var picture:element_profile_picture = new element_profile_picture(null, gift.from.fb_id);
				picture.width = picture.height = itemHeight - (DynamicConstants.DEVICE_SCALE*8);
				picture.y = picture.x = 4*DynamicConstants.DEVICE_SCALE;
				
				tfSentance = TextFieldManager.createTextField(gettext("inbox_credit_item_description_friend_"+Math.ceil(Math.random()*13), {name:gift.from.username}), FONT_audiobrush_content_bold, Constants.DARK_FONT_COLOR, itemHeight*.3, false, TextFieldAutoSize.LEFT);
				tfSentance.x = itemHeight;
				
				giftType = 0;
				
				inboxItem.addChild(picture);
			}
			else{
				if(gift.admin != null && gift.admin != ""){
					var strings:Array = gift.admin.split("_");
					if(strings[0] == "achievement"){
						tfSentance = TextFieldManager.createTextField(gettext("inbox_credit_item_description_"+gift.admin), FONT_audiobrush_content_bold, Constants.DARK_FONT_COLOR, itemHeight*.3, false, TextFieldAutoSize.LEFT);
						tfSentance.x = 4*DynamicConstants.DEVICE_SCALE;
						giftType = 1;
					}
					else if(strings[0] == "redeem"){
						tfSentance = TextFieldManager.createTextField("NEED TO DO REDEEM CODE", FONT_audiobrush_content_bold, Constants.DARK_FONT_COLOR, itemHeight*.3, false, TextFieldAutoSize.LEFT);
						tfSentance.x = 4*DynamicConstants.DEVICE_SCALE;
						giftType = 2;
					}
					else if(strings[0] == "tournament"){
						tfSentance = TextFieldManager.createTextField(gettext("inbox_tournament_item_description"), FONT_audiobrush_content_bold, Constants.DARK_FONT_COLOR, itemHeight*.3, false, TextFieldAutoSize.LEFT);
						tfSentance.x = 4*DynamicConstants.DEVICE_SCALE;
						giftType = 1;
					}
					else if(strings[0] == "admin"){
						tfSentance = TextFieldManager.createTextField(gettext("inbox_admin_item_description"), FONT_audiobrush_content_bold, Constants.DARK_FONT_COLOR, itemHeight*.3, false, TextFieldAutoSize.LEFT);
						tfSentance.x = 4*DynamicConstants.DEVICE_SCALE;
						giftType = 1;
					}
					else if(strings[0] == "update"){
						tfSentance = TextFieldManager.createTextField(gettext("inbox_updating_item_description"), FONT_audiobrush_content_bold, Constants.DARK_FONT_COLOR, itemHeight*.3, false, TextFieldAutoSize.LEFT);
						tfSentance.x = 4*DynamicConstants.DEVICE_SCALE;
						giftType = 1;
					}
				}
			}
			tfSentance.y = 4*DynamicConstants.DEVICE_SCALE;
			if(gift.credits > 0){
				itemSymbol = new ui_credits_symbol() as MovieClip;
				tfItem = TextFieldManager.createTextField(gettext("inbox_item_name_credits_"+(gift.credits>1), {credits:gift.credits}), FONT_audiobrush_content, Constants.DARK_FONT_COLOR, itemHeight*.25, false, TextFieldAutoSize.LEFT);
			}
			else{
				itemSymbol = new ui_items_symbol() as MovieClip;
			}
			itemSymbol.width = itemSymbol.height = itemHeight*.3;
			itemSymbol.x = tfSentance.x + (itemSymbol.width*.75);
			itemSymbol.y = tfSentance.y + tfSentance.textHeight + (4*DynamicConstants.DEVICE_SCALE) + (itemSymbol.height*.5);
			tfItem.x = itemSymbol.x + (itemSymbol.width);
			tfItem.y = itemSymbol.y - itemSymbol.height*.5;// + (4*DynamicConstants.DEVICE_SCALE);
			switch(giftType){
				case 0:
					button = new element_mainMiniButton(gettext("inbox_button_accept_n_gift"), "gift_"+gift._id);		
					break;
				case 1:
					button = new element_mainMiniButton(gettext("inbox_button_collect"), "gift_"+gift._id);
					break;
				case 2:
					button = new element_mainMiniButton(gettext("inbox_button_collect"), "gift_"+gift._id);
					break;
			}
			
			button.x = _width - button.width - DynamicConstants.BUTTON_SPACING;
			button.y = itemHeight *.5 - button.height*.5;
			addButton(button);
			
			inboxItem.addChild(tfSentance);
			inboxItem.addChild(itemSymbol);
			inboxItem.addChild(tfItem);
			inboxItem.addChild(button);
			
			inboxItem.y = itemHeight*i;
			
			return inboxItem;
		}
		
		public function populateInbox(gifts:Vector.<ServerGiftVO>):void{
			this.gifts = gifts;
		}
		
		private function handleGiftsUpdate():void{
			this.gifts = GiftData.getInstance().gifts.concat();
			generateListing();
		}
		
		private function handleInteraction(buttonOption:String):void{
			var str:Array = buttonOption.split("_");
			if(str[0] == "gift"){
				for(var i:int = 0; i < gifts.length; i++){
					if(gifts[i]._id == str[1]){
						GiftData.getInstance().acceptAndSend(gifts.splice(i, 1));
						inboxItemContainer.removeChildAt(i);
						for(var b:int = i; b < inboxItemContainer.numChildren; b++){
							inboxItemContainer.getChildAt(b).y -= itemHeight;
						}
						break;
					}
				}
			}
		}
		
		public function readyForRemoval():void
		{
			super.destroy();
			readyToRemoveSignal.dispatch();
		}
		
		private function destroy(e:Event):void{
			GiftData.getInstance().giftDataSignal.remove(handleGiftsUpdate);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
		}
	}
}