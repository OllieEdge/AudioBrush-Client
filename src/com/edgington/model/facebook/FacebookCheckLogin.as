package com.edgington.model.facebook
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.FacebookConstants;
	import com.edgington.model.events.FacebookEvent;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.milkmangames.nativeextensions.GoViral;
	import com.milkmangames.nativeextensions.events.GVFacebookEvent;
	
	import org.osflash.signals.Signal;

	public class FacebookCheckLogin
	{
		private var facebookSignal:Signal;
		
		private var debug:Boolean = false;
		
		private var profileSet:Boolean = false;
		
		public function FacebookCheckLogin(facebookSignal:Signal)
		{
			this.facebookSignal = facebookSignal;
			
			if(GoViral.isSupported() && GoViral.goViral.isFacebookAuthenticated()){
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_FAILED,onProfileReceived);
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE,onProfileReceived);
				GoViral.goViral.requestMyFacebookProfile();
			}
			else{
				facebookSignal.dispatch(FacebookEvent.FACEBOOK_REQUIRES_LOGIN);
			}
		}
		
		public function loginToFacebook():void{
			if(DynamicConstants.isMobileOS()){
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGGED_IN,onFacebookEvent);
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGGED_OUT,onFacebookLogout);
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_CANCELED,onFacebookEvent);
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_FAILED,onFacebookEvent);
				
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_FAILED,onProfileReceived);
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE,onProfileReceived);
					
				GoViral.goViral.authenticateWithFacebook(FacebookConstants.MINIMUM_PERMISSIONS);
			}
		}
		
		public function getUserProfile():void{
			if(DynamicConstants.isMobileOS()){
				if(GoViral.goViral.isFacebookAuthenticated()){
					GoViral.goViral.requestMyFacebookProfile();
				}
			}
		}
		
		private function onFacebookLogout(e:GVFacebookEvent):void{
			LOG.facebook("Facebook logged out");
		}
		
		private function onFacebookEvent(e:GVFacebookEvent):void{
			if(e.type == GVFacebookEvent.FB_LOGGED_IN){
				getUserProfile();
			}
			else{
				facebookSignal.dispatch(FacebookEvent.FACEBOOK_LOGIN_FAILED, gettext("facebook_unknown_error"));
			}
		}
		
		private function onProfileReceived(e:GVFacebookEvent):void{
			if(!profileSet){
				if(e.type == GVFacebookEvent.FB_REQUEST_RESPONSE){
					var fbProfileVO:FacebookProfileVO;
					if(e.friends.length > 0){
						LOG.facebook(e.data.name + " is now logged into Facebook");
						fbProfileVO = new FacebookProfileVO(e.friends[0]);
					}
					else{
						fbProfileVO = new FacebookProfileVO(null, e.data);
					}
					profileSet = true;
					FacebookManager.getInstance().currentLoggedInUser = fbProfileVO;
					
					GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_FAILED,onProfileReceived);
					GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE,onProfileReceived);
					
					GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, facebookFriendsDownloaded);
					GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_FAILED, facebookFriendsDownloadFailed);
					GoViral.goViral.requestFacebookFriends({fields:"installed,name,gender"});
					LOG.facebook("Requesting Friends");
					
				}
				else{
					LOG.facebook("There was a problem downloading the users Facebook Profile");
					if(e.errorCode == 5){
						facebookSignal.dispatch(FacebookEvent.FACEBOOK_LOGIN_FAILED, gettext("facebook_no_internet"));
					}
					else{
						facebookSignal.dispatch(FacebookEvent.FACEBOOK_LOGIN_FAILED, gettext("facebook_unknown_error"));		
					}
				}
			}
		}
		
		private function facebookFriendsDownloaded(e:GVFacebookEvent):void{
			if(e.graphPath == "me/friends"){
				var facebookManger:FacebookManager = FacebookManager.getInstance();
				GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, facebookFriendsDownloaded);
				GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_FAILED, facebookFriendsDownloadFailed);
				var installFriends:Vector.<FacebookProfileVO> = new Vector.<FacebookProfileVO>;
				var allFriends:Vector.<FacebookProfileVO> = new Vector.<FacebookProfileVO>;
				var friendsLength:int = e.data.data.length;
				for(var i:int = 0; i < friendsLength; i++){
					if(e.data.data[i].installed){
						installFriends.push(new FacebookProfileVO(null, e.data.data[i]));
					}
					allFriends.push(new FacebookProfileVO(null, e.data.data[i]));
				}
				FacebookManager.getInstance().currentLoggedInUserFriendsWithInstall = installFriends;
				FacebookManager.getInstance().currentLoggedInUserFriends = allFriends;
				facebookSignal.dispatch(FacebookEvent.FACEBOOK_LOGGED_IN);
				destroy();
			}
		}
		
		private function facebookFriendsDownloadFailed(e:GVFacebookEvent):void{
			LOG.facebook("COULDN'T GET FRIENDS!!! --> Code " + e.errorCode + ": " + e.errorMessage);
			facebookSignal.dispatch(FacebookEvent.FACEBOOK_LOGGED_IN);
			destroy();
		}
		
		public function destroy():void{
			facebookSignal.removeAll();
			facebookSignal = null;
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGGED_IN,onFacebookEvent);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGGED_OUT,onFacebookEvent);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGIN_CANCELED,onFacebookEvent);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGIN_FAILED,onFacebookEvent);
			
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_FAILED,onProfileReceived);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE,onProfileReceived);
			
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, facebookFriendsDownloaded);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_FAILED, facebookFriendsDownloadFailed);
		}
	}
}