package com.edgington.net.helpers
{
	public class NetResponceHandler
	{
		
		public var succesful:Function;
		public var failed:Function;
		
		public function NetResponceHandler(succesful:Function, failed:Function)
		{
			this.succesful = succesful;
			this.failed = succesful;
		}
	}
}