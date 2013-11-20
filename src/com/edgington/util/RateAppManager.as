package com.edgington.util
{
	import com.edgington.util.localisation.gettext;
	import com.milkmangames.nativeextensions.RateBox;

	public class RateAppManager
	{
	
		private static var _INSTANCE:RateAppManager;
		
		public function RateAppManager():void{
			setup();
		}
		
		private function setup():void{
			if(RateBox.isSupported()){
				RateBox.create("646334666", 
					gettext("rate_app_title"), 
					gettext("rate_app_desccription"), 
					gettext("rate_app_rate_now"),
					gettext("rate_app_rate_later"),
					gettext("rate_app_never_again"),
					3, 0, 1, 2);
			}
		}
		
		public static function get INSTANCE():RateAppManager{
			if(_INSTANCE == null){
				_INSTANCE = new RateAppManager();
			}
			return _INSTANCE;
		}
	}
}