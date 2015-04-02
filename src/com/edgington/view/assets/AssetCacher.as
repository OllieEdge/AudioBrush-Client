package com.edgington.view.assets
{
	import com.edgington.util.debug.LOG;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class AssetCacher
	{
		
		private static var INSTANCE:AssetCacher;
		
		private var CACHE_DIRECTORY:String;
		
		private var _imageDictionary:Dictionary;
		
		private var fileFormat:String = ".abic";
		
		private var mainLoader:LoaderMax;
		
		private var loadByteQueue:Vector.<CacheVO>;
		
		public function AssetCacher()
		{
			LOG.create(AssetCacher);
			
			CACHE_DIRECTORY = File.cacheDirectory.url;
			
			PNGEncoder2.level = CompressionLevel.FAST;
			
			_imageDictionary = new Dictionary();
			
			loadByteQueue = new Vector.<CacheVO>;
			
			mainLoader = new LoaderMax({onChildComplete:loadComplete, onChildFail:loadFailed, onComplete:allLoadsComplete});
			mainLoader.autoLoad = true;
			
			var cacheDirectory:File = new File(CACHE_DIRECTORY + "/audiobrush/imagecache");
			if(!cacheDirectory.isDirectory){
				cacheDirectory.createDirectory();
			}
		}
		
		public function checkForCachedImage(image_id:String):Boolean{
			var cacheFile:File = new File(CACHE_DIRECTORY + "/audiobrush/imagecache/"+ image_id + fileFormat);
			
			return cacheFile.exists;
		}
		
		public function saveImage(image_id, loadContent:ByteArray):void{
			var saveFile:File = new File(CACHE_DIRECTORY+ "/audiobrush/imagecache");
			saveFile = saveFile.resolvePath(image_id + fileFormat);
			if(saveFile.exists){
				saveFile.deleteFile();
			}
			var fs:FileStream = new FileStream();
			fs.open(saveFile , FileMode.WRITE);
			fs.writeBytes(loadContent);
			fs.close();
			
			LOG.debug("Saved Cached Image to disk");
		}
		
		public static function getInstance():AssetCacher{
			if(INSTANCE == null){
				INSTANCE = new AssetCacher();
			}
			return INSTANCE;
		}
		
		public function insertCachedImage(image_id:String, parentToAddTo:DisplayObjectContainer, positionOfImage:Rectangle):void{
			
			var cacheVO:CacheVO = new CacheVO();
			cacheVO.positionOfImage = positionOfImage;
			cacheVO.cacheID = image_id;
			cacheVO.cacheURL = CACHE_DIRECTORY + "/audiobrush/imagecache/"+ image_id + fileFormat;
			cacheVO.parentToAddTo = parentToAddTo;
			
			if(_imageDictionary[image_id]){
				addBitmap(cacheVO);
				LOG.debug("Loaded Memory Cached Image");
				return;
			}
			
			var imageLoader:ImageLoader = new ImageLoader(cacheVO.cacheURL, {cacheVO:cacheVO});
			mainLoader.append(imageLoader);
		}
		
		private function loadComplete(e:LoaderEvent):void{
			
			_imageDictionary[e.target.vars.cacheVO.cacheID] = e.target.rawContent.bitmapData.clone();
			addBitmap(e.target.vars.cacheVO);
//			var context:LoaderContext = new LoaderContext();
//			context.allowCodeImport = false;
//			context.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
//			
//			var cacheVO:CacheVO = LoaderCore(e.target).vars.cacheVO;
//			cacheVO.loader = new Loader();
//			
//			loadByteQueue.push(cacheVO);
			
//			cacheVO.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderComplete);
//			cacheVO.loader.loadBytes(e.target.content, context);
		}
		private function loaderComplete(e:Event):void{
			for(var i:int = 0; i < loadByteQueue.length; i++){
				if(e.target.loader == loadByteQueue[i].loader){
					
					loadByteQueue[i].loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderComplete);
					
					var bmd:BitmapData = new BitmapData(e.target.content.width, e.target.content.height, false);
					bmd.draw(e.target.content);
					_imageDictionary[loadByteQueue[i].cacheID] = bmd.clone();
					
					addBitmap(loadByteQueue[i]);
					loadByteQueue.splice(i, 1);
					
					LOG.debug("Loaded Disk Cached Image");
					break;
				}
			}
		}
		
		private function addBitmap(cacheVO:CacheVO):void{
			var bm:Bitmap = new Bitmap(BitmapData(_imageDictionary[cacheVO.cacheID]).clone());
			bm.x = cacheVO.positionOfImage.x;
			bm.y = cacheVO.positionOfImage.y;
			bm.width = cacheVO.positionOfImage.width;
			bm.height = cacheVO.positionOfImage.height;
			cacheVO.parentToAddTo.addChild(bm);
			cacheVO = null;
		}
		
		private function loadFailed(e:LoaderEvent):void{
			LOG.error("Failed Loading an Asset");
		}
		
		private function allLoadsComplete(e:LoaderEvent):void{
			LOG.debug("Image Cacher, all images loaded");
		}
		
		public static function CLEAR_MEMORY():void{
			if(INSTANCE != null){
				for(var str:String in INSTANCE._imageDictionary){
					INSTANCE._imageDictionary[str].dispose();
				}
				INSTANCE._imageDictionary = new Dictionary();
			}
		}
	}
}