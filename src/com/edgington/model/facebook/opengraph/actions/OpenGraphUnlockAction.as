package com.edgington.model.facebook.opengraph.actions
{
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.model.facebook.opengraph.objects.IOpenGraphObject;
	import com.edgington.model.facebook.opengraph.types.ActionTypes;
	
	public class OpenGraphUnlockAction implements IOpenGraphAction
	{
		
		private var _actionType:String = ActionTypes.OPEN_GRAPH_UNLOCK_ACTION;
		private var _actionObject:IOpenGraphObject;
		
		private var _explicitlyShared:Boolean;
		
		public function OpenGraphUnlockAction(openGraphObject:IOpenGraphObject, explicitlyShared:Boolean = false)
		{
			actionObject = openGraphObject;
			this.explicitlyShared = explicitlyShared;
			FacebookManager.getInstance().updateActivity(this);
		}
		
		public function get explicitlyShared():Boolean
		{
			return _explicitlyShared;
		}
		
		public function set explicitlyShared(value:Boolean):void
		{
			_explicitlyShared = value;
		}
		
		public function get actionObject():IOpenGraphObject
		{
			return _actionObject;
		}
		
		public function set actionObject(value:IOpenGraphObject):void
		{
			_actionObject = value;
		}
		
		public function get actionType():String
		{
			return _actionType;
		}
		
		public function set actionType(value:String):void
		{
			_actionType = value;
		}
	}
}