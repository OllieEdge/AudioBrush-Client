package com.edgington.model.facebook
{
	import com.milkmangames.nativeextensions.GVFacebookFriend;

	public class FacebookProfileVO
	{
		
		public var id:String;
		public var gender:String;
		public var installed:Boolean;
		public var name:String;
		
		public var rawFacebookData:GVFacebookFriend;
		
		public function FacebookProfileVO(facebookProfile:GVFacebookFriend = null, rawData:Object = null)
		{
			if(facebookProfile != null){
				rawFacebookData = facebookProfile;
				id = facebookProfile.id;
				gender = facebookProfile.gender;
				installed = facebookProfile.installed;
				name = facebookProfile.name;
			}
			else if(rawData != null){
				rawFacebookData =  new GVFacebookFriend(rawData.name, rawData.id, rawData);
				id = rawData.id;
				gender = rawData.gender;
				installed = true;
				name = rawData.name;
			}
		}
	}
}