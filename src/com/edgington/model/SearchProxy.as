package com.edgington.model
{
	import com.edgington.NativeMediaManager.NativeMediaVO;
	import com.edgington.util.debug.LOG;

	public class SearchProxy
	{
		
		private static var INSTANCE:SearchProxy;
		
		public var currentSearch:String;
		public var isSearch:Boolean = false;
		
		public var currentTrack:NativeMediaVO
		
		public function SearchProxy()
		{
			LOG.create(this);
		}
		
		public static function getInstance():SearchProxy{
			if(INSTANCE == null){
				INSTANCE = new SearchProxy();
			}
			return INSTANCE;
		}
	}
}