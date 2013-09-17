package com.edgington.model.facebook
{
	import com.edgington.constants.FacebookConstants;
	import com.edgington.model.facebook.opengraph.actions.IOpenGraphAction;
	import com.edgington.model.facebook.opengraph.types.ObjectTypes;
	import com.milkmangames.nativeextensions.GoViral;

	public class FacebookOpenGraphDispatcher
	{
		public function FacebookOpenGraphDispatcher()
		{
			
		}
		
		public function dispatchOpenGraphRequest(openGraphAction:IOpenGraphAction):void{
			var openGraphObject:Object = new Object();
			switch(openGraphAction.actionObject.objectType){
				case ObjectTypes.OPEN_GRAPH_TRACK_OBJECT:
					openGraphObject["fb:explicitly_shared"] = openGraphAction.explicitlyShared;
					openGraphObject[openGraphAction.actionObject.objectType] = FacebookConstants.OPEN_GRAPH_TRACK_OBJECT_URL + openGraphAction.actionObject.objectType + "&ABurl=http://google.com&ABtitle=" + openGraphAction.actionObject.title + "&ABimage=" + openGraphAction.actionObject.imageURL + "&ABdescription=" + openGraphAction.actionObject.description;
					break;
				case ObjectTypes.OPEN_GRAPH_HIGHSCORE_OBJECT:
					openGraphObject["fb:explicitly_shared"] = openGraphAction.explicitlyShared;
					openGraphObject[openGraphAction.actionObject.objectType] = FacebookConstants.OPEN_GRAPH_HIGHSCORE_OBJECT_URL + openGraphAction.actionObject.objectType + "&ABurl=http://google.com&ABtitle=" + openGraphAction.actionObject.title + "&ABimage=" + openGraphAction.actionObject.imageURL + "&ABdescription=" + openGraphAction.actionObject.description;
					break;
				case ObjectTypes.OPEN_GRAPH_RANK_OBJECT:
					openGraphObject["fb:explicitly_shared"] = openGraphAction.explicitlyShared;
					openGraphObject[openGraphAction.actionObject.objectType] = FacebookConstants.OPEN_GRAPH_RANK_OBJECT_URL + openGraphAction.actionObject.objectType + "&ABurl=http://google.com&ABtitle=" + openGraphAction.actionObject.title + "&ABimage=" + openGraphAction.actionObject.imageURL + "&ABdescription=" + openGraphAction.actionObject.description;
					break;
			}
			
			GoViral.goViral.facebookGraphRequest("me/audiobrush:"+openGraphAction.actionType, "POST", openGraphObject);
		}
	}
}