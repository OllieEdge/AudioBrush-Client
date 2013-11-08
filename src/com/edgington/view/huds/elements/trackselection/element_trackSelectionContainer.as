package com.edgington.view.huds.elements.trackselection
{
	import com.edgington.constants.Constants;
	import com.edgington.constants.DynamicConstants;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	
	public class element_trackSelectionContainer extends Sprite
	{
		
		private var background:Sprite;
		private var containerDescription:ui_list_description_box;
		
		private var containerDescriptionLabel:String;
		
		public function element_trackSelectionContainer(containerDescriptionLabel:String)
		{
			super();
		
			this.containerDescriptionLabel = containerDescriptionLabel;
			
			addListeners();
			
			setupVisuals();
		}
		
		private function addListeners():void{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		private function setupVisuals():void{
			background = new Sprite();
			background.graphics.beginFill(Constants.NORMAL_WHITE_COLOUR);
			background.graphics.drawRect(0, 0, (DynamicConstants.SCREEN_WIDTH-(DynamicConstants.SCREEN_MARGIN*2)), DynamicConstants.SCREEN_HEIGHT -  (Math.max(DynamicConstants.SCREEN_MARGIN, (47*DynamicConstants.BUTTON_SCALE) + (DynamicConstants.BUTTON_SPACING*2)) + DynamicConstants.SCREEN_MARGIN));
			background.graphics.endFill();
			
			containerDescription = new ui_list_description_box();
			containerDescription.txt_description.text = containerDescriptionLabel;
			containerDescription.txt_description.scaleX = containerDescription.txt_description.scaleY = DynamicConstants.DEVICE_SCALE;
			containerDescription.background.width = (DynamicConstants.SCREEN_WIDTH-(DynamicConstants.SCREEN_MARGIN*2)) - (DynamicConstants.BUTTON_SPACING*2);
			containerDescription.background.height *= DynamicConstants.DEVICE_SCALE;
			containerDescription.x = DynamicConstants.BUTTON_SPACING;
			containerDescription.y = DynamicConstants.BUTTON_SPACING;
			containerDescription.txt_description.autoSize = TextFieldAutoSize.LEFT;
			containerDescription.cacheAsBitmap = true;
			
			this.addChild(background);
			this.addChild(containerDescription);
		}
		
		public function changeDescriptionLabel(str:String):void{
			containerDescription.txt_description.text = str;
			containerDescriptionLabel = str;
		}
		
		public function getBodyOriginY():int{
			return containerDescription.y + containerDescription.height;
		}
		
		private function destroy(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
		}
	}
}