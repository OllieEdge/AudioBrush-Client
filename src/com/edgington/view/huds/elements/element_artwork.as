package com.edgington.view.huds.elements
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	public class element_artwork extends Sprite
	{
		private var picture:ui_profile_artwork;
		private var profileID:String;
		
		private var imageLoader:Loader;
		private var imageURLRequest:URLRequest;
		private var profileBitmap:Bitmap;
		
		public function element_artwork(profilePicture:ui_profile_artwork = null, imageURL:String = "")
		{
			super();
			
			this.profileID = profileID;
			
			if(profilePicture != null){
				picture = profilePicture as ui_profile_artwork;
			}
			else{
				picture = new ui_profile_artwork();
				this.addChild(picture);
			}
			
			this.cacheAsBitmap = true;
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			
			imageLoader = new Loader();
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);
			imageURLRequest = new URLRequest(imageURL);
			imageLoader.load(imageURLRequest);
		}
		
		private function imageLoaded(e:Event):void{
			imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, imageLoaded);
			profileBitmap = new Bitmap(e.target.content.bitmapData.clone());
			profileBitmap.width = picture.img.width;
			profileBitmap.height = picture.img.height;
			while(picture.img.numChildren > 0){
				picture.img.removeChildAt(0);
			}
			picture.img.addChild(profileBitmap);
		}
		
		private function destroy(e:Event):void{
			imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, imageLoaded);
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

