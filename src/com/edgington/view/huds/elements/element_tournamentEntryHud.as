package com.edgington.view.huds.elements
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.TournamentTrackPreviewer;
	import com.edgington.net.TournamentData;
	import com.edgington.net.events.TournamentEvent;
	import com.edgington.util.DateStringFormatter;
	import com.edgington.util.NumberFormat;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.valueobjects.TournamentVO;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osflash.signals.Signal;
	
	public class element_tournamentEntryHud extends Sprite
	{
		
		private var hud:ui_tournament_entry;
		
		private var tournamentData:TournamentData;
		
		private var tournamentIndex:int;
		private var tournamentVO:TournamentVO;
		
		private var scoreFound:Boolean = false;
		
		private var tournamentTimer:Timer;
		
		private var isPreviewing:Boolean = false;
		private var previewSignal:Signal;
		
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
			
			hud.details.txt_titleFinishes.text = gettext("tournament_finishes_in");
			hud.previewBox.txt_preview.text = gettext("tournament_preview");
			hud.previewBox.bar.visible = false;
			
			hud.details.visible = true;
			hud.removeChild(hud.loader);
			
			updateTournamentDuration(null);
			
			tournamentTimer = new Timer(1000, 0);
			tournamentTimer.addEventListener(TimerEvent.TIMER, updateTournamentDuration);
			tournamentTimer.start();
			
			if(!tournamentVO.CACHED){
				hud.previewBox.visible = false;
			}
			else{
				hud.picture_artist.addEventListener(MouseEvent.MOUSE_UP, previewTrackHandle);
				hud.previewBox.mouseChildren = false;
				hud.previewBox.mouseEnabled = false;
			}
			
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
		
		private function previewTrackHandle(e:MouseEvent):void{
			if(isPreviewing){
				isPreviewing = false;
				hud.previewBox.bar.visible = false;
				hud.previewBox.txt_preview.text = gettext("tournament_preview");
				hud.previewBox.playButton.gotoAndStop(1);
				TournamentTrackPreviewer.getInstance().stopTrack();
			}
			else{
				hud.previewBox.txt_preview.text = "0:30";
				hud.previewBox.bar.visible = true;
				hud.previewBox.bar.scaleX = 0;
				isPreviewing = true;
				previewSignal = new Signal();
				previewSignal.add(updatePreviewTimer);
				TournamentTrackPreviewer.getInstance().previewTrack(tournamentVO.ID, previewSignal);
				hud.previewBox.playButton.gotoAndPlay(2);
			}
		}
		
		private function updatePreviewTimer(time:int):void{
			
			var secondsRemaining:String =  (30 - time) < 10 ? "0" + (30 - time) : "" + (30 - time);
			
			hud.previewBox.txt_preview.text = "0:" + secondsRemaining;
			hud.previewBox.bar.scaleX = time/30;
			if(time == 30){
				isPreviewing = false;
				hud.previewBox.bar.visible = false;
				previewSignal.removeAll();
				previewSignal = null;
				hud.previewBox.txt_preview.text = gettext("tournament_preview");
				hud.previewBox.playButton.gotoAndStop(1);
				TournamentTrackPreviewer.getInstance().stopTrack();
			}
		}
		
		private function updateTournamentDuration(e:TimerEvent):void{
			hud.details.txt_finishes.text = DateStringFormatter.getDurationBetweenDatesString(new Date(), tournamentVO.END_DATE);
			
			
			var tournamentMax:Number = tournamentVO.END_DATE.time - tournamentVO.ACTIVE_DATE.time;
			var currentTime:Number = new Date().time - tournamentVO.ACTIVE_DATE.time;
			hud.details.bar.scaleX = currentTime / tournamentMax;
		}
		
		private function destroy(e:Event):void{
			hud.picture_artist.removeEventListener(MouseEvent.MOUSE_UP, previewTrackHandle);
			
			if(previewSignal != null){
				previewSignal.removeAll();
				previewSignal = null;
			}
			tournamentTimer.removeEventListener(TimerEvent.TIMER, updateTournamentDuration);
			tournamentTimer.stop();
			tournamentTimer = null;
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