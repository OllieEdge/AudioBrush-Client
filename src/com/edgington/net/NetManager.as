package com.edgington.net
{
	import com.edgington.util.debug.LOG;
	
	import flash.net.NetConnection;
	
	import org.osflash.signals.Signal;

	public class NetManager
	{
		
		private static var INSTANCE:NetManager;
		
		public var netConnection:NetConnection;
		
		private static const CORE_URL:String = "http://192.168.33.10:3000/api/";
		private static const CORE_API:String = "v1"
		
		public var serverConnectionErrorSignal:Signal;
		
		public function NetManager()
		{
			LOG.create(this);
			
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