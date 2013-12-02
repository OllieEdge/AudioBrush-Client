package com.edgington.view.huds.elements
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.types.DeviceTypes;
	import com.edgington.types.FontFaceType;
	import com.edgington.util.localisation.getfont;
	import com.edgington.util.localisation.gettext;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class element_handSelection extends Sprite
	{
		
		private var message:ui_settings_direction;
		
		public function element_handSelection()
		{
			super();
			
			message = new ui_settings_direction;
			getfont(message.txt_hand, FontFaceType.BOLD);
			message.txt_hand.text = gettext("settings_hand_selection_question");
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPAD){
				message.iphone_left.visible = false;
				message.iphone_right.visible = false;
			}
			else{
				message.ipad_left.visible = false;
				message.ipad_right.visible = false;
			}
			this.addChild(message);
			this.cacheAsBitmap = true;
			
			this.scaleX = this.scaleY = DynamicConstants.MESSAGE_SCALE;
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		private function destroy(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			message = null;
		}
	}
}