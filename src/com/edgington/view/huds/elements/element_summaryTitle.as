package com.edgington.view.huds.elements
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.GameProxy;
	import com.edgington.util.NumberFormat;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class element_summaryTitle extends Sprite
	{
		
		private var title:ui_summaryScore;
		
		public function element_summaryTitle()
		{
			super();
			
			title = new ui_summaryScore();
			title.txt_score.text = NumberFormat.addThreeDigitCommaSeperator(GameProxy.INSTANCE.score);
			this.scaleX = this.scaleY = DynamicConstants.MESSAGE_SCALE;
			this.cacheAsBitmap = true;
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