package com.edgington.view.huds
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.SettingsProxy;
	import com.edgington.net.ProductsData;
	import com.edgington.net.UserData;
	import com.edgington.types.GameStateTypes;
	import com.edgington.types.ThemeTypes;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_mainButton;
	
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class hudThemesMenu extends AbstractHud implements IAbstractHud
	{
		
		private var readyToRemoveSignal:Signal;
		
		private var normalButton:element_mainButton;
		private var fireButton:element_mainButton;
		private var backButton:element_mainButton;
		
		private var buttonOptions:Vector.<String> = new <String>["NORMAL_THEME", "FIRE_THEME", "SETTINGS"];
		
		public function hudThemesMenu(removeSignal:Signal)
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
			normalButton = new element_mainButton(gettext("theme_menu_normal_button"), buttonOptions[0], ThemeTypes.NORMAL_THEME_COST);
			normalButton.x = DynamicConstants.SCREEN_MARGIN;
			normalButton.y = DynamicConstants.SCREEN_MARGIN;
			
			if(ProductsData.getInstance().doesUserHaveProduct(ThemeTypes.FIRE_THEME)){
				fireButton = new element_mainButton(gettext("theme_menu_fire_button"), buttonOptions[1]);
			}
			else{
				fireButton = new element_mainButton(gettext("theme_menu_fire_button"), buttonOptions[1], ThemeTypes.FIRE_THEME_COST);
			}
			fireButton.x = normalButton.x;
			fireButton.y = normalButton.y + normalButton.height + DynamicConstants.BUTTON_SPACING;
			
			backButton = new element_mainButton("Back",  buttonOptions[2]);
			backButton.x = normalButton.x;
			backButton.y = fireButton.y + fireButton.height + DynamicConstants.BUTTON_SPACING;
			
			addButton(normalButton);
			addButton(fireButton);
			addButton(backButton);
			
			buttonSignal.add(handleInteraction);
			
			onScreenElements.push(normalButton, fireButton, backButton);
		}
		
		private function handleInteraction(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
					LOG.createCheckpoint("AudioBrush Theme Selected");
					UserData.getInstance().purchaseTheme(ThemeTypes.NORMAL_THEME);
					SettingsProxy.getInstance().changeTheme(ThemeTypes.NORMAL_THEME);
					cleanButtons();
					break;
				case buttonOptions[1]:
					if(UserData.getInstance().getCredits() >= ThemeTypes.FIRE_THEME_COST){
						LOG.createCheckpoint("Fire Theme Selected");
						UserData.getInstance().purchaseTheme(ThemeTypes.FIRE_THEME);
						SettingsProxy.getInstance().changeTheme(ThemeTypes.FIRE_THEME);
						DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_SETTINGS;
					}
					else if(ProductsData.getInstance().doesUserHaveProduct(ThemeTypes.FIRE_THEME)){
						SettingsProxy.getInstance().changeTheme(ThemeTypes.FIRE_THEME);
						DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_SETTINGS;
					}
					else{
						DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.PURCHASES;
					}
					cleanButtons();
					break;
				case buttonOptions[2]:
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
			
			normalButton = null
				fireButton = null;
				backButton = null;
		}
	}
}