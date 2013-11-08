package com.edgington.view.huds.elements
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.net.TournamentData;
	import com.edgington.net.events.TournamentEvent;
	import com.edgington.util.NumberFormat;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.valueobjects.TournamentVO;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class element_tournamentEntryHud extends Sprite
	{
		
		private var hud:ui_tournament_entry;
		
		private var tournamentData:TournamentData;
		
		private var tournamentIndex:int;
		private var tournamentVO:TournamentVO;
		
		private var scoreFound:Boolean = false;
		
		public function element_tournamentEntryHud(tournamentIndex:int)
		{
			super();
			
			this.tournamentIndex = tournamentIndex;
			
			hud = new ui_tournament_entry();
			hud.details.visible = false;
			
			this.scaleX = this.scaleY = DynamicConstants.MESSAGE_SCALE;
			
			hud.picture_artist.cacheAsBitmap = true;
			
			this.addChild(hud);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		public function displayTournamentData(currentIndex:int):void{
			tournamentData = TournamentData.getInstance();
			tournamentVO = tournamentData.currentActiveTournaments[tournamentIndex];
			
			new element_artwork(hud.picture_artist, tournamentData.currentActiveTournaments[tournamentIndex].ARTWORK_URL);
			
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
					var updated:Boolean = false;
					for(var i:int = 0; i < tournamentData.currentLeader.length; i++){
						if(tournamentData.currentLeader[i].trackkey != null && tournamentData.currentLeader[i].trackkey != ""){
							var str:Array = String(tournamentData.currentLeader[i].trackkey).split("_");
							var id:String = str[1];
							LOG.debug(str);
							LOG.debug(tournamentVO.ID);
							if(id == tournamentVO.ID){
								hud.details.txt_player_name.text = tournamentData.currentLeader[i].userId.username;
								hud.details.txt_score.text = NumberFormat.addThreeDigitCommaSeperator(int(tournamentData.currentLeader[i].score));
								new element_profile_picture(hud.details.picture_user, tournamentData.currentLeader[i].userId.fb_id);
								updated = true;		
								scoreFound = true;
							}
						}
					}
					if(!updated && !scoreFound){
						hud.details.txt_player_name.text = gettext("tournament_entry_no_leader");
						hud.details.txt_score.text = 0;
					}
					
					break;
				case TournamentEvent.TOURNAMENT_LEADER_FAILED:
					hud.details.txt_player_name.text = gettext("tournament_entry_error_finding_leader");
					break;
			}

		}
		
		private function destroy(e:Event):void{
			tournamentData.responceSignal.remove(leaderHandle);
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