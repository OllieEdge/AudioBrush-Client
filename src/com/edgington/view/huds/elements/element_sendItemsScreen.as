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
	
	import org.osflash.signals.Signal;
	
	public class element_sendItemsScreen extends Sprite
	{
		
		private var friendsList:element_smallList;
		public var friendsSelectedList:element_smallList;
		
		private var sendItemSurround:element_sendItemSurround;
		
		private var audioBrushOnlyTickBox:element_tickBoxWithText;
		
		private var friends:Vector.<SmallListItemVO>;
		
		private var nonSelectedFriendsSignal:Signal;
		private var selectedFriendsSignal:Signal;
		
		private var _height:int;
		private var _width:int;
		
		private var tickBoxSignal:Signal;
		
		private var sendButtonSignal:Signal;
		private var sendButtonOn:Boolean = false;
		
		public function element_sendItemsScreen(_width:int, _height:int, sendButtonSignal:Signal)
		{
			super();
			
			this._width = _width;
			this._height = _height;
			this.sendButtonSignal = sendButtonSignal;
			
			addListeners();
			
			friends = new Vector.<SmallListItemVO>;
//			if(FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
//				friends = new Vector.<SmallListItemVO>;
//				friends.push(new SmallListItemVO("Natasha Ancel", "899295388"));
//				friends.push(new SmallListItemVO("Hailz Anne Campbell", "694881083"));
//				friends.push(new SmallListItemVO("Grace Ann Rowland", "508274951"));
//				friends.push(new SmallListItemVO("Adam Scott", "1075321660"));
//				friends.push(new SmallListItemVO("Nikos Asfis", "1609420253"));
//				friends.push(new SmallListItemVO("Luke Armstrong", "503608430"));
//				friends.push(new SmallListItemVO("Katie Anne", "1056784533"));
//				friends.push(new SmallListItemVO("Elliot A King", "514180110"));
//				friends.push(new SmallListItemVO("Afsana Choudhury", "100001789641254"));
//				friends.push(new SmallListItemVO("Robert Andrew Adams", "797308306"));
//				friends.push(new SmallListItemVO("Alex Bentley", "516832798"));
//				friends.push(new SmallListItemVO("Annie Bell-Carfrae", "743930439"));
//				friends.push(new SmallListItemVO("Anna Nguyen", "819690230"));
//				friends.push(new SmallListItemVO("Daryl Armstrong", "517927632"));
//				friends.push(new SmallListItemVO("Lauren Anneyce", "531362131"));
//				friends.push(new SmallListItemVO("Caren Armstrong", "604960549"));
//				friends.push(new SmallListItemVO("Astrid Lily Whan", "514088532"));
//				friends.push(new SmallListItemVO("Anna Lloyd", "506926528"));
//				friends.push(new SmallListItemVO("Akshay Khullar", "720145760"));
//			}
//			else{
				for(var i:int = 0; i < FacebookManager.getInstance().currentLoggedInUserFriends.length; i++){
					friends.push(new SmallListItemVO( FacebookManager.getInstance().currentLoggedInUserFriends[i].name,  FacebookManager.getInstance().currentLoggedInUserFriends[i].id));
				}
//			}			
			
			setupVisuals();
			
		}
		
		private function addListeners():void{
			tickBoxSignal = new Signal();
			tickBoxSignal.add(handleTickBox);
			nonSelectedFriendsSignal = new Signal();
			nonSelectedFriendsSignal.add(handleNonSelectedFriendSelected);
			selectedFriendsSignal = new Signal();
			selectedFriendsSignal.add(handleSelectedFriendSelected);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		private function setupVisuals():void{
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
				friendsList = new element_smallList(friends, 8, 30*DynamicConstants.DEVICE_SCALE, 326*DynamicConstants.DEVICE_SCALE, nonSelectedFriendsSignal);
			}
			else{
				friendsList = new element_smallList(friends, 8, 23*DynamicConstants.DEVICE_SCALE, 326*DynamicConstants.DEVICE_SCALE, nonSelectedFriendsSignal);
			}
			friendsList.x = DynamicConstants.BUTTON_SPACING;
			friendsList.y = _height - DynamicConstants.BUTTON_SPACING - friendsList.height;
			
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
				friendsSelectedList = new element_smallList(new Vector.<SmallListItemVO>, 6, 30*DynamicConstants.DEVICE_SCALE, 326*DynamicConstants.DEVICE_SCALE, selectedFriendsSignal);
			}
			else{
				friendsSelectedList = new element_smallList(new Vector.<SmallListItemVO>, 6, 23*DynamicConstants.DEVICE_SCALE, 326*DynamicConstants.DEVICE_SCALE, selectedFriendsSignal);
			}
			friendsSelectedList.x = _width - DynamicConstants.BUTTON_SPACING - friendsSelectedList.width;
			friendsSelectedList.y = friendsList.y;
			
			sendItemSurround = new element_sendItemSurround();
			sendItemSurround.setMaximumUsers(friends.length);
			
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPAD){
				sendItemSurround.scaleX = sendItemSurround.scaleY = DynamicConstants.MESSAGE_SCALE;
				sendItemSurround.y = DynamicConstants.BUTTON_SPACING;
			}
			sendItemSurround.x = (_width*.5) - (sendItemSurround.width*.5);
			
			audioBrushOnlyTickBox = new element_tickBoxWithText(gettext("send_freinds_audiobrush_only"), tickBoxSignal, false);
			audioBrushOnlyTickBox.scaleX = audioBrushOnlyTickBox.scaleY = DynamicConstants.DEVICE_SCALE;
			audioBrushOnlyTickBox.x = friendsSelectedList.x;
			audioBrushOnlyTickBox.y = friendsSelectedList.y + friendsSelectedList.height + DynamicConstants.BUTTON_SPACING;
			
			this.addChild(sendItemSurround);
			this.addChild(friendsList);
			this.addChild(friendsSelectedList);
			this.addChild(audioBrushOnlyTickBox);
		}
		
		private function handleSelectedFriendSelected(item:SmallListItemVO):void{
			friendsSelectedList.removeItem(item);
			item.ticked = false;
			friendsList.addItem(item);
			sendItemSurround.removeItem(item);
			if(sendButtonOn && friendsSelectedList.itemList.length == 0){
				sendButtonOn = false;
				sendButtonSignal.dispatch(sendButtonOn);
			}
		}
		
		private function handleNonSelectedFriendSelected(item:SmallListItemVO):void{
			friendsList.removeItem(item);
			item.ticked = true;
			friendsSelectedList.addItem(item);
			sendItemSurround.addItem(item);
			if(!sendButtonOn){
				sendButtonOn = true;
				sendButtonSignal.dispatch(sendButtonOn);
			}
		}
		
		private function handleTickBox():void{
			var i:int = 0;
			friends = new Vector.<SmallListItemVO>;
			if(audioBrushOnlyTickBox.TICKED){
//				if(FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
//					friends.push(new SmallListItemVO("Natasha Ancel", "899295388"));
//					friends.push(new SmallListItemVO("Hailz Anne Campbell", "694881083"));
//					friends.push(new SmallListItemVO("Grace Ann Rowland", "508274951"));
//					friends.push(new SmallListItemVO("Adam Scott", "1075321660"));
//					friends.push(new SmallListItemVO("Nikos Asfis", "1609420253"));
//				}
//				else{
					for(i = 0; i < FacebookManager.getInstance().currentLoggedInUserFriendsWithInstall.length; i++){
						friends.push(new SmallListItemVO( FacebookManager.getInstance().currentLoggedInUserFriendsWithInstall[i].rawFacebookData.name,  FacebookManager.getInstance().currentLoggedInUserFriendsWithInstall[i].rawFacebookData.id));
					}
//				}			
			}
			else{
//				if(FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
//					friends.push(new SmallListItemVO("Natasha Ancel", "899295388"));
//					friends.push(new SmallListItemVO("Hailz Anne Campbell", "694881083"));
//					friends.push(new SmallListItemVO("Grace Ann Rowland", "508274951"));
//					friends.push(new SmallListItemVO("Adam Scott", "1075321660"));
//					friends.push(new SmallListItemVO("Nikos Asfis", "1609420253"));
//					friends.push(new SmallListItemVO("Luke Armstrong", "503608430"));
//					friends.push(new SmallListItemVO("Katie Anne", "1056784533"));
//					friends.push(new SmallListItemVO("Elliot A King", "514180110"));
//					friends.push(new SmallListItemVO("Afsana Choudhury", "100001789641254"));
//					friends.push(new SmallListItemVO("Robert Andrew Adams", "797308306"));
//					friends.push(new SmallListItemVO("Alex Bentley", "516832798"));
//					friends.push(new SmallListItemVO("Annie Bell-Carfrae", "743930439"));
//					friends.push(new SmallListItemVO("Anna Nguyen", "819690230"));
//					friends.push(new SmallListItemVO("Daryl Armstrong", "517927632"));
//					friends.push(new SmallListItemVO("Lauren Anneyce", "531362131"));
//					friends.push(new SmallListItemVO("Caren Armstrong", "604960549"));
//					friends.push(new SmallListItemVO("Astrid Lily Whan", "514088532"));
//					friends.push(new SmallListItemVO("Anna Lloyd", "506926528"));
//					friends.push(new SmallListItemVO("Akshay Khullar", "720145760"));
//				}
//				else{
					for(i = 0; i < FacebookManager.getInstance().currentLoggedInUserFriends.length; i++){
						friends.push(new SmallListItemVO( FacebookManager.getInstance().currentLoggedInUserFriends[i].name,  FacebookManager.getInstance().currentLoggedInUserFriends[i].id));
					}
//				}
			}
			
			this.removeChild(friendsList);
			this.removeChild(friendsSelectedList);
			friendsList = null;
			friendsSelectedList = null;
			nonSelectedFriendsSignal.removeAll();
			nonSelectedFriendsSignal = null;
			selectedFriendsSignal.removeAll();
			selectedFriendsSignal = null;
			
			nonSelectedFriendsSignal = new Signal();
			nonSelectedFriendsSignal.add(handleNonSelectedFriendSelected);
			selectedFriendsSignal = new Signal();
			selectedFriendsSignal.add(handleSelectedFriendSelected);
			
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
				friendsList = new element_smallList(friends, 8, 30*DynamicConstants.DEVICE_SCALE, 326*DynamicConstants.DEVICE_SCALE, nonSelectedFriendsSignal);
			}
			else{
				friendsList = new element_smallList(friends, 8, 23*DynamicConstants.DEVICE_SCALE, 326*DynamicConstants.DEVICE_SCALE, nonSelectedFriendsSignal);
			}
			friendsList.x = DynamicConstants.BUTTON_SPACING;
			friendsList.y = _height - DynamicConstants.BUTTON_SPACING - friendsList.height;
			
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
				friendsSelectedList = new element_smallList(new Vector.<SmallListItemVO>, 6, 30*DynamicConstants.DEVICE_SCALE, 326*DynamicConstants.DEVICE_SCALE, selectedFriendsSignal);;
			}
			else{
				friendsSelectedList = new element_smallList(new Vector.<SmallListItemVO>, 6, 23*DynamicConstants.DEVICE_SCALE, 326*DynamicConstants.DEVICE_SCALE, selectedFriendsSignal);
			}
			friendsSelectedList.x = _width - DynamicConstants.BUTTON_SPACING - friendsSelectedList.width;
			friendsSelectedList.y = friendsList.y;
			
			sendItemSurround.removeAll();
			sendItemSurround.setMaximumUsers(friends.length);
			
			this.addChild(friendsList);
			this.addChild(friendsSelectedList);
			
			if(sendButtonOn && friendsSelectedList.itemList.length == 0){
				sendButtonOn = false;
				sendButtonSignal.dispatch(sendButtonOn);
			}

		}
		
		private function destroy(e:Event):void{
			sendButtonSignal = null;
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			nonSelectedFriendsSignal.removeAll();
			nonSelectedFriendsSignal = null;
			tickBoxSignal.removeAll();
			tickBoxSignal = null;
			selectedFriendsSignal.removeAll();
			selectedFriendsSignal = null;
			friendsList = null;
			friends = null;
		}
	}
}