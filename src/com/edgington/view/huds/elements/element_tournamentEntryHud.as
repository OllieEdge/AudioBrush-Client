package com.edgington.view.huds.elements
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.net.TournamentData;
	import com.edgington.net.events.TournamentEvent;
	import com.edgington.util.NumberFormat;
	import com.edgington.util.localisation.gettext;
	import com.edgington.valueobjects.TournamentVO;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class element_tournamentEntryHud extends Sprite
	{
		
		private var hud:ui_tournament_entry;
		
		private var tournamentData:TournamentData;
		
		private var tournamentVO:TournamentVO;
		
		public function element_tournamentEntryHud()
		{
			super();
			
			hud = new ui_tournament_entry();
			hud.details.visible = false;
			
			this.scaleX = this.scaleY = DynamicConstants.MESSAGE_SCALE;
			
			hud.picture_artist.cacheAsBitmap = true;
			
			this.addChild(hud);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		public function displayTournamentData():void{
			tournamentData = TournamentData.getInstance();
			tournamentVO = tournamentData.currentActiveTournament;
			
			new element_artwork(hud.picture_artist, tournamentData.currentActiveTournament.ARTWORK_URL);
			
			hud.details.txt_trackTitle.text = tournamentVO.TRACK;
			hud.details.txt_artist.text = tournamentVO.ARTIST;
			hud.details.txt_prizes.text = tournamentVO.PRIZES;
			
			hud.details.txt_prizes_title.text = gettext("tournament_entry_prizes_title");
			hud.details.txt_leader_title.text = gettext("tournament_entry_curren_leader");
			
			hud.details.txt_player_name.text = gettext("tournament_entry_loading_leader");
			hud.details.txt_score.text = gettext("tournament_entry_loading_score");
			
			hud.details.visible = true;
			hud.removeChild(hud.loader);
			
			tournamentData.responceSignal.add(leaderHandle);
			tournamentData.getLeader(tournamentVO.ID);
		}
		
		private function leaderHandle(eventType:String):void{
			switch(eventType){
				case TournamentEvent.TOURNAMENT_LEADER_RECEIVED:
					if(tournamentData.currentLeader.userId != null){
						hud.details.txt_player_name.text = tournamentData.currentLeader.userId.username;
						hud.details.txt_score.text = NumberFormat.addThreeDigitCommaSeperator(int(tournamentData.currentLeader.score));
						new element_profile_picture(hud.details.picture_user, tournamentData.currentLeader.userId.fb_id);
					}
					else{
						hud.details.txt_player_name.text = gettext("tournament_entry_no_leader");
						hud.details.txt_score.text = 0;
					}
					break;
				case TournamentEvent.TOURNAMENT_LEADER_FAILED:
					hud.details.txt_player_name.text = gettext("tournament_entry_error_finding_leader");
					break;
			}
			tournamentData.responceSignal.remove(leaderHandle);
		}
		
		private function destroy(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			if(tournamentData != null){
				tournamentData.responceSignal.remove(leaderHandle);
			}
			
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			
			hud = null;
		}
	}
}