package com.edgington.model.facebook.opengraph.objects
{
	public interface IOpenGraphObject
	{
		function get title():String;
		function set title(title:String):void;
		
		function get description():String;
		function set description(description:String):void;
		
		function get imageURL():String;
		function set imageURL(imageURL:String):void;
		
		function get objectType():String;
		function set objectType(objectType:String):void;
	}
}