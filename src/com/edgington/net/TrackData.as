package com.edgington.net
{
	
	import com.edgington.util.debug.LOG;
	import com.edgington.view.assets.AssetCacher;
	import com.edgington.view.huds.elements.element_artwork;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.osflash.signals.Signal;

	public class TrackData
	{
		
		private var urlCall:String = "https://itunes.apple.com/search?term="
			
		private var loader:URLLoader = new URLLoader();
		private var request:URLRequest = new URLRequest();
		
		private var trackData:Object;
		
		public var trackDetails:Object;
		public var resultsSignal:Signal;
		
		private var artwork:ui_profile_artwork;
		private var image_id:String
		
		public function TrackData(searchTerms:Vector.<String>, artwork:ui_profile_artwork = null, limit:int = 1)
		{
			this.artwork = artwork;
			
			resultsSignal = new Signal();
			for(var i:int = 0; i < searchTerms.length; i++){
				urlCall += searchTerms[i];
				if(i + 1 < searchTerms.length){
					urlCall += "+";
				}
			}
			
			var regExp:RegExp=new RegExp(/[^a-zA-Z 0-9]+|\s/g);
			image_id = urlCall.replace(regExp, "").toLowerCase();
			
			if(AssetCacher.getInstance().checkForCachedImage(image_id)){
				AssetCacher.getInstance().insertCachedImage(image_id, artwork, artwork.img.getBounds(artwork));
				artwork.removeChild(artwork.img);
				return;
			}
			
			request.url = (urlCall + "&limit="+limit+"&media=music&entity=musicTrack");
			loader.addEventListener(Event.COMPLETE, onLoaderComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.load(request);
		}
		
		private function onIOError(e:IOErrorEvent):void{
			LOG.warning("There was an IO Error when attempting to access the iTunes Store.");
			loader.removeEventListener(Event.COMPLETE, onLoaderComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			resultsSignal.dispatch();
		}
		
		private function onLoaderComplete(e:Event):void{
			loader.removeEventListener(Event.COMPLETE, onLoaderComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			try{
				trackData = JSON.parse(e.target.data);
			}
			catch(e:Error){
				LOG.error("The iTunes store did not return valid JSON for the track details");
				resultsSignal.dispatch();
				return;
			}
			if(trackData.resultCount > 0){
				for(var i:int = 0; i < trackData.resultCount; i++){
					if(trackData.results[i].kind == "song"){
						trackDetails = trackData.results[i];
						break;
					}
				}
				if(artwork != null && trackDetails != null){
					if(trackDetails.artworkUrl100 != null){
						new element_artwork(artwork, trackDetails.artworkUrl100, image_id);
					}
					else if(trackDetails.artworkUrl60 != null){
						new element_artwork(artwork, trackDetails.artworkUrl60, image_id);
					}
					else if(trackDetails.artworkUrl30 != null){
						new element_artwork(artwork, trackDetails.artworkUrl30, image_id);
					}
				}
			}
			resultsSignal.dispatch();
		}
	}
}