package com.edgington.view.huds
{
	import com.edgington.NativeMediaManager.NativeMediaVO;
	import com.edgington.constants.Constants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.GameProxy;
	import com.edgington.net.HighscoresGetData;
	import com.edgington.net.events.HighscoreEvent;
	import com.edgington.types.DeviceTypes;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.TextFieldManager;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_mainButton;
	import com.edgington.view.huds.elements.element_profile_picture;
	import com.edgington.view.huds.elements.element_tabContainer;
	import com.edgington.view.huds.events.TabContainerEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import org.osflash.signals.Signal;
	
	public class miniHudSocialHighscores extends AbstractHud implements IAbstractHud
	{
		
		private var readyToRemoveSignal:Signal;
		
		private var tabChangedSignal:Signal;
		
		private var tabOptions:Vector.<String> = new <String>["FRIEND_HIGHSCORES", "GLOBAL_HIGHSCORES"];
		private var tabs:Vector.<String>;
		private var tabDescriptions:Vector.<String>;
		
		private var buttonOptions:Vector.<String> = new <String>["BACK"];
		
		private var backButton:element_mainButton;
		
		private var tabContainer:element_tabContainer;
		
		private var loading:ui_loading;
		
		private var trackDetails:NativeMediaVO;
		
		private var highscoresData:HighscoresGetData;
		private var highscores:Array;
		private var highscoresFriends:Array;
		
		private var currentTab:int = 0;
		
		private var highscoreListings:Vector.<Sprite>;
		
		private var amountOfListings:int = 10;
		
		public function miniHudSocialHighscores(removeSignal:Signal)
		{
			super();
			
			this.trackDetails = GameProxy.INSTANCE.currentTrackDetails;
			
			highscoresData = new HighscoresGetData();
			
			readyToRemoveSignal = removeSignal;
			
			addListeners();
			
			setupVisuals();
			
			addElements();
		}
		
		public function addListeners():void
		{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			superRemoveSignal.addOnce(readyForRemoval);
			highscoresData.responceSignal.add(highscoresHandler);
			tabChangedSignal = new Signal();
			tabChangedSignal.add(tabChanged);
		}
		
		public function setupVisuals():void
		{
			tabs = new Vector.<String>;
			tabs.push(gettext("highscores_tab_global"), gettext("highscores_tab_friends"));
			tabDescriptions = new Vector.<String>;
			tabDescriptions.push(gettext("highscores_tab_global_description", {topnumber:amountOfListings, track:GameProxy.INSTANCE.currentTrackDetails.trackTitle, artist:GameProxy.INSTANCE.currentTrackDetails.artistName}), gettext("highscores_tab_friends_description", {track:GameProxy.INSTANCE.currentTrackDetails.trackTitle, artist:GameProxy.INSTANCE.currentTrackDetails.artistName}));
			
			loading = new ui_loading();
			tabContainer = new element_tabContainer(tabs, tabChangedSignal, tabDescriptions);
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
				tabContainer.x = DynamicConstants.SCREEN_WIDTH*.5 - tabContainer.width*.5;
				tabContainer.y = DynamicConstants.SCREEN_MARGIN;
			}
			else{
				tabContainer.x = DynamicConstants.SCREEN_WIDTH*.5 - tabContainer.width*.5;
				tabContainer.y = DynamicConstants.SCREEN_MARGIN;
			}
			loading.scaleX = loading.scaleY = DynamicConstants.BUTTON_MINI_SCALE;
			loading.x = tabContainer.x + tabContainer.width*.5;
			loading.y = tabContainer.y + tabContainer.height*.5;
			
			backButton = new element_mainButton("Back", buttonOptions[0]);
			backButton.x = tabContainer.x + tabContainer.width - backButton.width;
			backButton.y = tabContainer.y + tabContainer.height + DynamicConstants.BUTTON_SPACING;
			
			addButton(backButton);
			
			buttonSignal.add(handleInteraction)
				
			onScreenElements.push(tabContainer, backButton, loading);
			
			highscoresData.getTopX(amountOfListings, trackDetails, 0);
		}
		
		private function handleInteraction(buttonOption):void{
			switch(buttonOption){
				case buttonOptions[0]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.SUMMARY_MENU;
					cleanButtons();
					break;
			}
		}
		
		private function tabChanged(eventType:String, tabLabel:String):void{
			switch(eventType){
				case TabContainerEvent.TAB_CHANGED:
					if(highscoreListings != null){
						for(var l:int = 0; l < highscoreListings.length; l++){
							removeSeperateElements(highscoreListings[l]);
							highscoreListings[l] = null;
						}
						addAdditionalElements(new <Sprite>[loading]);
					}
					switch(tabLabel)
					{
						case tabs[0]:
							currentTab = 0;
							if(highscores == null){
								highscoresData.getTopX(amountOfListings, trackDetails, 0);
							}
							else{
								addGlobalHighscores();
							}
							break;
						case tabs[1]:
							currentTab = 1;
							if(highscoresFriends == null){
								highscoresData.getFriendsScores(amountOfListings, trackDetails, 0);
							}
							else{
								addFriendsHighscores();
							}
							break;
					}
					break;
			}
			
		}
		
		private function addGlobalHighscores():void{
			
			highscoreListings = new Vector.<Sprite>;
			
			if(highscores.length > 0){
				for(var i:int = 0; i < highscores.length; i++){
					var clip:Sprite = new Sprite();
					if(i%2 == 0){
						var listing:ui_listItem = new ui_listItem();
						listing.height = 50;
						listing.width = tabContainer.width - DynamicConstants.BUTTON_SPACING*2;
						clip.addChild(listing);
					}
					
					var profilePicture:element_profile_picture = new element_profile_picture(null, highscores[i].facebookID);
					profilePicture.width = 44;
					profilePicture.height = 44;
					profilePicture.x = 3;
					profilePicture.y = 3;
					clip.addChild(profilePicture);
					
					var txtFieldRank:TextField = TextFieldManager.createTextField(highscores[i].rank, FONT_audiobrush_content, Constants.DARK_FONT_COLOR, 14, false, TextFieldAutoSize.LEFT);
					var txtFieldName:TextField = TextFieldManager.createTextField(highscores[i].name, FONT_audiobrush_content, Constants.DARK_FONT_COLOR, 14, false, TextFieldAutoSize.LEFT);
					var txtFieldScore:TextField = TextFieldManager.createTextField(highscores[i].score, FONT_audiobrush_content, Constants.DARK_FONT_COLOR, 14, false, TextFieldAutoSize.RIGHT);
					
					txtFieldRank.height = 50;
					txtFieldRank.x = DynamicConstants.BUTTON_SPACING;
					txtFieldRank.y += Math.round((txtFieldRank.height - txtFieldRank.textHeight));
					
					txtFieldName.height = 50;
					txtFieldName.x = DynamicConstants.BUTTON_SPACING*3;
					txtFieldName.y += Math.round((txtFieldName.height - txtFieldName.textHeight));
					
					txtFieldScore.height = 50;
					txtFieldScore.x = (tabContainer.width - DynamicConstants.BUTTON_SPACING*2) - txtFieldScore.textWidth-DynamicConstants.BUTTON_SPACING;
					txtFieldScore.y += Math.round((txtFieldScore.height - txtFieldScore.textHeight));
					
					clip.addChild(txtFieldRank);
					clip.addChild(txtFieldName);
					clip.addChild(txtFieldScore);
					
					clip.cacheAsBitmap = true;
					clip.x = tabContainer.x + DynamicConstants.BUTTON_SPACING;
					clip.y = tabContainer.y + (48*DynamicConstants.BUTTON_SCALE) + 24 + DynamicConstants.BUTTON_SPACING + (i*50);
					highscoreListings.push(clip);
				}
			}
			else{
				var noScoresClip:Sprite = new Sprite();
				var txtNoScores:TextField = TextFieldManager.createTextField(gettext("highscores_no_scores_available_global"), FONT_audiobrush_content_bold, Constants.DARK_FONT_COLOR, 14, false, TextFieldAutoSize.CENTER);
				txtNoScores.height = 30;
				txtNoScores.x = tabContainer.x + tabContainer.width*.5 - txtNoScores.textWidth*.5;
				txtNoScores.y = tabContainer.height*.5+tabContainer.y;
				noScoresClip.addChild(txtNoScores);
				noScoresClip.cacheAsBitmap = true;
				highscoreListings.push(noScoresClip);
			}
			addAdditionalElements(highscoreListings);
			removeSeperateElements(loading);
		}
		
		private function addFriendsHighscores():void{
			
			highscoreListings = new Vector.<Sprite>;
			
			if(highscoresFriends.length > 0){
				for(var i:int = 0; i < highscoresFriends.length; i++){
					var clip:Sprite = new Sprite();
					if(i%2 == 0){
						var listing:ui_listItem = new ui_listItem();
						listing.height = 50;
						listing.width = tabContainer.width - DynamicConstants.BUTTON_SPACING*2;
						clip.addChild(listing);
					}
					
					var profilePicture:element_profile_picture = new element_profile_picture(null, highscores[i].facebookID);
					profilePicture.width = 44;
					profilePicture.height = 44;
					profilePicture.x = 3;
					profilePicture.y = 3;
					clip.addChild(profilePicture);
					
					var txtFieldRank:TextField = TextFieldManager.createTextField(highscoresFriends[i].rank, FONT_audiobrush_content, Constants.DARK_FONT_COLOR, 14, false, TextFieldAutoSize.LEFT);
					var txtFieldName:TextField = TextFieldManager.createTextField(highscoresFriends[i].name, FONT_audiobrush_content, Constants.DARK_FONT_COLOR, 14, false, TextFieldAutoSize.LEFT);
					var txtFieldScore:TextField = TextFieldManager.createTextField(highscoresFriends[i].score, FONT_audiobrush_content, Constants.DARK_FONT_COLOR, 14, false, TextFieldAutoSize.RIGHT);
					
					txtFieldRank.height = 50;
					txtFieldRank.x = DynamicConstants.BUTTON_SPACING;
					txtFieldRank.y += Math.round((txtFieldRank.height - txtFieldRank.textHeight));
					
					txtFieldName.height = 50;
					txtFieldName.x = DynamicConstants.BUTTON_SPACING*3;
					txtFieldName.y += Math.round((txtFieldName.height - txtFieldName.textHeight));
					
					txtFieldScore.height = 50;
					txtFieldScore.x = (tabContainer.width - DynamicConstants.BUTTON_SPACING*2) - txtFieldScore.textWidth-DynamicConstants.BUTTON_SPACING;
					txtFieldScore.y += Math.round((txtFieldScore.height - txtFieldScore.textHeight));
					
					clip.addChild(txtFieldRank);
					clip.addChild(txtFieldName);
					clip.addChild(txtFieldScore);
					
					clip.cacheAsBitmap = true;
					clip.x = tabContainer.x + DynamicConstants.BUTTON_SPACING;
					clip.y = tabContainer.y + (48*DynamicConstants.BUTTON_SCALE) + DynamicConstants.BUTTON_SPACING + (i*50);
					highscoreListings.push(clip);
				}
			}
			else{
				var noScoresClip:Sprite = new Sprite();
				var txtNoScores:TextField = TextFieldManager.createTextField(gettext("highscores_no_scores_available_global"), FONT_audiobrush_content_bold, Constants.DARK_FONT_COLOR, 14, false, TextFieldAutoSize.CENTER);
				txtNoScores.height = 30;
				txtNoScores.x = tabContainer.x + tabContainer.width*.5 - txtNoScores.textWidth*.5;
				txtNoScores.y = tabContainer.height*.5+tabContainer.y;
				noScoresClip.addChild(txtNoScores);
				noScoresClip.cacheAsBitmap = true;
				highscoreListings.push(noScoresClip);
			}
			addAdditionalElements(highscoreListings);
			removeSeperateElements(loading);
		}
		
		private function displayOffline():void{
			highscoreListings = new Vector.<Sprite>;
			var noScoresClip:Sprite = new Sprite();
			var txtNoScores:TextField = TextFieldManager.createTextField(gettext("highscores_no_scores_available_global"), FONT_audiobrush_content_bold, Constants.DARK_FONT_COLOR, 14, false, TextFieldAutoSize.CENTER);
			txtNoScores.height = 30;
			txtNoScores.x = tabContainer.x + tabContainer.width*.5 - txtNoScores.textWidth*.5;
			txtNoScores.y = tabContainer.height*.5+tabContainer.y;
			noScoresClip.addChild(txtNoScores);
			noScoresClip.cacheAsBitmap = true;
			highscoreListings.push(noScoresClip);
			addAdditionalElements(highscoreListings);
			removeSeperateElements(loading);
		}
		
		public function readyForRemoval():void
		{
			super.destroy();
			readyToRemoveSignal.dispatch();
		}
		
		private function highscoresHandler(eventType:String, highscoresList:Array = null):void{
			switch(eventType){
				case HighscoreEvent.HIGHSCORES_FAILED:
						displayOffline();
					break;
				case HighscoreEvent.TOP_X_RECEVIED:
						highscores = highscoresList;
						if(currentTab == 0){
							addGlobalHighscores();
						}
					break;
				case HighscoreEvent.NO_FRIENDS_WITH_HIGHSCORES:
						displayOffline();
					break;
				case HighscoreEvent.FRIEND_HIGHSCORES_RECEIVED:
						highscoresFriends = highscoresList;
						if(currentTab == 1){
							addFriendsHighscores();
						}
					break;
			}
		}
		
		private function destroy(e:Event):void{
			LOG.createCheckpoint("Highscores Viewed");
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			tabChangedSignal.removeAll();
			tabChangedSignal = null;
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			highscoresData.destroy();
			highscoresData = null;
			
			loading = null;
			tabContainer = null;
			backButton = null;
		}
	}
}