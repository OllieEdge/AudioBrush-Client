package com.edgington.view.huds
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.SoundConstants;
	import com.edgington.model.SettingsProxy;
	import com.edgington.model.SoundManager;
	import com.edgington.model.facebook.opengraph.actions.OpenGraphUnlockAction;
	import com.edgington.model.facebook.opengraph.images.OpenGraphImages;
	import com.edgington.model.facebook.opengraph.objects.OpenGraphThemeObject;
	import com.edgington.net.AchievementData;
	import com.edgington.net.ProductsData;
	import com.edgington.net.UserData;
	import com.edgington.types.DeviceTypes;
	import com.edgington.types.GameStateTypes;
	import com.edgington.types.ThemeTypes;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_mainButton;
	import com.edgington.view.huds.elements.element_themeDisplay;
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.osflash.signals.Signal;
	
	public class hudThemesMenu extends AbstractHud implements IAbstractHud
	{
		
		private var readyToRemoveSignal:Signal;
		
		private var nextButton:ui_arrow_button;
		private var previousButton:ui_arrow_button;
		
		private var buyButton:element_mainButton;
		private var useButton:element_mainButton;
		private var backButton:element_mainButton;
		
		private var themes:Vector.<element_themeDisplay>;
		
		private var buttonOptions:Vector.<String> = new <String>["BACK", "BUY", "SELECT"];

		private var currentIndex:int = 0;
		
		private var tweens:Vector.<TweenMax>;
		private var disableArrows:Boolean = false;
		
		public function hudThemesMenu(removeSignal:Signal)
		{
			super();
			
			readyToRemoveSignal = removeSignal;
			
			tweens = new Vector.<TweenMax>;
			
			addListeners();
			
			setupVisuals();
			
			addElements();
			
			
			if(themes[currentIndex].isCurrentTheme){
				selectButtonSwitcher(false);
				buyButtonSwitcher(false);
			}
			else if(themes[currentIndex].hasUnlockedTheme){
				selectButtonSwitcher(true);
			}
			else if(!themes[currentIndex].hasUnlockedTheme){
				buyButtonSwitcher(true, themes[currentIndex].themeVO.themeCost);
			}
			
			
		}
		
		public function addListeners():void
		{
			LOG.createCheckpoint("MENU: Themes");
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			superRemoveSignal.addOnce(readyForRemoval);
		}
		
		public function setupVisuals():void
		{
			themes = new Vector.<element_themeDisplay>;
			themes.push(new element_themeDisplay(ThemeTypes.NORMAL_THEME));
			themes.push(new element_themeDisplay(ThemeTypes.ICE_THEME));
			themes.push(new element_themeDisplay(ThemeTypes.FIRE_THEME));
			
			themes[currentIndex].x = DynamicConstants.SCREEN_WIDTH*.5 - themes[currentIndex].getWidth()*.5;
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
				themes[currentIndex].y = DynamicConstants.SCREEN_MARGIN;
			}
			else{
				themes[currentIndex].y = DynamicConstants.SCREEN_HEIGHT*.5 - themes[currentIndex].getHeight()*.5;	
			}
			
			themes[1].visible = false;
			themes[2].visible = false;
			
			onScreenElements.push(themes[0], themes[1], themes[2]);
			
			nextButton = new ui_arrow_button();
			nextButton.scaleX = nextButton.scaleY = DynamicConstants.DEVICE_SCALE;
			nextButton.x = themes[currentIndex].x + themes[currentIndex].getWidth() + DynamicConstants.BUTTON_SPACING + nextButton.width;
			nextButton.y = themes[currentIndex].y + (themes[currentIndex].getHeight()*.5);
			
			previousButton = new ui_arrow_button();
			previousButton.scaleX = previousButton.scaleY = DynamicConstants.DEVICE_SCALE;
			previousButton.scaleX = -previousButton.scaleX; 
			previousButton.x = themes[currentIndex].x - (DynamicConstants.BUTTON_SPACING + previousButton.width);
			previousButton.y = nextButton.y;
			
			nextButton.addEventListener(MouseEvent.MOUSE_UP, handleArrowClick);
			previousButton.addEventListener(MouseEvent.MOUSE_UP, handleArrowClick);
			
			nextButton.addEventListener(MouseEvent.MOUSE_DOWN, handleArrowHighlight);
			previousButton.addEventListener(MouseEvent.MOUSE_DOWN, handleArrowHighlight);
			
			backButton = new element_mainButton(gettext("purchase_menu_back"), buttonOptions[0]);
			backButton.x = themes[currentIndex].x;
			backButton.y = themes[currentIndex].y + themes[currentIndex].getHeight() + DynamicConstants.BUTTON_SPACING;
		
			addButton(backButton);
			
			buttonSignal.add(handleInteraction);
			
			onScreenElements.push(themes[currentIndex], backButton, nextButton, previousButton);
		}
		
		private function handleInteraction(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_MAIN;
					cleanButtons();
					break;
				case buttonOptions[1]:
					if(UserData.getInstance().getCredits() >= themes[currentIndex].themeVO.themeCost){
						UserData.getInstance().useCredits(themes[currentIndex].themeVO.themeCost);
						selectButtonSwitcher(true);
						UserData.getInstance().purchaseTheme(themes[currentIndex].themeVO.themeID);
						AchievementData.UnlockAchievement(21);
						var openGraphThemeObject:OpenGraphThemeObject = new OpenGraphThemeObject(themes[currentIndex].themeVO.themeName, gettext("opengraph_theme_unlock_description"), OpenGraphImages["IMAGE_URL_THEME_"+Math.ceil(Math.random()*1)]);
						var openGraphUnlockAction:OpenGraphUnlockAction = new OpenGraphUnlockAction(openGraphThemeObject, themes[currentIndex].share);
						themes[currentIndex].purchased();
						LOG.createCheckpoint("PURCHASE: Theme - " + themes[currentIndex].themeVO.themeName);
					}
					else{
						DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.PURCHASES;
						cleanButtons();
					}
					break;
				case buttonOptions[2]:
					if(ProductsData.getInstance().doesUserHaveProduct(themes[currentIndex].themeVO.themeID)){
						SettingsProxy.getInstance().changeTheme(themes[currentIndex].themeVO.themeID);
					}
					for(var i:int = 0; i < themes.length; i++){
						if(i != currentIndex){
							themes[i].selected(false);
						}
						else{
							themes[i].selected(true);
						}
					}
					selectButtonSwitcher(false);
					break;
			}
		}
		
		private function handleArrowClick(e:MouseEvent):void{
			e.currentTarget.gotoAndStop(1);
			if(!disableArrows){
				SoundManager.getInstance().loadAndPlaySFX(SoundConstants.SFX_TAB_SELECT, "", 1);
				disableArrows = true;
				if(e.currentTarget == previousButton){
					tweens.push(new TweenMax(themes[currentIndex], 0.3, {x:DynamicConstants.SCREEN_WIDTH, ease:Quad.easeOut, onComplete:clearAsset, onCompleteParams:[themes[currentIndex]]}));
					
					themes[getPreviousNumberReference()].x = -themes[getPreviousNumberReference()].width;
					if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
						themes[getPreviousNumberReference()].y = DynamicConstants.SCREEN_MARGIN;
					}
					else{
						themes[getPreviousNumberReference()].y = DynamicConstants.SCREEN_HEIGHT*.5 - themes[getPreviousNumberReference()].height*.5;	
					}
					
					themes[getPreviousNumberReference()].visible = true;
					
					tweens.push(new TweenMax(themes[getPreviousNumberReference()], 0.3, {x:DynamicConstants.SCREEN_WIDTH*.5 - themes[getPreviousNumberReference()].getWidth()*.5, ease:Quad.easeOut, onComplete:decreaseIndex}));
					if(themes[getPreviousNumberReference()].isCurrentTheme){
						selectButtonSwitcher(false);
						buyButtonSwitcher(false);
					}
					else if(themes[getPreviousNumberReference()].hasUnlockedTheme){
						selectButtonSwitcher(true);
					}
					else if(!themes[getPreviousNumberReference()].hasUnlockedTheme){
						buyButtonSwitcher(true, themes[getPreviousNumberReference()].themeVO.themeCost);
					}
				}
				else{
					tweens.push(new TweenMax(themes[currentIndex], 0.3, {x:-themes[currentIndex].width, ease:Quad.easeOut, onComplete:clearAsset, onCompleteParams:[themes[currentIndex]]}));
					
					themes[getNextNumberReference()].x = DynamicConstants.SCREEN_WIDTH;
					if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
						themes[getNextNumberReference()].y = DynamicConstants.SCREEN_MARGIN;
					}
					else{
						themes[getNextNumberReference()].y = DynamicConstants.SCREEN_HEIGHT*.5 - themes[getNextNumberReference()].getHeight()*.5;	
					}
					
					themes[getNextNumberReference()].visible = true;
					
					tweens.push(new TweenMax(themes[getNextNumberReference()], 0.3, {x:DynamicConstants.SCREEN_WIDTH*.5 - themes[getNextNumberReference()].getWidth()*.5, ease:Quad.easeOut, onComplete:increaseIndex}));
					if(themes[getNextNumberReference()].isCurrentTheme){
						selectButtonSwitcher(false);
						buyButtonSwitcher(false);
					}
					else if(themes[getNextNumberReference()].hasUnlockedTheme){
						selectButtonSwitcher(true);
					}
					else if(!themes[getNextNumberReference()].hasUnlockedTheme){
						buyButtonSwitcher(true, themes[getNextNumberReference()].themeVO.themeCost);
					}
				}
			}
		}
		
		private function buyButtonSwitcher(isOn:Boolean, price:int = 0):void{
			if(isOn && buyButton == null){
				selectButtonSwitcher(false);
				buyButton = new element_mainButton(gettext("purchase_menu_buy"), buttonOptions[1], price);
				buyButton.x = backButton.x + themes[currentIndex].getWidth() -buyButton.width;
				buyButton.y = backButton.y;
				
				if(buyButton.x < backButton.x + backButton.width){
					buyButton.x = backButton.x + backButton.width + DynamicConstants.BUTTON_SPACING;
				}
				
				addButton(buyButton);
				
				addAdditionalElements(new <Sprite>[buyButton]);
			}
			else if(isOn && buyButton != null){
				buyButton.changeCost(price);
			}
			else if(!isOn && buyButton != null){
				removeButton(buyButton);
				buyButton = null;
			}
		}
		
		private function selectButtonSwitcher(isOn:Boolean):void{
			if(isOn && useButton == null){
				buyButtonSwitcher(false);
				useButton = new element_mainButton(gettext("purchase_menu_select"), buttonOptions[2]);
				useButton.x = backButton.x + themes[currentIndex].getWidth() -useButton.width;
				useButton.y = backButton.y;
				
				if(useButton.x < backButton.x + backButton.width){
					useButton.x = backButton.x + backButton.width + DynamicConstants.BUTTON_SPACING;
				}
				
				addButton(useButton);
				
				addAdditionalElements(new <Sprite>[useButton]);
			}
			else if(!isOn && useButton != null){
				removeButton(useButton);
				useButton = null;
			}
		}
		
		private function decreaseIndex():void{
			currentIndex--;
			if(currentIndex < 0){
				currentIndex = themes.length-1;
			}
			disableArrows = false;
			tweens = new Vector.<TweenMax>;
		}
		private function increaseIndex():void{
			currentIndex++;
			if(currentIndex > themes.length-1){
				currentIndex = 0;
			}
			disableArrows = false;
			tweens = new Vector.<TweenMax>;
		}
		
		private function clearAsset(clip:element_themeDisplay):void{
			clip.visible = false;
		}
		
		private function handleArrowHighlight(e:MouseEvent):void{
			if(!disableArrows){
				e.currentTarget.gotoAndStop(2);
			}
		}
		
		public function readyForRemoval():void{
			super.destroy();
			readyToRemoveSignal.dispatch();
		}
		
		private function getPreviousNumberReference():int{
			if(currentIndex == 0){
				return themes.length-1;
			}
			return currentIndex-1;
		}
		
		private function getNextNumberReference():int{
			if(currentIndex+1 > themes.length-1){
				return 0;
			}
			return currentIndex+1;
		}
		
		private function destroy(e:Event):void{
			nextButton.removeEventListener(MouseEvent.MOUSE_UP, handleArrowClick);
			previousButton.removeEventListener(MouseEvent.MOUSE_UP, handleArrowClick);
			
			nextButton.removeEventListener(MouseEvent.MOUSE_DOWN, handleArrowHighlight);
			previousButton.removeEventListener(MouseEvent.MOUSE_DOWN, handleArrowHighlight);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			backButton = null;
		}
	}
}