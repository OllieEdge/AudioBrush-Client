package com.edgington.model.facebook
{
	import com.edgington.constants.FacebookConstants;
	import com.edgington.model.facebook.opengraph.actions.IOpenGraphAction;
	import com.edgington.util.debug.LOG;
	import com.milkmangames.nativeextensions.GVFacebookFriend;
	import com.milkmangames.nativeextensions.GoViral;
	import com.milkmangames.nativeextensions.events.GVFacebookEvent;
	
	public class FacebookManager
	{
		
		private static var INSTANCE:FacebookManager;
		
		public var isSupported:Boolean = false;
		
		public var currentLoggedInUser:FacebookProfileVO;
		
		public var currentLoggedInUserFriends:Vector.<GVFacebookFriend>;
		public var currentLoggedInUserFriendsWithInstall:Vector.<FacebookProfileVO>;
		
		private var facebookOpenGraphDispatcher:FacebookOpenGraphDispatcher;
		
		public function FacebookManager()
		{
			if(GoViral.isSupported())
			{
				GoViral.create();
				GoViral.goViral.initFacebook(FacebookConstants.APP_ID,"");
				
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_CANCELED,onFacebookEvent);
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_FAILED,onFacebookEvent);
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_FINISHED,onFacebookEvent);
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGGED_IN,onFacebookEvent);
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGGED_OUT,onFacebookEvent);
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_CANCELED,onFacebookEvent);
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_FAILED,onFacebookEvent);
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_FAILED,onFacebookEvent);
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE,onFacebookEvent);
				GoViral.goViral.addEventListener(GVFacebookEvent.FACEBOOK_FEED_DIALOG,onFacebookEvent);
				GoViral.goViral.addEventListener(GVFacebookEvent.FACEBOOK_REQUEST_DIALOG,onFacebookEvent);
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_PUBLISH_PERMISSIONS_FAILED,onFacebookEvent);
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_PUBLISH_PERMISSIONS_UPDATED,onFacebookEvent);
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_READ_PERMISSIONS_FAILED,onFacebookEvent);
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_READ_PERMISSIONS_UPDATED,onFacebookEvent);
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_SESSION_INVALIDATED,onFacebookEvent);
				
				facebookOpenGraphDispatcher = new FacebookOpenGraphDispatcher();
				
				
				
				isSupported = true;
			}
			else {
				LOG.facebook("GoViral only works on mobile!");
				return;
			}
		}
		
		public function checkIfUserIsLoggedIn():Boolean{
			if(isSupported){
				return GoViral.goViral.isFacebookAuthenticated();
			}
			return false;
		}
		
		public function updateActivity(action:IOpenGraphAction):void{
			if(isSupported){
				facebookOpenGraphDispatcher.dispatchOpenGraphRequest(action);
			}
		}
		
		public function requestPostPermissions():void{
			if(isSupported){
				GoViral.goViral.requestNewFacebookPublishPermissions("publish_actions");
			}
		}
		
		public function postMessage():void{
			GoViral.goViral.showFacebookFeedDialog(
				"Posting from AIR",
				"This is a caption",
				"This is a message!",
				"This is a description",
				"http://audiobrush.com",
				"http://4.bp.blogspot.com/-fyFnnZ4viuM/UWtuumw9ClI/AAAAAAAAAFI/QiyXndIAg8k/s1600/Screen+Shot+2013-04-15+at+4.04.05+AM.png"
			);
		}
		
		private function onFacebookEvent(e:GVFacebookEvent):void{
			switch(e.type){
				case GVFacebookEvent.FB_LOGGED_IN:
						LOG.facebook("LOGGED IN");
					break;
				case GVFacebookEvent.FB_LOGGED_OUT:
						LOG.facebook("LOGGED OUT");
					break;
				case GVFacebookEvent.FB_LOGIN_FAILED:
						LOG.facebook("There was a problem logging into Facebook");
					break;
				case GVFacebookEvent.FB_LOGIN_CANCELED:
						LOG.facebook("The user canceled logging in with Facebook");
					break;
				case GVFacebookEvent.FB_LOGIN_CANCELED:
						LOG.facebook("The user canceled logging in with Facebook");
					break;
				case GVFacebookEvent.FB_REQUEST_FAILED:
						LOG.facebook("An Graph request failed");
					break;
				case GVFacebookEvent.FB_REQUEST_RESPONSE:
						LOG.facebook("Graph action responce");
					break;
				case GVFacebookEvent.FB_SESSION_INVALIDATED:
						LOG.facebook("This facebook session is no longer valid");
					break;
				case GVFacebookEvent.FB_READ_PERMISSIONS_UPDATED:
						LOG.facebook("The profile READ permissions have successfully updated");
					break;
				case GVFacebookEvent.FB_READ_PERMISSIONS_FAILED:
						LOG.facebook("READ permissions failed to update");
					break;
				case GVFacebookEvent.FB_PUBLISH_PERMISSIONS_UPDATED:
						LOG.facebook("The profile PUBLISH permissions have successfully updated");
					break;
				case GVFacebookEvent.FB_PUBLISH_PERMISSIONS_FAILED:
						LOG.facebook("PUBLISH permissions failed to update");
					break;
				case GVFacebookEvent.FB_DIALOG_FINISHED:
						LOG.facebook("A native dialog has finished");
					break;
				case GVFacebookEvent.FB_DIALOG_CANCELED:
						LOG.facebook("A native dialog has was canceled");
					break;
				case GVFacebookEvent.FB_DIALOG_FAILED:
						LOG.facebook("A native dialog failed");
					break;
				case GVFacebookEvent.FACEBOOK_REQUEST_DIALOG:
						LOG.facebook("New request dialog shown");
					break;
				case GVFacebookEvent.FACEBOOK_FEED_DIALOG:
						LOG.facebook("New feed dialog shown");
					break;
			}
			

		}
		
		public static function getInstance():FacebookManager{
			if(INSTANCE == null){
				INSTANCE = new FacebookManager();
			}
			return INSTANCE;
		}
	}
}