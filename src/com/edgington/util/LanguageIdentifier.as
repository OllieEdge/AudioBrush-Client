package com.edgington.util
{
	import com.edgington.constants.Constants;
	
	import flash.system.Capabilities;

	public class LanguageIdentifier
	{
		public static function getBestLanguageTagForUser():String{
			
			var str:String = Capabilities.language;
			var languageSet:Boolean = false;
			
			//Straight up - get the default language.
			for(var i:int = 0; i < Constants.AVAILABLE_LANGUAGES.length; i++){
				if(str == Constants.AVAILABLE_LANGUAGES[i]){
					languageSet = true;
					break;
				}
			}
			
			//If the above didn't find any available languages, then look through the list of other languages the user might like.
			if(!languageSet){
				var availableLanguages:Array = Capabilities.languages;
				for(i = 0; i < availableLanguages.length; i++){
					var language:Array;
					if(String(availableLanguages[i]).indexOf("-")){
						language = String(availableLanguages[i]).split("-");
					}
					else{
						language = [availableLanguages[i]];
					}
					for(var c:int = 0; c < Constants.AVAILABLE_LANGUAGES.length; c++){
						if(language[0] == Constants.AVAILABLE_LANGUAGES[i]){
							str = language[0];
							languageSet = true;
							break;
						}
					}
					if(languageSet){
						break;
					}
				}
			}
			
			//Default to english as a last resort.
			if(!languageSet){
				str = "en";
			}
			
			return str;
		}
	}
}