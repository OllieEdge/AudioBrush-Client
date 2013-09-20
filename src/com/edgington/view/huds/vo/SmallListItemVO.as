package com.edgington.view.huds.vo
{
	public class SmallListItemVO
	{
		public var label:String;
		public var id:String;
		public var ticked:Boolean;
		
		public function SmallListItemVO(label:String, id:String, ticked:Boolean = false){
			this.label = label;
			this.id = id;
			this.ticked = ticked;
		}
	}
}