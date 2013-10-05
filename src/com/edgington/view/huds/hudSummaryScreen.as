package com.edgington.view.huds
{
	import com.edgington.constants.AchievementConstants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.GameProxy;
	import com.edgington.model.SettingsProxy;
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.model.facebook.opengraph.actions.OpenGraphAchieveAction;
	import com.edgington.model.facebook.opengraph.actions.OpenGraphNewHighscoreAction;
	import com.edgington.model.facebook.opengraph.actions.OpenGraphPlayAction;
	import com.edgington.model.facebook.opengraph.images.OpenGraphImages;
	import com.edgington.model.facebook.opengraph.objects.OpenGraphHighscoreObject;
	import com.edgington.model.facebook.opengraph.objects.OpenGraphRankObject;
	import com.edgington.model.facebook.opengraph.objects.OpenGraphTrackObject;
	import com.edgington.net.AchievementData;
	import com.edgington.net.HighscoresPostData;
	import com.edgington.net.TournamentPostData;
	import com.edgington.net.UserData;
	import com.edgington.net.events.HighscoreEvent;
	import com.edgington.net.events.TournamentEvent;
	import com.edgington.types.DeviceTypes;
	import com.edgington.types.GameStateTypes;
	import com.edgington.types.HandDirectionType;
	import com.edgington.util.NumberFormat;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.valueobjects.net.HighscoreServerVO;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_mainButton;
	import com.edgington.view.huds.elements.element_mainMiniButton;
	import com.edgington.view.huds.elements.element_summaryOverview;
	import com.edgington.view.huds.elements.element_summaryTitle;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import org.osflash.signals.Signal;
	
	public class hudSummaryScreen extends AbstractHud implements IAbstractHud
	{
		
		private var score:element_summaryTitle;
		private var summaryOverview:element_summaryOverview;
		
		private var dismissButton:element_mainButton;
		private var restartButton:element_mainButton;
		
		private var viewHighscoresButton:element_mainMiniButton;
		private var viewScoreDetailsButton:element_mainMiniButton;
		
		private var buttonOptions:Vector.<String> = new <String>["MAIN_MENU", "DETAILS", "HIGHSCORES"];
		
		private var readyToRemoveSignal:Signal;
		
		public function hudSummaryScreen(removeSignal:Signal)
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
			score = new element_summaryTitle();
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
				score.x = DynamicConstants.SCREEN_WIDTH*.5 - score.width*.5;
				score.y = DynamicConstants.SCREEN_MARGIN*.5;
			}
			else{
				score.x = DynamicConstants.SCREEN_WIDTH*.5 - score.width*.5;
				score.y = DynamicConstants.SCREEN_HEIGHT*.4 - score.height;
			}
			
			summaryOverview = new element_summaryOverview();
			summaryOverview.x = DynamicConstants.SCREEN_WIDTH*.5 - score.width*.5;
			summaryOverview.y = score.y + score.height + DynamicConstants.BUTTON_SPACING;
			
			dismissButton = new element_mainButton("OK", buttonOptions[0]);
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
				dismissButton.x = summaryOverview.x + summaryOverview.width - dismissButton.width;
				dismissButton.y = summaryOverview.y + summaryOverview.height + DynamicConstants.BUTTON_SPACING;
			}
			else{
				dismissButton.x = summaryOverview.x + summaryOverview.width - dismissButton.width;
				dismissButton.y = summaryOverview.y + summaryOverview.height + DynamicConstants.BUTTON_SPACING;
			}
			
			var pt:Point =  summaryOverview.getViewRankingButtonPoint();
			pt = summaryOverview.localToGlobal(pt);
			
			if(FacebookManager.getInstance().checkIfUserIsLoggedIn()){
				viewHighscoresButton = new element_mainMiniButton(gettext("summary_screen_view_ranking"), buttonOptions[2]);
				viewHighscoresButton.x = pt.x;
				viewHighscoresButton.y = pt.y+DynamicConstants.SCREEN_MARGIN*0.1;
				addButton(viewHighscoresButton);
			}
			
			pt = summaryOverview.getViewScoreDetailsButtonPoint();
			pt = summaryOverview.localToGlobal(pt);
			
			viewScoreDetailsButton = new element_mainMiniButton(gettext("summary_screen_detailed_score"), buttonOptions[1]);
			viewScoreDetailsButton.x = pt.x - viewScoreDetailsButton.width;
			viewScoreDetailsButton.y = pt.y+DynamicConstants.SCREEN_MARGIN*0.1;
			
			
			restartButton = new element_mainButton("Replay", buttonOptions[0]);
			restartButton.x = summaryOverview.x;
			restartButton.y = dismissButton.y;
			
			
			addButton(viewScoreDetailsButton);
			
			addButton(dismissButton);
			addButton(restartButton);
			
			buttonSignal.add(handleInteraction);
			
			onScreenElements.push(score, summaryOverview, viewScoreDetailsButton, restartButton, dismissButton);
			if(viewHighscoresButton){
				onScreenElements.push(viewHighscoresButton);
			}
			
			if(GameProxy.INSTANCE.highscoreVO == null){
				if(GameProxy.INSTANCE.isTournament){
					TournamentPostData.getInstance().tournamentStatusSignal.add(highscoreInformationReceived);
					TournamentPostData.getInstance().postHighscore();
				}
				else{
					HighscoresPostData.getInstance().highscoreDataSignal.add(highscoreInformationReceived);
					HighscoresPostData.getInstance().postHighscore();
				}
			}
			else{
				summaryOverview.updateRanking(GameProxy.INSTANCE.highscoreVO, GameProxy.INSTANCE.isTournament);
			}
		}
		
		private function highscoreInformationReceived(eventType:String = "", highscoreVO:HighscoreServerVO = null):void{
			
			switch(eventType){
				case "":
					
					break;
				case HighscoreEvent.NEW_HIGHSCORE:
						GameProxy.INSTANCE.highscoreVO = highscoreVO;
						summaryOverview.updateRanking(highscoreVO);
					break;
				case HighscoreEvent.NO_NEW_HIGHSCORE:
						GameProxy.INSTANCE.highscoreVO = highscoreVO;
						summaryOverview.updateRanking(highscoreVO);
					break;
				case TournamentEvent.NEW_HIGHSCORE:
						GameProxy.INSTANCE.highscoreVO = highscoreVO;
						summaryOverview.updateRanking(highscoreVO, true);
					break;
				case TournamentEvent.NO_NEW_HIGHSCORE:
						GameProxy.INSTANCE.highscoreVO = highscoreVO;
						summaryOverview.updateRanking(highscoreVO, true);
					break;
				case TournamentEvent.SCORE_POST_FAILED:
						summaryOverview.tournamentOffline();
					break;
			}
			checkAchievements();
		}
		
		private function handleInteraction(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_MAIN;
					cleanButtons();
					break;
				case buttonOptions[1]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.SUMMARY_DETAILS;
					cleanButtons();
					break;
				case buttonOptions[2]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.SUMMARY_HIGHSCORES;
					cleanButtons();
					break;
			}
		}
		
		public function readyForRemoval():void
		{
			super.destroy();
			readyToRemoveSignal.dispatch();
		}
		
		private function checkAchievements():void{
			
			//I'm in!
			if(!AchievementConstants.ach_22 && GameProxy.INSTANCE.isTournament){
				AchievementData.UnlockAchievement(22);
			}
			//Hendrix's Prophecy
			if(!AchievementConstants.ach_19 && SettingsProxy.getInstance().handSelection == HandDirectionType.LEFT_HAND){
				AchievementData.UnlockAchievement(19);
			}
			//5 fingers
			if(!AchievementConstants.ach_4 && GameProxy.INSTANCE.starRating >= 5 && GameProxy.INSTANCE.difficulty == 1){
				AchievementData.UnlockAchievement(4);
			}
			//Perfect!
			if(!AchievementConstants.ach_9 && GameProxy.INSTANCE.starRating >= 6){
				AchievementData.UnlockAchievement(9);
			}
			//100 Streak
			if(!AchievementConstants.ach_12 && GameProxy.INSTANCE.longestBeatsInARow >= 100){
				AchievementData.UnlockAchievement(12);
			}
			//500 Streak
			if(!AchievementConstants.ach_13 && GameProxy.INSTANCE.longestBeatsInARow >= 500){
				AchievementData.UnlockAchievement(13);
			}
			//100 Perfect Streak
			if(!AchievementConstants.ach_14 && GameProxy.INSTANCE.longestPerfectsInARow >= 100){
				AchievementData.UnlockAchievement(14);
			}
			
			//IF NORMAL OR HIGHER
			if(GameProxy.INSTANCE.difficulty > 1){
				
				//Starry Eyed
				if(!AchievementConstants.ach_20){
					var ach20Progress:int  = AchievementData.getInstance().userAchievements[19].progress;
					ach20Progress += 10;
					AchievementData.getInstance().updateAchievement(20, ach20Progress);
				}
				
				//500k club
				if(!AchievementConstants.ach_1 && GameProxy.INSTANCE.score > 500000){
					AchievementData.UnlockAchievement(1);
				}
				//2million
				if(!AchievementConstants.ach_3 && GameProxy.INSTANCE.score > 2000000){
					AchievementData.UnlockAchievement(3);
				}
				//5 toes
				if(!AchievementConstants.ach_5 && GameProxy.INSTANCE.starRating >= 5 && GameProxy.INSTANCE.difficulty == 2){
					AchievementData.UnlockAchievement(5);
				}
				//NINJA!
				if(!AchievementConstants.ach_10 && GameProxy.INSTANCE.starRating >= 7){
					AchievementData.UnlockAchievement(10);
				}
				//Leonardo da Vinci
				if(!AchievementConstants.ach_11 && GameProxy.INSTANCE.starRating >= 8){
					AchievementData.UnlockAchievement(11);
				}				
				
				//IF HARD OR HIGHER
				if(GameProxy.INSTANCE.difficulty > 2){
					//1mill Groupie
					if(!AchievementConstants.ach_2 && GameProxy.INSTANCE.score > 1000000){
						AchievementData.UnlockAchievement(2);
					}
					//5 senses
					if(!AchievementConstants.ach_6 && GameProxy.INSTANCE.starRating >= 5 && GameProxy.INSTANCE.difficulty == 3){
						AchievementData.UnlockAchievement(6);
					}
					
					//IF EXPERT OR HIGHER
					if(GameProxy.INSTANCE.difficulty > 3){
						//5 oceans
						if(!AchievementConstants.ach_7 && GameProxy.INSTANCE.starRating >= 5 && GameProxy.INSTANCE.difficulty == 4){
							AchievementData.UnlockAchievement(7);
						}
						
						//IF INSANE OR HIGHER
						if(GameProxy.INSTANCE.difficulty > 4){
							//5 hundred miles
							if(!AchievementConstants.ach_8 && GameProxy.INSTANCE.starRating >= 5 && GameProxy.INSTANCE.difficulty == 5){
								AchievementData.UnlockAchievement(8);
							}
						}
					}
				}
				
			}
		}
		
		private function destroy(e:Event):void{
			HighscoresPostData.getInstance().highscoreDataSignal.removeAll();
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			if(DynamicConstants.CURRENT_GAME_STATE == GameStateTypes.MENU_MAIN){
				if(FacebookManager.getInstance().checkIfUserIsLoggedIn()){
					var highscoreVO:HighscoreServerVO = GameProxy.INSTANCE.highscoreVO;
					if(highscoreVO.rank <= 10 && highscoreVO.newHighscore){
						if(highscoreVO.rank == 1){
							var openGraphRank1Object:OpenGraphRankObject = new OpenGraphRankObject(gettext("opengraph_rank_1_title", {artist:GameProxy.INSTANCE.currentTrackDetails.artistName}), gettext("opengraph_rank_1_description", {track:GameProxy.INSTANCE.currentTrackDetails.trackTitle, artist:GameProxy.INSTANCE.currentTrackDetails.artistName}), OpenGraphImages.IMAGE_URL_RANK_1);
							var openGraphAchieveRank1Action:OpenGraphAchieveAction = new OpenGraphAchieveAction(openGraphRank1Object, summaryOverview.share);	
						}
						else if(highscoreVO.rank == 2){
							var openGraphRank2Object:OpenGraphRankObject = new OpenGraphRankObject(gettext("opengraph_rank_2_title", {artist:GameProxy.INSTANCE.currentTrackDetails.artistName}), gettext("opengraph_rank_2_description", {track:GameProxy.INSTANCE.currentTrackDetails.trackTitle, artist:GameProxy.INSTANCE.currentTrackDetails.artistName}), OpenGraphImages.IMAGE_URL_RANK_2);
							var openGraphAchieveRank2Action:OpenGraphAchieveAction = new OpenGraphAchieveAction(openGraphRank2Object, summaryOverview.share);	
						}
						else if(highscoreVO.rank == 3){
							var openGraphRank3Object:OpenGraphRankObject = new OpenGraphRankObject(gettext("opengraph_rank_3_title", {artist:GameProxy.INSTANCE.currentTrackDetails.artistName}), gettext("opengraph_rank_3_description", {track:GameProxy.INSTANCE.currentTrackDetails.trackTitle, artist:GameProxy.INSTANCE.currentTrackDetails.artistName}), OpenGraphImages.IMAGE_URL_RANK_3);
							var openGraphAchieveRank3Action:OpenGraphAchieveAction = new OpenGraphAchieveAction(openGraphRank3Object, summaryOverview.share);	
						}
						else{
							var openGraphRank10Object:OpenGraphRankObject = new OpenGraphRankObject(gettext("opengraph_rank_10_title", {artist:GameProxy.INSTANCE.currentTrackDetails.artistName}), gettext("opengraph_rank_10_description", {rank:highscoreVO.rank, track:GameProxy.INSTANCE.currentTrackDetails.trackTitle, artist:GameProxy.INSTANCE.currentTrackDetails.artistName}), OpenGraphImages.IMAGE_URL_RANK_TOP_10);
							var openGraphAchieveRank10Action:OpenGraphAchieveAction = new OpenGraphAchieveAction(openGraphRank10Object, summaryOverview.share);	
						}
					}
					if(highscoreVO.newHighscore){
						var openGraphHighscoreObject:OpenGraphHighscoreObject = new OpenGraphHighscoreObject(gettext("opengraph_new_highscore_title", {artist:GameProxy.INSTANCE.currentTrackDetails.artistName}), gettext("opengraph_new_highscore_description", {score:NumberFormat.addThreeDigitCommaSeperator(highscoreVO.score), track:GameProxy.INSTANCE.currentTrackDetails.trackTitle, artist:GameProxy.INSTANCE.currentTrackDetails.artistName}), OpenGraphImages["IMAGE_URL_HIGHSCORE_"+Math.ceil(Math.random()*6)]);
						var openGraphHighscoreAction:OpenGraphNewHighscoreAction = new OpenGraphNewHighscoreAction(openGraphHighscoreObject, summaryOverview.share);	
					}
					else{
						var openGraphPlayObject:OpenGraphTrackObject = new OpenGraphTrackObject(gettext("opengraph_new_track_played_title", {track:GameProxy.INSTANCE.currentTrackDetails.trackTitle}), gettext("opengraph_new_track_played_description", {score:NumberFormat.addThreeDigitCommaSeperator(GameProxy.INSTANCE.score), track:GameProxy.INSTANCE.currentTrackDetails.trackTitle, artist:GameProxy.INSTANCE.currentTrackDetails.artistName}), OpenGraphImages["IMAGE_URL_PLAY_TRACK_"+Math.ceil(Math.random()*6)]);
						var openGraphPlayAction:OpenGraphPlayAction = new OpenGraphPlayAction(openGraphPlayObject, false);
					}
				}
				UserData.getInstance().getUser();
				GameProxy.deleteInstance();	
			}
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			LOG.createCheckpoint("Track Played");
			viewHighscoresButton = null;
			viewScoreDetailsButton = null;
			dismissButton = null;
			restartButton = null;
			score = null;
			summaryOverview = null;
		}
	}
}