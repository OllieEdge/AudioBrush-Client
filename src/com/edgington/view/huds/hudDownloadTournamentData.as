package com.edgington.view.huds
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.tournaments.TournamentAssetsManager;
	import com.edgington.net.TournamentData;
	import com.edgington.net.events.TournamentEvent;
	import com.edgington.types.DeviceTypes;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_mainButton;
	import com.edgington.view.huds.elements.element_tournamentDownloader;
	
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class hudDownloadTournamentData extends AbstractHud implements IAbstractHud
	{
		
		private var readyToRemoveSignal:Signal;
		
		private var buttonOptions:Vector.<String> = new <String>["CANCEL"];
		
		private var download:element_tournamentDownloader;
		private var cancelButton:element_mainButton;
		
		public function hudDownloadTournamentData(removeSignal:Signal)
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
			TournamentAssetsManager.getInstance().downloadSignal.add(handleDownloadComplete);
		}
		
		public function setupVisuals():void
		{
			download = new element_tournamentDownloader();
			download.x = DynamicConstants.SCREEN_WIDTH*.5 - download.width*.5;
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
				download.y = DynamicConstants.SCREEN_MARGIN;
			}
			else{
				download.y = DynamicConstants.SCREEN_HEIGHT*.5 - download.height*.5;
			}
			
			cancelButton = new element_mainButton(gettext("tournament_cancel_download"), buttonOptions[0]);
			cancelButton = new element_mainButton(gettext("tournament_entry_button_back"), buttonOptions[0]);
			cancelButton.x = download.x;
			cancelButton.y = download.y + download.height + DynamicConstants.BUTTON_SPACING;
			addButton(cancelButton);
			
			buttonSignal.add(handleInteraction);
			
			onScreenElements.push(download, cancelButton);
			
			TournamentAssetsManager.getInstance().downloadAssets(TournamentData.getInstance().currentActiveTournament);
		}
		
		private function handleDownloadComplete(eventType:String, progress:Number):void{
			if(eventType == TournamentEvent.DATA_COMPLETE){
				DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.TOURNAMENT_ENTRY;
				cleanButtons();
			}
		}
		
		private function handleInteraction(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
					TournamentAssetsManager.getInstance().cancelDownload();
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.TOURNAMENT_ENTRY;
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
			TournamentAssetsManager.getInstance().downloadSignal.removeAll();
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			
			download = null;
			cancelButton = null;
		}
	}
}