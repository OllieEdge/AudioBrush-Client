package com.edgington.view.assets
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.geom.Rectangle;

	public class CacheVO
	{
		public var positionOfImage:Rectangle;
		public var cacheID:String;
		public var cacheURL:String;
		public var parentToAddTo:DisplayObjectContainer;
		public var loader:Loader;
	}
}