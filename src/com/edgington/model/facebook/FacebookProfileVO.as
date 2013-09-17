package com.edgington.model.facebook
{
	import com.milkmangames.nativeextensions.GVFacebookFriend;

	public class FacebookProfileVO
	{
		
		public var profileID:String;
		public var gender:String;
		public var installed:Boolean;
		public var firstName:String;
		public var lastName:String;
		
		public var rawFacebookData:GVFacebookFriend;
		
		public function FacebookProfileVO(facebookProfile:GVFacebookFriend = null, rawData:Object = null)
		{
			if(facebookProfile != null){
				rawFacebookData = facebookProfile;
				profileID = facebookProfile.id;
				gender = facebookProfile.gender;
				installed = facebookProfile.installed;
				firstName = facebookProfile.properties.first_name;
				lastName = facebookProfile.properties.last_name;
			}
			else if(rawData != null){
				profileID = rawData.id;
				gender = rawData.gender;
				installed = true;
				firstName = rawData.first_name;
				lastName = rawData.last_name;
			}
		}
	}
}