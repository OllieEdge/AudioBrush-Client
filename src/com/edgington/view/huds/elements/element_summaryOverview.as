package com.edgington.view.huds.elements
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.GameProxy;
	import com.edgington.model.facebook.FacebookManager;
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
			
			if(FacebookManager.getInstance().checkIfUserIsLoggedIn()){
				summary.txt_noRanking.visible = false;
				summary.txt_rank.text =  gettext("summary_screen_ranking_loading");
			}
			else{
				summary.txt_rank.text = gettext("summary_screen_ranking_off");
				summary.txt_noRanking.text = gettext("summary_screen_ranking_facebook_required");
			}
			
			if(GameProxy.INSTANCE.starRating != 0){
				summary.star_rating.gotoAndStop(GameProxy.INSTANCE.starRating);
				summary.txt_star_rating.text = gettext("difficulty_star_rating_"+GameProxy.INSTANCE.starRating);
			}
			else{
				summary.star_rating.visible = false;
				summary.txt_star_rating.text = gettext("difficulty_star_rating_0");
			}
			
			summary.txt_percentage.text = gettext("percentage_beats_hit", {percentage:GameProxy.INSTANCE.percentageOfBeatsHit});
			
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
			pt.x = summary.rankBackground.x + summary.rankBackground.width;
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