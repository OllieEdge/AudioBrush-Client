package com.edgington.util.localisation
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class LocaleTest extends Sprite
	{
		
		private var locale:Locale = Locale.getInstance();
		
		private var timer:Timer = new Timer(1000, 0);
		
		public function LocaleTest()
		{
			LOCALE_INSTANCE = Locale.getInstance();
			locale.loadXML("xml/translations.xml");
			timer.addEventListener(TimerEvent.TIMER, getText);
			timer.start();
		}
		
		protected function getText(event:TimerEvent):void
		{
			var obj:Object = new Object();
			obj.players = 2;
			
			trace(gettext("_Hippie_Title"));
			trace(gettext("_gameplay_players_no_cards"));
			trace(gettext("_gameplay_players_no_cards", {players:2}));
		}
	}
}