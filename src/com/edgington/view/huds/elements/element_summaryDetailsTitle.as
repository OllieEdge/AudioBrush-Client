package com.edgington.view.huds.elements
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.GameProxy;
	import com.edgington.net.TrackData;
	import com.edgington.util.NumberFormat;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class element_summaryDetailsTitle extends Sprite
	{
		
		private var title:ui_summaryOutcomeTitle
		private var trackImage:TrackData;
		
		public function element_summaryDetailsTitle()
		{
			super();
			
			title = new ui_summaryOutcomeTitle();
			title.txt_artist.text = GameProxy.INSTANCE.currentTrackDetails.artist;
			title.txt_trackTitle.text = GameProxy.INSTANCE.currentTrackDetails.trackTitle;
			title.txt_score.text = NumberFormat.addThreeDigitCommaSeperator(GameProxy.INSTANCE.score);
			
			title.starrating.gotoAndStop(GameProxy.INSTANCE.starRating);
			
			trackImage = new TrackData(new <String>[title.txt_trackTitle.text, title.txt_artist.text], title.background.picture);
			
			this.scaleX = this.scaleY = DynamicConstants.MESSAGE_SCALE;
			
			title.cacheAsBitmap = true;
			
			this.addChild(title);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		private function destroy(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			title = null;
		}
	}
}