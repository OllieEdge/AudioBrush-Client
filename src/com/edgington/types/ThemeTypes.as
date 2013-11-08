package com.edgington.types
{
	import com.edgington.util.localisation.gettext;
	import com.edgington.valueobjects.ThemeVO;

	public class ThemeTypes
	{
		public static var FIRE_THEME:ThemeVO;
		public static var ICE_THEME:ThemeVO;
		public static var NORMAL_THEME:ThemeVO;
		
		public static function populateThemes():void{
			FIRE_THEME = new ThemeVO();
			FIRE_THEME.themeCost = 20;
			FIRE_THEME.themeID = "theme_fire";
			FIRE_THEME.themeName = gettext(FIRE_THEME.themeID+"_name");
			
			ICE_THEME = new ThemeVO();
			ICE_THEME.themeCost = 25;
			ICE_THEME.themeID = "theme_ice";
			ICE_THEME.themeName = gettext(ICE_THEME.themeID+"_name");
			
			NORMAL_THEME = new ThemeVO();
			NORMAL_THEME.themeCost = 0;
			NORMAL_THEME.themeID = "theme_normal";
			NORMAL_THEME.themeName = gettext(NORMAL_THEME.themeID+"_name");
		}
	}
}