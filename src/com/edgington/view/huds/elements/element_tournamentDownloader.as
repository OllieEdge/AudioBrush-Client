package com.edgington.view.huds.elements
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.tournaments.TournamentAssetsManager;
	import com.edgington.net.TournamentData;
	import com.edgington.net.events.TournamentEvent;
	import com.edgington.util.localisation.gettext;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class element_tournamentDownloader extends Sprite
	{
		
		private var hud:ui_tournament_downloading;
		
		public function element_tournamentDownloader()
		{
			super();
			
			hud = new ui_tournament_downloading();
			hud.txt_downloading.text = gettext("tournament_downloading");
			hud.txt_description.text = gettext("tournament_description");
			
			this.scaleX = this.scaleY = DynamicConstants.MESSAGE_SCALE;
			
			new element_artwork(hud.picture, TournamentData.getInstance().currentActiveTournament.ARTWORK_URL);
			
			TournamentAssetsManager.getInstance().downloadSignal.add(handleProgress);
			
			this.addChild(hud);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		private function handleProgress(eventType:String, progress:Number):void{
			if(eventType == TournamentEvent.DATA_PROGRESS){
				hud.ui_progressbar.bar.scaleX = progress;
			}
		}
		
		private function destroy(e:Event):void{
			TournamentAssetsManager.getInstance().downloadSignal.remove(handleProgress);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			
			hud = null;
		}
	}
}