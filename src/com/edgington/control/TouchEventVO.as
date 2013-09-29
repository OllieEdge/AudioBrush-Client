package com.edgington.control
{
	public class TouchEventVO
	{
		public var touchID:int = 0;
		public var x:int = 0;
		public var y:int = 0;
		
		public function TouchEventVO(touchID:int, x:int, y:int){
			this.touchID = touchID;
			this.x = x;
			this.y = y;
		}
	}
}