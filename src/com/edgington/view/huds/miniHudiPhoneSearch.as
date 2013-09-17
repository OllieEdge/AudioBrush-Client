package com.edgington.view.huds
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.SearchProxy;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_mainButton;
	import com.edgington.view.huds.elements.element_searchIphone;
	
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class miniHudiPhoneSearch extends AbstractHud implements IAbstractHud
	{
		private var readyToRemoveSignal:Signal;
		
		private var buttonOptions:Vector.<String> = new <String>["BACK"];
		
		private var backButton:element_mainButton;
		
		private var search:element_searchIphone;
		
		private var searchSignal:Signal;
		
		public function miniHudiPhoneSearch(removeSignal:Signal)
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
			searchSignal = new Signal();
			searchSignal.add(runSearch);
		}
		
		public function setupVisuals():void
		{
			search = new element_searchIphone(searchSignal);
			search.x = DynamicConstants.SCREEN_WIDTH*.5 - search.width *.5;
			search.y = DynamicConstants.SCREEN_MARGIN;
			
			backButton = new element_mainButton(gettext("highscores_search_back_button"), buttonOptions[0]);
			backButton.x = search.x;
			backButton.y = search.y + search.height + DynamicConstants.BUTTON_SPACING;
			
			addButton(backButton);
				
			buttonSignal.add(handleInteraction);
			
			onScreenElements.push(search, backButton);
		}
		
		private function handleInteraction(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.HIGHSCORES_MAIN;
					cleanButtons();
					break;
			}
		}
		
		private function runSearch(searchString:String):void{
			SearchProxy.getInstance().currentSearch = searchString;
			SearchProxy.getInstance().isSearch = true;
			DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.HIGHSCORES_MAIN;
			cleanButtons();
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
			search = null;
		}
	}
}