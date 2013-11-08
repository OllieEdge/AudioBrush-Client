package com.edgington.view.huds.elements
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.util.debug.LOG;
	import com.edgington.view.assets.AssetCacher;
	import com.milkmangames.nativeextensions.GoViral;
	import com.milkmangames.nativeextensions.events.GVFacebookEvent;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	
	public class element_profile_picture extends Sprite
	{
		private var picture:ui_profile_picture;
		public var profileID:String;
		
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
			
			
			if(profileID != ""){
				
				if(AssetCacher.getInstance().checkForCachedImage("facebookPic_" + profileID)){
					removeAnyExistingImages();
					var rect:Rectangle = picture.img.getBounds(picture);
					picture.img.holder.visible = false;
					rect.x = 0;
					rect.y = 0;
					AssetCacher.getInstance().insertCachedImage("facebookPic_" + profileID, picture.img, rect);
					return;
				}
				
				var urlRequest:URLRequest = new URLRequest("http://graph.facebook.com/"+profileID+"/picture?width=200&height=200");
				imageLoader = new Loader();
				imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);
				imageLoader.load(urlRequest);
			}
			
			this.cacheAsBitmap = true;
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		public function changeImage(profileID:String = ""):void{
			this.profileID = profileID;
			
			if(!picture.img.holder.visible){
				
				removeAnyExistingImages();
				
				picture.img.holder.visible = true;
			}
			
			if(profileID != ""){
				
				if(AssetCacher.getInstance().checkForCachedImage("facebookPic_" + profileID)){
					removeAnyExistingImages();
					var rect:Rectangle = picture.img.getBounds(picture);
					picture.img.holder.visible = false;
					rect.x = 0;
					rect.y = 0;
					AssetCacher.getInstance().insertCachedImage("facebookPic_" + profileID, picture.img, rect);
					return;
				}
				
				var urlRequest:URLRequest = new URLRequest("http://graph.facebook.com/"+profileID+"/picture?width=200&height=200");
				imageLoader = new Loader();
				imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);
				imageLoader.load(urlRequest);
			}
		}
		
		private function facebookPicDownloaded(e:Event):void{
			LOG.info(e.target.data);
		}
		
		private function facebookPicDownloadError(e:IOErrorEvent):void{
			LOG.info("There was a problem downloading the requested Facebook image");
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
			AssetCacher.getInstance().saveImage("facebookPic_" + profileID, e.target.bytes);
			profileBitmap = new Bitmap(e.target.content.bitmapData.clone());
			if(picture != null){
				profileBitmap.width = picture.img.width;
				profileBitmap.height = picture.img.height;
				
				removeAnyExistingImages();
				
				picture.img.holder.visible = false;
				picture.img.addChild(profileBitmap);
			}
			imageLoader.unload();
			imageLoader = null;
			
		}
		
		private function checkFailureResponce(e:GVFacebookEvent):void{
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_FAILED, checkFailureResponce);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, checkResponce);
		}
		
		private function removeAnyExistingImages():void{
			var i:int = picture.img.numChildren
			while(i--){
				if(picture.img.getChildAt(i) != picture.img.holder){
					picture.img.removeChildAt(i);
				}
			}
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