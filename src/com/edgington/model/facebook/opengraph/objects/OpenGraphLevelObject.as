package com.edgington.model.facebook.opengraph.objects
{
	import com.edgington.model.facebook.opengraph.types.ObjectTypes;
	
	public class OpenGraphLevelObject implements IOpenGraphObject
	{
		
		private var _title:String;
		private var _description:String;
		private var _imageURL:String;
		private var _objectType:String = ObjectTypes.OPEN_GRAPH_RANK_OBJECT;
		
		public function OpenGraphLevelObject(title:String, description:String, imageURL:String)
		{
			this.title = title;
			this.description = description;
			this.imageURL = imageURL;
		}
		
		public function get objectType():String
		{
			return _objectType;
		}
		
		public function set objectType(value:String):void
		{
			_objectType = value;
		}
		
		public function get imageURL():String
		{
			return _imageURL;
		}
		
		public function set imageURL(value:String):void
		{
			_imageURL = value;
		}
		
		public function get description():String
		{
			return _description;
		}
		
		public function set description(value:String):void
		{
			_description = value;
		}
		
		public function get title():String
		{
			return _title;
		}
		
		public function set title(value:String):void
		{
			_title = value;
		}
	}
}