package com.edgington.view.huds.elements
{
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.net.UserData;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class element_mainMenuProfileIphone extends Sprite
	{
		
		private var profile:ui_main_menu_profile_box_iphone;
		private var picture:element_profile_picture;
		
		public function element_mainMenuProfileIphone()
		{
			super();
			
			profile = new ui_main_menu_profile_box_iphone();
			if(FacebookManager.getInstance().checkIfUserIsLoggedIn()){
			//	profile.txt_name.text = FacebookManager.getInstance().currentLoggedInUser.firstName + " " + FacebookManager.getInstance().currentLoggedInUser.lastName;
				picture = new element_profile_picture(profile.picture as ui_profile_picture, FacebookManager.getInstance().currentLoggedInUser.id);
				profile.credits.txt_label.text = "x" + UserData.getInstance().getCredits();
			}
			else{
			//	profile.txt_name.text = gettext("main_menu_guest_player");
				profile.credits.txt_label.text = "x" + UserData.getInstance().getCredits();
			}
			
			this.addChild(profile);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		private function destroy(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			profile = null;
			picture = null;
		}
	}
}