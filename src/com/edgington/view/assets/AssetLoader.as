package com.edgington.view.assets
{
	import com.edgington.types.AssetType;
	import com.edgington.util.debug.LOG;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.core.LoaderCore;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	public class AssetLoader extends EventDispatcher
	{
		
		private static var INSTANCE:AssetLoader
		
		private var imagesXML:XML;
		private var imageLoader:URLLoader;
		
		private static var _imageDictionary:Dictionary;
		
		private var mainLoader:LoaderMax;
		
		public var isLoaded:Boolean = false;
		public var errorLoading:Boolean = false;
		
		public function AssetLoader()
		{
			AssetLoader._imageDictionary = new Dictionary();
			mainLoader = new LoaderMax({onChildComplete:loadComplete, onChildFail:loadFailed, onComplete:allLoadsComplete});
			mainLoader.autoLoad = true;
			
			var myXML:XML;
			imageLoader = new URLLoader();
			imageLoader.addEventListener(Event.COMPLETE , processImageXML);
			imageLoader.load(new URLRequest("assets/images/bitmapAssetList.xml")); // Path to xml file
		}
		
		private function processImageXML(e:Event):void{
			imagesXML = new XML(e.target.data);
			for(var i:int = 0; i < imagesXML.bitmap.length(); i++){
				var assetVO:AssetVO = new AssetVO();
				assetVO.assetID = imagesXML.bitmap[i].assetID;
				assetVO.assetURL = imagesXML.bitmap[i].url;
				assetVO.assetType = AssetType.IMAGE;
				addLoader(assetVO);
			}
		}
		
		private function addLoader(assetVO:AssetVO):void{
			switch(assetVO.assetType){
				case AssetType.IMAGE:
					var imageLoader:ImageLoader = new ImageLoader(assetVO.assetURL, {assetVO:assetVO});
					mainLoader.append(imageLoader);
					break;
				default:
					LOG.fatal("AssetType not implemented in addLoader method");
					break;
			}
		}
		
		private function loadComplete(e:LoaderEvent):void{
			switch(LoaderCore(e.target).vars.assetVO.assetType){
				case AssetType.IMAGE:
					AssetLoader._imageDictionary[LoaderCore(e.target).vars.assetVO.assetID] = e.target.rawContent.bitmapData.clone();
					break;
				default:
					LOG.fatal("AssetType not implemented in loadComplete method");
					break;
			}
		}
		
		private function loadFailed(e:LoaderEvent):void{
			LOG.error("Failed Loading an Asset");
			errorLoading = true;
		}
		
		private function allLoadsComplete(e:LoaderEvent):void{
			dispatchEvent(new Event(Event.COMPLETE));
			isLoaded = true;
		}
		
		public static function get imageDictionary():Dictionary{
			return _imageDictionary;
		}
		
		public static function getInstance():AssetLoader{
			if(INSTANCE == null){
				INSTANCE = new AssetLoader();
			}
			return INSTANCE;
		}
	}
}