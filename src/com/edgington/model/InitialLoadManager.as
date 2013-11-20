package com.edgington.model
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.model.gamecenter.GameCenterManager;
	import com.edgington.model.payments.MobilePurchaseManager;
	import com.edgington.util.PushNotificationsManager;
	import com.edgington.util.RateAppManager;
	import com.edgington.util.TextFieldManager;
	import com.edgington.util.localisation.LOCALE_INSTANCE;
	import com.edgington.util.localisation.Locale;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.assets.AssetLoader;
	import com.greensock.TweenLite;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;

	public class InitialLoadManager extends EventDispatcher
	{
		//The load tick timer.
		private var checkLoadTimer:Timer;
		
		//The current task that is being loaded
		private var loadStatus:int = 0;
		//Every time the timer ticks on a certain load this will increment (the idea being if this gets to high we can handle something to sort it out)
		private var currentLoadTaskTickCount:int = 0;
		
		//The textfield on the screen during the initial load screen
		private var loadStatusText:TextField;
		
		public function InitialLoadManager(loadStatusText:TextField)
		{
			checkLoadTimer = new Timer(1000, 0);
			checkLoadTimer.addEventListener(TimerEvent.TIMER, checkLoadStatus);
			checkLoadTimer.start();
			
			this.loadStatusText = loadStatusText;
			load();
			checkLoadStatus(null);
		}
		
		private function checkLoadStatus(e:TimerEvent):void{
			switch(loadStatus){
				case 0:
					loadStatusText.text = "Loading locale...";
					if(LOCALE_INSTANCE.isLoaded){
						localeComplete(null);
					}
					if(LOCALE_INSTANCE.errorLoading){
						loadStatusText.text = "Sorry but we couldn't load your language, please contact support.";	
					}
					currentLoadTaskTickCount++;
					break;
				case 1:
					loadStatusText.text = gettext("loadmanager_apple_store");
					if(MobilePurchaseManager.INSTANCE.isLoaded){
						purchasesLoaded(null);
					}
					if(MobilePurchaseManager.INSTANCE.errorLoading){
						loadStatusText.text = gettext("loadmanager_apple_store_error");
					}
					currentLoadTaskTickCount++;
					break;
				case 2:
					loadStatusText.text = gettext("loadmanager_push_notifications");
					if(PushNotificationsManager.getInstance().isLoaded){
						pushNotificationsLoaded(null);
					}
					if(PushNotificationsManager.getInstance().errorLoading){
						loadStatusText.text = gettext("loadmanager_push_notifications_error");
						pushNotificationsLoaded(null);
					}
					currentLoadTaskTickCount++;
					break;
				case 3:
					loadStatusText.text = gettext("loadmanager_assets");
					if(AssetLoader.getInstance().isLoaded){
						assetsLoaded(null);
					}
					if(AssetLoader.getInstance().errorLoading){
						loadStatusText.text = gettext("loadmanager_asset_error");
						TweenLite.delayedCall(3, assetsLoaded, [null]);
					}
					currentLoadTaskTickCount++;
					break;
				case 4:
					gettext("loadmanager_complete_initial_load");
					cleanUp();
					break;
			}
			loadStatusText.x = loadStatusText.parent.stage.fullScreenWidth*.5 - loadStatusText.textWidth*.5;
		}
		
		private function increaseLoadStatus():void{
			loadStatus++;
			currentLoadTaskTickCount = 0;
			checkLoadStatus(null);
		}
		
		//The first load to call to begin all loads.
		private function load():void{
			LOCALE_INSTANCE = Locale.getInstance();
			LOCALE_INSTANCE.addEventListener(Event.COMPLETE, localeComplete);
			LOCALE_INSTANCE.loadXML("languages/" + DynamicConstants.CURRENT_LANGUAGE + ".xml");
		}
		private function localeComplete(e:Event):void{
			LOCALE_INSTANCE.removeEventListener(Event.COMPLETE, localeComplete);
			increaseLoadStatus();
			loadPurchases();
		}
		
		//Second load phase
		private function loadPurchases():void{
			MobilePurchaseManager.INSTANCE;
			MobilePurchaseManager.INSTANCE.addEventListener(Event.COMPLETE, purchasesLoaded);
		}
		private function purchasesLoaded(e:Event):void{
			MobilePurchaseManager.INSTANCE.removeEventListener(Event.COMPLETE, purchasesLoaded);
			increaseLoadStatus();
			loadPushNotifications();
		}
		
		//Third loading phase
		private function loadPushNotifications():void{
			PushNotificationsManager.getInstance();
			PushNotificationsManager.getInstance().addEventListener(Event.COMPLETE, pushNotificationsLoaded);
			PushNotificationsManager.getInstance().setupPN();
		}
		private function pushNotificationsLoaded(e:Event):void{
			PushNotificationsManager.getInstance().removeEventListener(Event.COMPLETE, pushNotificationsLoaded);
			increaseLoadStatus();
			loadAssets();
		}
		
		//Forth loading phase
		private function loadAssets():void{
			AssetLoader.getInstance().addEventListener(Event.COMPLETE, assetsLoaded);
		}
		private function assetsLoaded(e:Event):void{
			AssetLoader.getInstance().removeEventListener(Event.COMPLETE, assetsLoaded);
			
			
			SoundManager.getInstance();
			
			GameCenterManager.getInstance();
			
			FacebookManager.getInstance();
			
			RateAppManager.INSTANCE;
			
			increaseLoadStatus();
		}
		
		//When everything is loaded
		private function cleanUp():void{
			checkLoadTimer.stop();
			checkLoadTimer.removeEventListener(TimerEvent.TIMER, checkLoadStatus);
			checkLoadTimer = null;
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}