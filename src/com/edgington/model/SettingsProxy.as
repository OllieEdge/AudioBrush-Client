package com.edgington.model
{	
	import com.edgington.types.HandDirectionType;
	import com.edgington.types.ThemeTypes;
	
	import flash.net.SharedObject;

	public class SettingsProxy
	{
		
		private static var INSTANCE:SettingsProxy;
		
		private var settingsStore:SharedObject = SharedObject.getLocal("abSettings");
		
		public var handSelection:String = null;
		
		public var currentTheme:String;
		
		public function SettingsProxy()
		{
			if(settingsStore.data.handSelected != null){
				handSelection = settingsStore.data.handSelected;
			}
			if(settingsStore.data.theme == null){
				currentTheme = ThemeTypes.NORMAL_THEME.themeID;
				settingsStore.data.theme = currentTheme;
				saveSettings();
			}
			currentTheme = settingsStore.data.theme;
		}
		
		public function changeTheme(themeID:String):void{
			currentTheme = themeID;
			settingsStore.data.theme = currentTheme;
			saveSettings();
		}
		
		public function changeHandSelection(handSelection:String):void{
			this.handSelection = handSelection;
			settingsStore.data.handSelected = handSelection;
			saveSettings();
		}
		
		public static function getInstance():SettingsProxy{
			if(INSTANCE == null){
				INSTANCE = new SettingsProxy();
			}
			return INSTANCE;
		}
		
		private function saveSettings():void{
			settingsStore.flush();
		}
	}
}