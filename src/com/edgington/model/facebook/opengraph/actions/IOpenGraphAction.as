package com.edgington.model.facebook.opengraph.actions
{
	import com.edgington.model.facebook.opengraph.objects.IOpenGraphObject;

	public interface IOpenGraphAction
	{
		function get actionType():String;
		function set actionType(actionType:String):void;
		
		function get actionObject():IOpenGraphObject;
		function set actionObject(actionObject:IOpenGraphObject):void;
		
		function get explicitlyShared():Boolean;
		function set explicitlyShared(explicitlyShared:Boolean):void;
	}
}