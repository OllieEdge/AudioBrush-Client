package com.edgington.valueobjects
{
	import com.edgington.ipodlibrary.ILMediaItem;

	public class AudioBrushMediaItemVO
	{
		public var trackURL:String;
		public var difficulty:String;
		public var playCount:int;
		public var isLoaded:Boolean;
		public var trackID:String;
		
		public var trackDetails:ILMediaItem;
		
		public function AudioBrushMediaItemVO(rawData:Object = null)
		{
			if(rawData != null){
				for(var key:String in rawData){
					if(key != "trackDetails"){
						this[key] = rawData[key];
					}
				}
			}
		}
	}
}