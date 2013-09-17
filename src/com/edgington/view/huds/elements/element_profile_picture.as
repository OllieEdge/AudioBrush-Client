package com.edgington.view.huds.elements
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.facebook.FacebookManager;
	import com.milkmangames.nativeextensions.GoViral;
	import com.milkmangames.nativeextensions.events.GVFacebookEvent;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	public class element_profile_picture extends Sprite
	{
		private var picture:ui_profile_picture;
		private var profileID:String;
		
		private var imageLoader:Loader;
		private var imageURLRequest:URLRequest;
		private var profileBitmap:Bitmap;
		
		public function element_profile_picture(profilePicture:ui_profile_picture = null, profileID:String = "")
		{
			super();
			
			this.profileID = profileID;
			
			if(profilePicture != null){
				picture = profilePicture as ui_profile_picture;
			}
			else{
				picture = new ui_profile_picture();
				this.addChild(picture);
			}
			
			if(FacebookManager.getInstance().isSupported){
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_FAILED, checkFailureResponce);
				GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, checkResponce);
				GoViral.goViral.facebookGraphRequest(profileID+"?fields=picture.height("+picture.height+").width("+picture.width+").type(square)", "GET");
			}
			
			this.cacheAsBitmap = true;
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		private function checkResponce(e:GVFacebookEvent):void{
			if(e.data.id == profileID){
				GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_FAILED, checkFailureResponce);
				GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, checkResponce);
				if(!e.data.picture.data.is_silhouette && DynamicConstants.IS_CONNECTED){
					imageLoader = new Loader();
					imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);
					imageURLRequest = new URLRequest(e.data.picture.data.url);
					imageLoader.load(imageURLRequest);
				}
			}
		}
		
		private function imageLoaded(e:Event):void{
			
			imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, imageLoaded);
			profileBitmap = new Bitmap(e.target.content.bitmapData.clone());
			if(picture != null){
				profileBitmap.width = picture.img.width;
				profileBitmap.height = picture.img.height;
				while(picture.img.numChildren > 0){
					picture.img.removeChildAt(0);
				}
				picture.img.addChild(profileBitmap);
			}
		}
		
		private function checkFailureResponce(e:GVFacebookEvent):void{
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_FAILED, checkFailureResponce);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, checkResponce);
		}
		
		private function destroy(e:Event):void{
			if(FacebookManager.getInstance().isSupported){
				GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_FAILED, checkFailureResponce);
				GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, checkResponce);
			}
			if(imageLoader != null){
				imageLoader.unload();
				imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, imageLoaded);
			}
			imageLoader = null;
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			picture = null;
			profileBitmap = null;
		}
	}
}