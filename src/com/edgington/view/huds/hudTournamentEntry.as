package com.edgington.view.huds
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.net.TournamentData;
	import com.edgington.net.events.TournamentEvent;
	import com.edgington.types.DeviceTypes;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_mainButton;
	import com.edgington.view.huds.elements.element_tournamentEntryHud;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class hudTournamentEntry extends AbstractHud implements IAbstractHud
	{
		
		private var readyToRemoveSignal:Signal;
		
		private var buttonOptions:Vector.<String> = new <String>["BACK", "ENTER", "PLAY"];
		
		private var tournament:element_tournamentEntryHud;
		private var enterButton:element_mainButton;
		private var backButton:element_mainButton;
		
		private var tournamentData:TournamentData;
		
		public function hudTournamentEntry(removeSignal:Signal)
		{
			super();
			
			readyToRemoveSignal = removeSignal;
			tournamentData = TournamentData.getInstance();
			
			addListeners();
			
			setupVisuals();
			
			addElements();
		}
		
		public function addListeners():void
		{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			superRemoveSignal.addOnce(readyForRemoval);
			tournamentData.responceSignal.add(handleTournamentData);
		}
		
		public function setupVisuals():void
		{
			tournament = new element_tournamentEntryHud();
			tournament.x = DynamicConstants.SCREEN_WIDTH*.5 - tournament.width*.5;
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
				tournament.y = DynamicConstants.SCREEN_MARGIN;
			}
			else{
				tournament.y = DynamicConstants.SCREEN_HEIGHT*.5 - tournament.height*.5;
			}
			tournamentData.getCurrentTournamentData();
			
			onScreenElements.push(tournament);
		}
		
		private function displayTournamentInformation():void{
			if(tournamentData.currentTournamentDataDownloaded){
				tournament.displayTournamentData();
				enterButton = new element_mainButton(gettext("tournament_entry_button_play"), buttonOptions[2], tournamentData.currentActiveTournament.COST);
				enterButton.x = tournament.x + tournament.width - enterButton.width;
				enterButton.y = tournament.y + tournament.height + DynamicConstants.BUTTON_SPACING;
				addButton(enterButton);
				
				backButton = new element_mainButton(gettext("tournament_entry_button_back"), buttonOptions[0]);
				backButton.x = tournament.x;
				backButton.y = tournament.y + tournament.height + DynamicConstants.BUTTON_SPACING;
				addButton(backButton);
				
				buttonSignal.add(handleInteraction);
				
				addAdditionalElements(new <Sprite>[enterButton, backButton]);
			}
			else{
				tournament.displayTournamentData();
				enterButton = new element_mainButton(gettext("tournament_entry_button_enter"), buttonOptions[1]);
				enterButton.x = tournament.x + tournament.width - enterButton.width;
				enterButton.y = tournament.y + tournament.height + DynamicConstants.BUTTON_SPACING;
				addButton(enterButton);
				
				backButton = new element_mainButton(gettext("tournament_entry_button_back"), buttonOptions[0]);
				backButton.x = tournament.x;
				backButton.y = tournament.y + tournament.height + DynamicConstants.BUTTON_SPACING;
				addButton(backButton);
				
				buttonSignal.add(handleInteraction);
				
				addAdditionalElements(new <Sprite>[enterButton, backButton]);
			}
		}
		
		private function handleInteraction(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
					tournamentData.isThisGameATournamentGame = false;
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_MAIN;
					cleanButtons();
					break;
				case buttonOptions[1]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.TOURNAMENT_DOWNLOAD;
					cleanButtons();
					break;
				case buttonOptions[2]:
					tournamentData.isThisGameATournamentGame = true;
					LOG.createCheckpoint("Tournament Played");
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.GAME_LOADING;
					cleanButtons();
					break;
			}
		}
		
		private function handleTournamentData(eventType:String):void{
			switch(eventType){
				case TournamentEvent.TOURNAMENT_DATA_FAILED:
					
					break;
				case TournamentEvent.TOURNAMENT_DATA_RECEIVED:
					displayTournamentInformation();
					break;
			}
		}
		
		public function readyForRemoval():void
		{
			super.destroy();
			readyToRemoveSignal.dispatch();
		}
		
		private function destroy(e:Event):void{
			tournamentData.responceSignal.removeAll();
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			
			tournament = null;
		}
	}
}