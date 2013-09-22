package com.edgington.util
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.PushNotificationsConstants;
	import com.edgington.util.debug.LOG;
	import com.milkmangames.nativeextensions.EasyPush;
	import com.milkmangames.nativeextensions.events.PNAEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;

	public class PushNotificationsManager extends EventDispatcher
	{
		
		private static var INSTANCE:PushNotificationsManager;
		
		private const PREVENT_NOTIFICATIONS_UPON_START:Boolean = false;
		private const AMOUNT_OF_TIME_TO_DELAY:int = 1;
		
		private var PushNotificationsObject:SharedObject;
		
		public var pushNotificationsEnabled:Boolean = false;
		public var airshipToken:String;
		
		private var tags:Vector.<String>;
		
		public function PushNotificationsManager()
		{
			PushNotificationsObject = SharedObject.getLocal("ab_tags");
			tags = new Vector.<String>;
			if(PushNotificationsObject.data.tags != null){
				for(var i:int = 0; i < PushNotificationsObject.data.tags.length; i++){
					tags.push(PushNotificationsObject.data.tags[i]);
				}
			}
			else{
				PushNotificationsObject.data.tags = new Array();
				PushNotificationsObject.flush();
			}
		}
		
		public function setupPN():void{
			if(EasyPush.isSupported() && EasyPush.areNotificationsAvailable()){
				if(DynamicConstants.isDebug()){
					EasyPush.initAirship(PushNotificationsConstants.DEV_AIRSHIP_KEY, PushNotificationsConstants.DEV_AIRSHIP_SECRET, "airship", true, true, true);	
				}
				else{
					EasyPush.initAirship(PushNotificationsConstants.PROD_AIRSHIP_KEY, PushNotificationsConstants.PROD_AIRSHIP_SECRET, "airship", false, true, true);
				}
				EasyPush.airship.addEventListener(PNAEvent.TOKEN_REGISTERED,onTokenRegistered);
				EasyPush.airship.addEventListener(PNAEvent.TOKEN_REGISTRATION_FAILED,onRegFailed);
				EasyPush.airship.addEventListener(PNAEvent.TYPES_DISABLED,onTokenTypesDisabled);
			}
			else{
				complete();
				LOG.debug("Push Notifications are not available on this platform.");
			}
			
			if(PREVENT_NOTIFICATIONS_UPON_START){
				var now:Date=new Date();
				var inMinutes:Date=new Date();
				inMinutes.setTime(now.millisecondsUTC+(AMOUNT_OF_TIME_TO_DELAY*60*1000));
				EasyPush.airship.setQuietTime(now, inMinutes);
			}
		}
		
		private function onTokenRegistered(e:PNAEvent):void
		{
			complete();
			pushNotificationsEnabled = true;
			airshipToken = e.token;
			LOG.debug("EasyPush Token was registered: "+e.token);
		}
		
		private function onRegFailed(e:PNAEvent):void
		{
			complete();
			LOG.debug("EasyPush reg failed: "+e.errorId+"="+e.errorMsg);
		}
		
		private function onTokenTypesDisabled(e:PNAEvent):void
		{
			complete();
			LOG.debug("EasyPush some types disabled: "+e.disabledTypes);
		}
		
		private function complete():void{
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * This basically gives a name to the unique user so that they can be identified individually on urbanariship
		 */
		public static function updateUserAlias(alias:String):void{
			if(EasyPush.isSupported() && EasyPush.areNotificationsAvailable()){
				EasyPush.airship.setAirshipTags(INSTANCE.tags);
				EasyPush.airship.updateAlias(alias);
			}
		}
		
		/**
		 * This will put this user into a certain group which is dipicted by the tag given here.
		 */
		public static function setUserTag(tag:String):void{
			addTag(tag.toLowerCase());
			if(EasyPush.isSupported() && EasyPush.areNotificationsAvailable()){
				EasyPush.airship.setAirshipTags(INSTANCE.tags);
			}
		}
		
		private static function addTag(tag:String):void{
			for(var i:int = 0; i < INSTANCE.tags.length; i++){
				if(INSTANCE.tags[i] == tag){
					return;
				}
			}
			INSTANCE.tags.push(tag);
			INSTANCE.PushNotificationsObject.data.tags.push(tag);
			INSTANCE.PushNotificationsObject.flush();
			return;
		}
		
		public static function getInstance():PushNotificationsManager{
			if(INSTANCE == null){
				INSTANCE = new PushNotificationsManager();
			}
			return INSTANCE;
		}
	}
	
	
}