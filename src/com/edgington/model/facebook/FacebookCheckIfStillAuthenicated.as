package com.edgington.model.facebook
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.events.FacebookEvent;
	import com.edgington.net.GiftData;
	import com.edgington.net.ProductsData;
	import com.edgington.net.UserData;
	import com.edgington.util.debug.LOG;
	import com.greensock.TweenLite;
	import com.milkmangames.nativeextensions.GoViral;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osflash.signals.Signal;

	public class FacebookCheckIfStillAuthenicated
	{
		public var statusSignal:Signal;
		
		private var facebookSignInSignal:Signal;
		private var loginToFacebook:FacebookCheckLogin;
		
		private var mainOverloadTimer:Timer = new Timer(20000, 1);
		
		public function FacebookCheckIfStillAuthenicated()
		{
			statusSignal = new Signal();
		}
		
		public function startCheck():void{
			mainOverloadTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleOverload);
			mainOverloadTimer.start();
			if(DynamicConstants.isMobileOS()){
				if(!FacebookManager.getInstance().checkIfUserIsLoggedIn()){
					statusSignal.dispatch(false);
				}
				else{
					beginProfileAndFriendsDownload();
				}
			}
			else{
				statusSignal.dispatch(true);
			}
		}
		
		private function beginProfileAndFriendsDownload():void{
			facebookSignInSignal = new Signal();
			facebookSignInSignal.add(handleFacebookSignIn);
			loginToFacebook = new FacebookCheckLogin(facebookSignInSignal);
		}
		
		private function handleFacebookSignIn(eventType:String, error:String = ""):void{
			if(eventType == FacebookEvent.FACEBOOK_LOGGED_IN){
				facebookSignInSignal.remove(handleFacebookSignIn);
				loginToServer();
			}
			else if(eventType == FacebookEvent.FACEBOOK_LOGIN_FAILED){
				GoViral.goViral.logoutFacebook();
				loginToFacebook.loginToFacebook();
			}
			else{
				GoViral.goViral.logoutFacebook();
				LOG.error("Check Sign In Failed: " + error);
				//Login failed for some reason - manual login is necessary
				statusSignal.dispatch(false);
			}
		}
		
		private function loginToServer():void{
			UserData.getInstance().userDataSignal.add(handleUserDataDownloaded);
			UserData.getInstance().getUser();
		}
		
		private function handleUserDataDownloaded():void{
			if(facebookSignInSignal != null){
				GiftData.getInstance().getGifts();
				ProductsData.getInstance().getProducts();
				statusSignal.dispatch(true);
			}
		}
		
		private function handleOverload(e:TimerEvent):void{
			facebookSignInSignal.dispatch(false);
		}
		
		public function destroy():void{
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
		}
	}
}