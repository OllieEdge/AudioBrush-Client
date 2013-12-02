package com.edgington.view.huds
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.SoundConstants;
	import com.edgington.model.SoundManager;
	import com.edgington.model.TournamentTrackPreviewer;
	import com.edgington.net.TournamentData;
	import com.edgington.net.UserData;
	import com.edgington.net.events.TournamentEvent;
	import com.edgington.types.DeviceTypes;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_mainButton;
	import com.edgington.view.huds.elements.element_tournamentEntryHud;
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.osflash.signals.Signal;
	
	public class hudTournamentEntry extends AbstractHud implements IAbstractHud
	{
		
		private var readyToRemoveSignal:Signal;
		
		private var buttonOptions:Vector.<String> = new <String>["BACK", "ENTER", "PLAY"];
		
		private var tournaments:Vector.<element_tournamentEntryHud>;
		private var enterButton:element_mainButton;
		private var playButton:element_mainButton;
		private var backButton:element_mainButton;
		
		private var nextButton:ui_arrow_button;
		private var previousButton:ui_arrow_button;
		
		private var tournamentData:TournamentData;
		
		private var currentSelectedTournamedIndex:int = 0;
		
		private var disableArrows:Boolean = false;
		
		private var tweens:Vector.<TweenMax>;
		
		private var loading:ui_loading;
		
		public function hudTournamentEntry(removeSignal:Signal)
		{
			super();
			
			readyToRemoveSignal = removeSignal;
			tournamentData = TournamentData.getInstance();
			
			tweens = new Vector.<TweenMax>;
			
			addListeners();
			
			setupVisuals();
			
			addElements();
		}
		
		public function addListeners():void
		{
			LOG.createCheckpoint("MENU: Tournament Entry");
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			superRemoveSignal.addOnce(readyForRemoval);
			tournamentData.responceSignal.add(handleTournamentData);
			tournamentData.getCurrentTournamentData();
		}
		
		public function setupVisuals():void
		{
			loading = new ui_loading();
			loading.x = DynamicConstants.SCREEN_WIDTH*.5;
			loading.y = DynamicConstants.SCREEN_HEIGHT*.5;
			
			onScreenElements.push(loading);
		}
		
		private function displayTournamentInformation():void{
			tournaments = new Vector.<element_tournamentEntryHud>;
			
			for(var i:int = 0; i < tournamentData.currentActiveTournaments.length; i++){
				var tournament:element_tournamentEntryHud = new element_tournamentEntryHud(i);
				tournament.x = DynamicConstants.SCREEN_WIDTH*.5 - tournament.width*.5;
				if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
					tournament.y = DynamicConstants.SCREEN_MARGIN;
				}
				else{
					tournament.y = DynamicConstants.SCREEN_HEIGHT*.5 - tournament.height*.5;
				}
				tournament.visible = false;
				tournament.displayTournamentData(i);
				addAdditionalElements(new <Sprite>[tournament]);
				tournaments.push(tournament);
			}
			
			nextButton = new ui_arrow_button();
			nextButton.scaleX = nextButton.scaleY = DynamicConstants.DEVICE_SCALE;
			nextButton.x = tournaments[0].x + tournaments[0].width + DynamicConstants.BUTTON_SPACING + nextButton.width;
			nextButton.y = tournaments[0].y + tournaments[0].height*.5;
			nextButton.visible = (tournamentData.currentActiveTournaments.length > 1);
			
			previousButton = new ui_arrow_button();
			previousButton.scaleX = previousButton.scaleY = DynamicConstants.DEVICE_SCALE;
			previousButton.scaleX = -previousButton.scaleX;
			previousButton.x = tournaments[0].x - (DynamicConstants.BUTTON_SPACING+previousButton.width);
			previousButton.y = tournaments[0].y + tournaments[0].height*.5;
			previousButton.visible = (tournamentData.currentActiveTournaments.length > 1);
			
			nextButton.addEventListener(MouseEvent.MOUSE_UP, handleArrowClick);
			previousButton.addEventListener(MouseEvent.MOUSE_UP, handleArrowClick);
			
			nextButton.addEventListener(MouseEvent.MOUSE_DOWN, handleArrowHighlight);
			previousButton.addEventListener(MouseEvent.MOUSE_DOWN, handleArrowHighlight);
			
			tournaments[currentSelectedTournamedIndex].visible = true;
			
			backButton = new element_mainButton(gettext("tournament_entry_button_back"), buttonOptions[0]);
			backButton.x = tournaments[0].x;
			backButton.y = tournaments[0].y + tournaments[0].height + DynamicConstants.BUTTON_SPACING;
			addButton(backButton);
			
			
			buttonSignal.add(handleInteraction);
			
			addAdditionalElements(new <Sprite>[nextButton, previousButton, backButton]);
			
			if(tournamentData.currentActiveTournaments[currentSelectedTournamedIndex].CACHED){
				playButtonSwitcher(true);
			}
			else{
				enterButtonSwitcher(true);
			}
		}
		
		private function playButtonSwitcher(isOn:Boolean):void{
			if(isOn && playButton == null){
				enterButtonSwitcher(false);
				playButton = new element_mainButton(gettext("tournament_entry_button_play"), buttonOptions[2], tournamentData.currentActiveTournaments[currentSelectedTournamedIndex].COST);
				playButton.x = backButton.x + tournaments[currentSelectedTournamedIndex].width -playButton.width;
				playButton.y = backButton.y;
				
				addButton(playButton);
				
				addAdditionalElements(new <Sprite>[playButton]);
			}
			else if(isOn && playButton != null){
				playButton.changeCost(tournamentData.currentActiveTournaments[currentSelectedTournamedIndex].COST);
			}
			else if(!isOn && playButton != null){
				removeButton(playButton);
				playButton = null;
			}
		}
		
		private function enterButtonSwitcher(isOn:Boolean):void{
			if(isOn && enterButton == null){
				playButtonSwitcher(false);
				enterButton = new element_mainButton(gettext("tournament_entry_button_enter"), buttonOptions[1]);
				enterButton.x = backButton.x + tournaments[currentSelectedTournamedIndex].width -enterButton.width;
				enterButton.y = backButton.y;
				
				addButton(enterButton);
				
				addAdditionalElements(new <Sprite>[enterButton]);
			}
			else if(!isOn && enterButton != null){
				removeButton(enterButton);
				enterButton = null;
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
					tournamentData.currentActiveTournament = tournamentData.currentActiveTournaments[currentSelectedTournamedIndex];
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.TOURNAMENT_DOWNLOAD;
					cleanButtons();
					break;
				case buttonOptions[2]:
					tournamentData.currentActiveTournament = tournamentData.currentActiveTournaments[currentSelectedTournamedIndex];
					
					if(UserData.getInstance().getCredits() < tournamentData.currentActiveTournament.COST){
						DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.PURCHASES;
					}
					else{
						tournamentData.isThisGameATournamentGame = true;
						DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.GAME_LOADING;
					}
					cleanButtons();
					break;
			}
		}
		
		private function handleArrowClick(e:MouseEvent):void{
			e.currentTarget.gotoAndStop(1);
			if(TournamentTrackPreviewer.getInstance().isPlaying){
				TournamentTrackPreviewer.getInstance().stopTrack();
			}
			if(!disableArrows){
				SoundManager.getInstance().loadAndPlaySFX(SoundConstants.SFX_TAB_SELECT, "", 1);
				disableArrows = true;
				if(e.currentTarget == previousButton){
					tweens.push(new TweenMax(tournaments[currentSelectedTournamedIndex], 0.3, {x:DynamicConstants.SCREEN_WIDTH, ease:Quad.easeOut, onComplete:clearAsset, onCompleteParams:[tournaments[currentSelectedTournamedIndex]]}));
					
					tournaments[getPreviousNumberReference()].x = -tournaments[getPreviousNumberReference()].width;
					if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
						tournaments[getPreviousNumberReference()].y = DynamicConstants.SCREEN_MARGIN;
					}
					else{
						tournaments[getPreviousNumberReference()].y = DynamicConstants.SCREEN_HEIGHT*.5 - tournaments[getPreviousNumberReference()].height*.5;	
					}
					
					tournaments[getPreviousNumberReference()].visible = true;
					
					tweens.push(new TweenMax(tournaments[getPreviousNumberReference()], 0.3, {x:DynamicConstants.SCREEN_WIDTH*.5 - tournaments[getPreviousNumberReference()].width*.5, ease:Quad.easeOut, onComplete:decreaseIndex}));
					if(tournamentData.currentActiveTournaments[getPreviousNumberReference()].CACHED){
						playButtonSwitcher(true);
						playButton.changeCost(tournamentData.currentActiveTournaments[getPreviousNumberReference()].COST);
					}
					else{
						enterButtonSwitcher(true);
					}
				}
				else{
					tweens.push(new TweenMax(tournaments[currentSelectedTournamedIndex], 0.3, {x:-tournaments[currentSelectedTournamedIndex].width, ease:Quad.easeOut, onComplete:clearAsset, onCompleteParams:[tournaments[currentSelectedTournamedIndex]]}));
					
					tournaments[getNextNumberReference()].x = DynamicConstants.SCREEN_WIDTH;
					if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
						tournaments[getNextNumberReference()].y = DynamicConstants.SCREEN_MARGIN;
					}
					else{
						tournaments[getNextNumberReference()].y = DynamicConstants.SCREEN_HEIGHT*.5 - tournaments[getNextNumberReference()].height*.5;	
					}
					
					tournaments[getNextNumberReference()].visible = true;
					
					tweens.push(new TweenMax(tournaments[getNextNumberReference()], 0.3, {x:DynamicConstants.SCREEN_WIDTH*.5 - tournaments[getNextNumberReference()].width*.5, ease:Quad.easeOut, onComplete:increaseIndex}));
					if(tournamentData.currentActiveTournaments[getNextNumberReference()].CACHED){
						playButtonSwitcher(true);
						playButton.changeCost(tournamentData.currentActiveTournaments[getNextNumberReference()].COST);
					}
					else{
						enterButtonSwitcher(true);
					}
				}
			}
		}
		private function handleArrowHighlight(e:MouseEvent):void{
			if(!disableArrows){
				e.currentTarget.gotoAndStop(2);
			}
		}
		
		private function clearAsset(clip:element_tournamentEntryHud):void{
			clip.visible = false;
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
		
		private function decreaseIndex():void{
			currentSelectedTournamedIndex--;
			if(currentSelectedTournamedIndex < 0){
				currentSelectedTournamedIndex = tournamentData.currentActiveTournaments.length-1;
			}
			disableArrows = false;
			tweens = new Vector.<TweenMax>;
		}
		private function increaseIndex():void{
			currentSelectedTournamedIndex++;
			if(currentSelectedTournamedIndex > tournamentData.currentActiveTournaments.length-1){
				currentSelectedTournamedIndex = 0;
			}
			disableArrows = false;
			tweens = new Vector.<TweenMax>;
		}
		
		private function getPreviousNumberReference():int{
			if(currentSelectedTournamedIndex == 0){
				return tournamentData.currentActiveTournaments.length-1;
			}
			return currentSelectedTournamedIndex-1;
		}
		
		private function getNextNumberReference():int{
			if(currentSelectedTournamedIndex+1 > tournamentData.currentActiveTournaments.length-1){
				return 0;
			}
			return currentSelectedTournamedIndex+1;
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
			
			tournaments = null;
		}
	}
}