package com.edgington.view.huds.elements
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.FacebookConstants;
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.types.DeviceTypes;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.vo.SmallListItemVO;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class element_sendItemSurround extends Sprite
	{
		
		private var ipadSendItemSurround:ui_sendItemScreenIpad;
		private var iphoneSendItemSurround:ui_sendItemScreenIphone;
		
		private var items:Vector.<SmallListItemVO>;
		
		private var userProfilePicture:ui_profile_picture;
		private var friendProfilePic:Vector.<ui_profile_picture>;
		
		private var userProfilePicElement:element_profile_picture;
		private var friendsProfilePicElement:Vector.<element_profile_picture>;
		
		private var currentFriendsLoadedInPictures:Vector.<String>;
		
		private var maximumUsers:int = 0;
		private var selectedUsers:int = 0;
		
		public function element_sendItemSurround()
		{
			super();
			
			addListeners();
			
			setupVisuals();
		}
		
		private function addListeners():void{
			currentFriendsLoadedInPictures = new Vector.<String>;
			items = new Vector.<SmallListItemVO>;
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		private function setupVisuals():void{
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
				iphoneSendItemSurround = new ui_sendItemScreenIphone();
				iphoneSendItemSurround.y += 50;
				this.addChild(iphoneSendItemSurround);
			}
			else{
				ipadSendItemSurround = new ui_sendItemScreenIpad();
				userProfilePicture = ipadSendItemSurround.img_you;
				friendProfilePic = new Vector.<ui_profile_picture>;
				friendProfilePic.push(ipadSendItemSurround.img_friend_1);
				friendProfilePic.push(ipadSendItemSurround.img_friend_2);
				
//				if(FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
//					userProfilePicElement = new element_profile_picture(userProfilePicture, FacebookConstants.DEBUG_USER_ID); 	
//				}
				if(FacebookManager.getInstance().checkIfUserIsLoggedIn()){
					userProfilePicElement = new element_profile_picture(userProfilePicture, FacebookManager.getInstance().currentLoggedInUser.id);
				}
				
				friendsProfilePicElement = new Vector.<element_profile_picture>;
				for(var i:int = 0; i < friendProfilePic.length; i++){
					friendsProfilePicElement.push(new element_profile_picture(friendProfilePic[i]));
				}
				ipadSendItemSurround.x = 23//*DynamicConstants.DEVICE_SCALE; //We dont need this because the scale is set outside of this class.
				this.addChild(ipadSendItemSurround);
			}
		}
		
		public function setMaximumUsers(maxUsers:int):void{
			maximumUsers = maxUsers;
			updateUserCountText();
		}
		
		private function updateUserCountText():void{
			if(ipadSendItemSurround != null){
				ipadSendItemSurround.txt_number_friends.text = gettext("send_freinds_count", {selected:selectedUsers, maximum:maximumUsers});
			}
			else if(iphoneSendItemSurround != null){
				iphoneSendItemSurround.txt_num_friends.text = gettext("send_freinds_count", {selected:selectedUsers, maximum:maximumUsers});
			}
		}
		
		public function addItem(item:SmallListItemVO):void{
			items.push(item);
			if(DynamicConstants.DEVICE_TYPE != DeviceTypes.IPHONE){
				if(currentFriendsLoadedInPictures.length < friendsProfilePicElement.length){
					for(var i:int = 0; i < friendsProfilePicElement.length; i++){
						if(friendsProfilePicElement[i].profileID == ""){
							friendsProfilePicElement[i].changeImage(item.id);
							break;
						}
					}
					currentFriendsLoadedInPictures.push(item.id);
				}
			}
			selectedUsers = items.length;
			updateUserCountText();
		}
		
		public function removeItem(item:SmallListItemVO):void{
			for(var i:int = 0; i < items.length; i++){
				if(items[i].id == item.id){
					if(DynamicConstants.DEVICE_TYPE != DeviceTypes.IPHONE){
						for(var p:int = 0; p < friendsProfilePicElement.length; p++){
							if(friendsProfilePicElement[p].profileID == item.id){
								friendsProfilePicElement[p].changeImage("");
								break;
							}
						}
						for(var c:int = 0; c < currentFriendsLoadedInPictures.length; c++){
							if(currentFriendsLoadedInPictures[c] == item.id){
								currentFriendsLoadedInPictures.splice(c, 1);
								break;
							}
						}
					}
					items.splice(i, 1);
					break;
				}
			}
			selectedUsers = items.length;
			updateUserCountText();
		}
		
		public function removeAll():void{
			
			selectedUsers = 0;
			
			if(DynamicConstants.DEVICE_TYPE != DeviceTypes.IPHONE){
				for(var i:int = 0; i < friendProfilePic.length; i++){
					friendsProfilePicElement[i].changeImage("");
				}
			}
			
			currentFriendsLoadedInPictures = new Vector.<String>;
			items = new Vector.<SmallListItemVO>;
		}
		
		private function destroy(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
		}
	}
}