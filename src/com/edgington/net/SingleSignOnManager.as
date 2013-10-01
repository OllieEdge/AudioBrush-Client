package com.edgington.net
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.events.FacebookEvent;
	import com.edgington.model.facebook.FacebookCheckLogin;
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.util.debug.LOG;
	import com.greensock.TweenLite;
	import com.milkmangames.nativeextensions.GoViral;
	import com.milkmangames.nativeextensions.events.GVFacebookEvent;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osflash.signals.Signal;

	public class SingleSignOnManager
	{
		public var statusSignal:Signal;
		
		private var facebookSignInSignal:Signal;
		
		private var isFacebookLoggedIn:Boolean = false;
		private var loginToFacebook:FacebookCheckLogin;
		
		private var mainOverloadTimer:Timer = new Timer(20000, 1);
		
		public function SingleSignOnManager():void{
			statusSignal = new Signal();
			mainOverloadTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleOverload);
			mainOverloadTimer.start();
			if(GoViral.isSupported() && GoViral.goViral.isFacebookAuthenticated()){
				//do user download here
				beginProfileAndFriendsDownload();
			}
			else{
				//If we actually can use this system...
				if(DynamicConstants.isMobileOS()){
					TweenLite.delayedCall(5, checkFacebookManually);
					FacebookManager.getInstance().facebookSignals.add(facebookHandler);
				}
				else{
					//If not lets escape but make sure we don't fire too early
					TweenLite.delayedCall(1, statusSignal.dispatch, [false]);
				}
			}
		}
		
		/**
		 * If the initial check of the Facebook login was false, maybe it needed a little more time,
		 * This will listen for 5 seconds longer just in case.
		 * 
		 * If login is sucessfully proceed to download profile and friends
		 */
		private function facebookHandler(eventType:String):void{
			if(eventType == GVFacebookEvent.FB_LOGGED_IN){
				TweenLite.killDelayedCallsTo(checkFacebookManually);
				isFacebookLoggedIn = true;
				beginProfileAndFriendsDownload();
			}
		}
		
		/**
		 * After 5 seconds from first load if GoViral hasn't dispatched anything let's check manually
		 */
		private function checkFacebookManually():void{
			if(GoViral.isSupported() && GoViral.goViral.isFacebookAuthenticated()){
				isFacebookLoggedIn = true;
				beginProfileAndFriendsDownload();
			}
			else{
				LOG.debug("Facebook is not Authenticated");
				statusSignal.dispatch(false);
			}
		}
		
		private function beginProfileAndFriendsDownload():void{
			facebookSignInSignal = new Signal();
			facebookSignInSignal.add(handleFacebookSignIn);
			loginToFacebook = new FacebookCheckLogin(facebookSignInSignal);
		}
		
		/**
		 * If we've checked that we are logged in then lets see what the result was after getting profile and friends.
		 * 
		 * If we successfully get the profile and friends then we can get the server data for the user
		 * 
		 * If it wasn't successfully resort to manual
		 */
		private function handleFacebookSignIn(eventType:String, error:String = ""):void{
			if(eventType == FacebookEvent.FACEBOOK_LOGGED_IN){
				loginToServer();
			}
			else{
				LOG.error("Single Sign On Failed: " + error);
				//Login failed for some reason - manual login is necessary
				statusSignal.dispatch(false);
			}
		}
		
		
		/**
		 * If we've done all the facebook jazz and it was successful, lets get the user profile.
		 */
		private function loginToServer():void{
			UserData.getInstance().userDataSignal.add(handleUserDataDownloaded);
			UserData.getInstance().getUser();
		}
		
		/**
		 * Now everything is good to go, let's get down to business
		 */
		private function handleUserDataDownloaded():void{
			if(statusSignal != null){
				GiftData.getInstance().getGifts();
				ProductsData.getInstance().getProducts();
				statusSignal.dispatch(true);
			}
		}
		
		/**
		 * This is a fall-back should anything somehow go wrong, when the timer ticks after 20
		 * seconds single sign on will dispatch a fail.
		 */
		private function handleOverload(e:TimerEvent):void{
			statusSignal.dispatch(false);
		}
		
		public function destroy():void{
			FacebookManager.getInstance().facebookSignals.remove(facebookHandler);
			mainOverloadTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, handleOverload);
			mainOverloadTimer.stop();
			mainOverloadTimer = null;
			UserData.getInstance().userDataSignal.remove(handleUserDataDownloaded);
			if(facebookSignInSignal != null){
				facebookSignInSignal.removeAll();
				facebookSignInSignal = null;
			}
			TweenLite.killDelayedCallsTo(statusSignal.dispatch);
			statusSignal.removeAll();
			statusSignal = null;
			loginToFacebook = null;
			TweenLite.killDelayedCallsTo(checkFacebookManually);
		}
	}
}