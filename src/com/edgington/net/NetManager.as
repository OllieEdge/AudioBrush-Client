package com.edgington.net
{
	import com.edgington.util.debug.LOG;
	
	import flash.net.NetConnection;
	
	import org.osflash.signals.Signal;

	public class NetManager
	{
		
		private static var INSTANCE:NetManager;
		
		public var netConnection:NetConnection;
		
		public static var CORE_URL:String = "http://api.audiobrush.com:3000/api/";//"http://82.10.100.127:3000/api/"
		private static const CORE_API:String = "v1"
		
		public var serverConnectionErrorSignal:Signal;
		
		public function NetManager()
		{
			LOG.create(this);
			LOG.server("Connected to: " + CORE_URL);
		}
		
		public static function getURL():String{
			var str:String = CORE_URL + CORE_API;
			return str;
		}
	
		public static function getInstance():NetManager{
			if(INSTANCE == null){
				INSTANCE = new NetManager();
			}
			return INSTANCE;
		}
	}
}