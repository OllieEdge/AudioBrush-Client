package com.edgington.view.huds.elements
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.GameProxy;
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.util.NumberFormat;
	import com.edgington.util.localisation.gettext;
	import com.edgington.valueobjects.net.HighscoreServerVO;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class element_summaryOverview extends Sprite
	{
		
		private var summary:ui_summaryOverview;
		
		public var share:Boolean = false;
		
		public function element_summaryOverview()
		{
			super();
			
			summary = new ui_summaryOverview();
			
			summary.txt_beatsHit.text = gettext("summary_screen_beats_hit");
			summary.txt_longestStreak.text = gettext("summary_screen_longest_streak");
			summary.txt_additionalBonus.text = gettext("summary_screen_additional_bonus");
			
			if(FacebookManager.getInstance().checkIfUserIsLoggedIn()){
				summary.txt_noRanking.visible = false;
				summary.txt_rank.text =  gettext("summary_screen_ranking_loading");
			}
			else{
				summary.txt_rank.text = gettext("summary_screen_ranking_off");
				summary.txt_noRanking.text = gettext("summary_screen_ranking_facebook_required");
			}
			
			if(GameProxy.INSTANCE.currentTrackDetails.trackTitle == null){
				GameProxy.INSTANCE.currentTrackDetails.trackTitle = "Unknown Track";
			}
			if(GameProxy.INSTANCE.currentTrackDetails.artistName == null){
				GameProxy.INSTANCE.currentTrackDetails.artistName = "Unknown Artist";
			}
			
			summary.txt_artist.text = gettext("summary_screen_artist_name", {artist:GameProxy.INSTANCE.currentTrackDetails.artistName});
			summary.txt_trackTitle.text = GameProxy.INSTANCE.currentTrackDetails.trackTitle;
			
			summary.txt_numBeatsHit.text = NumberFormat.addThreeDigitCommaSeperator(GameProxy.INSTANCE.hitsAllHits) + " / " + NumberFormat.addThreeDigitCommaSeperator(GameProxy.INSTANCE.totalBeats);
			summary.txt_longestBeatStreak.text = NumberFormat.addThreeDigitCommaSeperator(Math.max(GameProxy.INSTANCE.longestBeatsInARow, GameProxy.INSTANCE.longestPerfectsInARow));
			
			summary.txt_totalBonusPoints.text = NumberFormat.addThreeDigitCommaSeperator(GameProxy.INSTANCE.scoreStarPowerBonus + GameProxy.INSTANCE.scorePerfectStreaks);
			
			summary.share_to_timeline.visible = false;
			summary.share_to_timeline.txt_share.text = gettext("summary_screen_share");
			summary.share_to_timeline.tick.addEventListener(MouseEvent.MOUSE_UP, handleTick);
			summary.share_to_timeline.blob.mouseEnabled = false;
			summary.share_to_timeline.blob.mouseChildren = false;
			
			this.scaleX = this.scaleY = DynamicConstants.MESSAGE_SCALE;
			
			this.cacheAsBitmap = true;
			
			this.addChild(summary);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		private function handleTick(e:MouseEvent):void{
			if(summary.share_to_timeline.blob.visible){
				summary.share_to_timeline.blob.visible = false;
				share = false;
			}
			else{
				summary.share_to_timeline.blob.visible = true;
				share = true;
			}
		}
		
		public function tournamentOffline():void{
			summary.share_to_timeline.visible = false;
			summary.txt_rank.text = gettext("summary_screen_tournament_offline");
			summary.txt_noRanking.text = gettext("summary_screen_tournament_offline_description");
		}
		
		public function updateRanking(highscoreInfo:HighscoreServerVO, isTournament:Boolean = false):void{
			summary.txt_noRanking.visible = true;
			if(isTournament){
				summary.txt_rank.text = gettext("summary_screen_ranking_rank", {rank:highscoreInfo.rank});
				//TODO - setup opengraph properly
				if(highscoreInfo.newHighscore){
					share = false;
					summary.share_to_timeline.visible = false;
					summary.txt_noRanking.text = gettext("summary_screen_tournament_new_highscore");
				}
				else{
					share = false;
					summary.share_to_timeline.visible = false;
					summary.txt_noRanking.text = gettext("summary_screen_tournament_no_new_highscore");
				}
			}
			else{
				if(highscoreInfo.requiresSyncWithServer){
					if(FacebookManager.getInstance().checkIfUserIsLoggedIn()){
						share = false;
						summary.share_to_timeline.visible = false;
						summary.txt_rank.text = gettext("summary_screen_ranking_off");
						summary.txt_noRanking.text("summary_screen_ranking_gone_offline");
					}
					else{
						share = false;
						summary.share_to_timeline.visible = false;
						summary.txt_rank.text = gettext("summary_screen_ranking_off");
						summary.txt_noRanking.text = gettext("summary_screen_ranking_facebook_required");
					}
				}
				else{
					summary.txt_rank.text = gettext("summary_screen_ranking_rank", {rank:highscoreInfo.rank});
					if(highscoreInfo.newHighscore){
						share = true;
						summary.share_to_timeline.visible = true;
						summary.txt_noRanking.text = gettext("summary_screen_ranking_new_highscore");
					}
					else{
						share = false;
						summary.share_to_timeline.visible = false;
						summary.txt_noRanking.text = gettext("summary_screen_ranking_no_new_highscore");
					}
				}
			}
		}
		
		public function rankingUnavailableOffline():void{
			summary.txt_noRanking.visible = true;
			summary.txt_rank.text = gettext("summary_screen_ranking_off");
			summary.txt_noRanking.text = gettext("summary_screen_ranking_gone_offline");
		}
		
		public function getViewRankingButtonPoint():Point{
			var pt:Point = new Point();
			pt.y = summary.rankBackground.y + summary.rankBackground.height;
			pt.x = summary.rankBackground.x;
			return pt;
		}
		
		public function getViewScoreDetailsButtonPoint():Point{
			var pt:Point = new Point();
			pt.y = summary.rankBackground.y + summary.rankBackground.height;
			pt.x = summary.additionalBonusBackground.x + summary.additionalBonusBackground.width;
			return pt;
		}

		private function destroy(e:Event):void{
			summary.share_to_timeline.tick.removeEventListener(MouseEvent.MOUSE_UP, handleTick);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			summary = null;
		}
	}
}