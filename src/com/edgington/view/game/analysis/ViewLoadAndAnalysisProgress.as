package com.edgington.view.game.analysis
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.media.MediaManager;
	import com.edgington.model.audio.AudioMainModel;
	import com.edgington.model.events.AudioEvent;
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.net.TournamentData;
	import com.edgington.types.DeviceTypes;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_mainButton;
	import com.edgington.view.huds.elements.element_mainMessage;
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.SharedObject;
	
	import org.osflash.signals.Signal;
	
	public class ViewLoadAndAnalysisProgress extends AbstractHud implements IAbstractHud
	{
		
		private var progress:ui_LoadAndAnalysisProgress;
		
		private var audioManager:AudioMainModel;
		
		private var readyToRemoveSignal:Signal;
		
		private var progressStepCount:int = -1;
		
		private var didYouKnow:element_mainMessage;
		
		private var loadAnalytics:SharedObject = SharedObject.getLocal("ab_loading");
		
		private var reportMessage:element_mainMessage;
		private var dismissButton:element_mainButton;
		
		private var buttonOptions:Vector.<String> = new <String>["MAIN_MENU"];
		
		public function ViewLoadAndAnalysisProgress(removeSignal:Signal)
		{
			super();
			if(loadAnalytics.data.didYouKnow == null){
				loadAnalytics.data.didYouKnow = 4;
				loadAnalytics.flush();
			}
			loadAnalytics.data.didYouKnow++;
			if(loadAnalytics.data.didYouKnow == 5){
				loadAnalytics.data.didYouKnow = 1;
			}
			loadAnalytics.flush();
			
			readyToRemoveSignal = removeSignal;
			
			if(TournamentData.getInstance().isThisGameATournamentGame){
				AudioMainModel.getInstance().selectTrackToLoad(true);
			}
			else{
				AudioMainModel.getInstance().selectTrackToLoad();
			}
			
			addListeners();
			
			setupVisuals();
			
			addElements();
			
			
		}
		
		public function addListeners():void{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			audioManager = AudioMainModel.getInstance();
			//TODO can be removed when there is a menu at the end of a track
			audioManager.trackStatusSignal.add(trackProgress);
			//audioManager.trackStatusSignal.add(trackProgress);
			superRemoveSignal.addOnce(readyForRemoval);
		}
		
		public function setupVisuals():void{
			progress = new ui_LoadAndAnalysisProgress();
			progress.scaleX = progress.scaleY = DynamicConstants.MESSAGE_SCALE;
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPAD){
				progress.x = DynamicConstants.SCREEN_WIDTH*.5 - progress.width*.5;
				progress.y = DynamicConstants.SCREEN_HEIGHT*.5 - progress.height*.5;
			}
			else{
				progress.x = DynamicConstants.SCREEN_WIDTH*.5 - progress.width*.5;
				progress.y = DynamicConstants.SCREEN_MARGIN;
			}
			
			didYouKnow = new element_mainMessage(gettext("menu_loading_did_you_know_"+loadAnalytics.data.didYouKnow));
			didYouKnow.scaleX = didYouKnow.scaleY = DynamicConstants.MESSAGE_SCALE;
			didYouKnow.x = DynamicConstants.SCREEN_WIDTH*.5 - didYouKnow.width*.5;
			didYouKnow.y = DynamicConstants.SCREEN_HEIGHT - DynamicConstants.SCREEN_MARGIN - didYouKnow.height;
			didYouKnow.visible = false;
			
			progress.txt_analising.text = gettext("menu_loading_section_waiting");
			progress.txt_trackInformation.text = "";
			onScreenElements.push(progress, didYouKnow);
		}
		
		private function trackProgress(type:String, progressPercentage:Number = 0):void{
			switch(type){
				case AudioEvent.TRACK_NEEDS_CONVERSION:
					progress.txt_analising.text = "Converting track...";
					progress.txt_trackInformation.text = MediaManager.INSTANCE.trackData.trackTitle;
					progress.ui_progressbar.bar.scaleX = progressPercentage;
					break;
				case AudioEvent.TRACK_CONVERSION_PROGRESS:
					progress.ui_progressbar.bar.scaleX = progressPercentage/100;
					break;
				case AudioEvent.TRACK_ANALISING:
					if(progressPercentage < 0.2 && progressStepCount == 0){
						if(audioManager.currentTrackDetails.trackTitle != null){
							progress.txt_trackInformation.text = audioManager.currentTrackDetails.trackTitle;
							if(audioManager.currentTrackDetails.artistName != null){
								progress.txt_trackInformation.text += " by " + audioManager.currentTrackDetails.artistName;
							}
						}
						didYouKnow.visible = true;
						progress.txt_analising.text = gettext("menu_loading_section_1_"+Math.ceil(Math.random()*5));
						progressStepCount++;
					}
					else if(progressPercentage >= 0.2 && progressPercentage < 0.3 && progressStepCount == 1){
						FacebookManager.getInstance().requestPostPermissions();
						progress.txt_analising.text = gettext("menu_loading_section_2_"+Math.ceil(Math.random()*5));
						progressStepCount++;
					}
					else if(progressPercentage >= 0.3 && progressPercentage < 0.5 && progressStepCount == 2){
						progress.txt_analising.text = gettext("menu_loading_section_3_"+Math.ceil(Math.random()*5));
						progressStepCount++;
					}
					else if(progressPercentage >= 0.5 && progressPercentage < 0.7 && progressStepCount == 3){
						progress.txt_analising.text = gettext("menu_loading_section_4_"+Math.ceil(Math.random()*5));
						progressStepCount++;
					}
					else if(progressPercentage >= 0.7 && progressPercentage < 0.9 && progressStepCount == 4){
						progress.txt_analising.text = gettext("menu_loading_section_5_"+Math.ceil(Math.random()*5));
						progressStepCount++;
					}
					else if(progressPercentage >  0.9 && progressStepCount == 5){
						progress.txt_analising.text = gettext("menu_loading_section_6_1");
						progressStepCount++;
					}
					progress.ui_progressbar.bar.scaleX = progressPercentage;
					break;
				case AudioEvent.TRACK_IMPORTING:
					if(progressStepCount != 0){
						progress.txt_analising.text = gettext("menu_loading_section_importing");
						progressStepCount++;
					}
					progress.ui_progressbar.bar.scaleX = progressPercentage;
					break;
				case AudioEvent.TRACK_ANALYSIS_COMPLETE:
					audioManager.parser.destroy();
					audioManager.parser = null;
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.GAME_ANALYSIS;
					removeElements();
					break;
				case AudioEvent.TRACK_SELECTION_CANCELED:
					LOG.debug("User has cancel track selection");
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_MAIN;
					removeElements();
					break;
				case AudioEvent.TRACK_ERROR_IMPORTING:
					LOG.fatal("There was an error importing this track");
					displayErrorMessage(gettext("menu_loading_error_unknown"));
					break;
				case AudioEvent.TRACK_ERROR_PROTECTED:
					displayErrorMessage(gettext("menu_loading_error_protected"));
					break;
			}
		}
		
		private function displayErrorMessage(errorMessage:String):void{
			removeSeperateElements(progress);
			removeSeperateElements(didYouKnow);
			reportMessage = new element_mainMessage(errorMessage);
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
				reportMessage.x = DynamicConstants.SCREEN_WIDTH*.5 - reportMessage.width*.5;
				reportMessage.y = DynamicConstants.SCREEN_MARGIN;
			}
			else{
				reportMessage.x = DynamicConstants.SCREEN_WIDTH*.5 - reportMessage.width*.5;
				reportMessage.y = DynamicConstants.SCREEN_HEIGHT*.5 - reportMessage.height*.5;	
			}
			dismissButton = new element_mainButton(gettext("menu_loading_dismiss_button"), buttonOptions[0]);
			dismissButton.x = reportMessage.x + reportMessage.width - dismissButton.width;
			dismissButton.y = reportMessage.y + reportMessage.height + DynamicConstants.BUTTON_SPACING;
			buttonSignal.add(handleInteractions);
			addButton(dismissButton);
			addAdditionalElements(new <Sprite>[reportMessage, dismissButton]);
		}
		
		private function handleInteractions(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
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
			readyToRemoveSignal = null;
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			progress = null;
			audioManager = null;
			didYouKnow = null;
			dismissButton = null;
			reportMessage = null;
		}
	}
}