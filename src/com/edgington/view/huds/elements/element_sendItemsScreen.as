package com.edgington.view.huds.elements
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.FacebookConstants;
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.view.huds.vo.SmallListItemVO;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class element_sendItemsScreen extends Sprite
	{
		
		private var friendsList:element_smallList;
		private var friendsSelectedList:element_smallList;
		
		private var friends:Vector.<SmallListItemVO>;
		
		private var nonSelectedFriendsSignal:Signal;
		private var selectedFriendsSignal:Signal;
		
		private var _height:int;
		private var _width:int;
		
		public function element_sendItemsScreen(_width:int, _height:int)
		{
			super();
			
			this._width = _width;
			this._height = _height;
			
			addListeners();
			
			friends = new Vector.<SmallListItemVO>;
			if(FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
				friends = new Vector.<SmallListItemVO>;
				friends.push(new SmallListItemVO("Natasha Ancel", "id1"));
				friends.push(new SmallListItemVO("Hailz Anne Campbell", "id2"));
				friends.push(new SmallListItemVO("Grace Ann Rowland", "id3"));
				friends.push(new SmallListItemVO("Adam Scott", "id4"));
				friends.push(new SmallListItemVO("Nikos Asfis", "id5"));
				friends.push(new SmallListItemVO("Luke Armstrong", "id6"));
				friends.push(new SmallListItemVO("Katie Anne", "id7"));
				friends.push(new SmallListItemVO("Elliot A King", "id8"));
				friends.push(new SmallListItemVO("Afsana Choudhury", "id9"));
				friends.push(new SmallListItemVO("Robert Andrew Adams", "id10"));
				friends.push(new SmallListItemVO("Alex Bentley", "id11"));
				friends.push(new SmallListItemVO("Annie Bell-Carfrae", "id12"));
				friends.push(new SmallListItemVO("Anna Nguyen", "id13"));
				friends.push(new SmallListItemVO("Daryl Armstrong", "id14"));
				friends.push(new SmallListItemVO("Lauren Anneyce", "id15"));
				friends.push(new SmallListItemVO("Caren Armstrong", "id16"));
				friends.push(new SmallListItemVO("Astrid Lily Whan", "id17"));
				friends.push(new SmallListItemVO("Anna Lloyd", "id18"));
				friends.push(new SmallListItemVO("Akshay Khullar", "id19"));
			}
			else{
				for(var i:int = 0; i < FacebookManager.getInstance().currentLoggedInUserFriends.length; i++){
					friends.push(new SmallListItemVO( FacebookManager.getInstance().currentLoggedInUserFriends[i].name,  FacebookManager.getInstance().currentLoggedInUserFriends[i].id));
				}
			}			
			
			setupVisuals();
			
		}
		
		private function addListeners():void{
			nonSelectedFriendsSignal = new Signal();
			nonSelectedFriendsSignal.add(handleNonSelectedFriendSelected);
			selectedFriendsSignal = new Signal();
			selectedFriendsSignal.add(handleSelectedFriendSelected);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		private function setupVisuals():void{
			friendsList = new element_smallList(friends, 8, 26, 326, nonSelectedFriendsSignal);
			friendsList.x = DynamicConstants.BUTTON_SPACING;
			friendsList.y = _height - DynamicConstants.BUTTON_SPACING - friendsList.height;
			
			friendsSelectedList = new element_smallList(new Vector.<SmallListItemVO>, 6, 26, 326, selectedFriendsSignal);
			friendsSelectedList.x = _width - DynamicConstants.BUTTON_SPACING - friendsSelectedList.width;
			friendsSelectedList.y = friendsList.y;
			
			this.addChild(friendsList);
			this.addChild(friendsSelectedList);
		}
		
		private function handleSelectedFriendSelected(item:SmallListItemVO):void{
			friendsSelectedList.removeItem(item);
			item.ticked = false;
			friendsList.addItem(item);
		}
		
		private function handleNonSelectedFriendSelected(item:SmallListItemVO):void{
			friendsList.removeItem(item);
			item.ticked = true;
			friendsSelectedList.addItem(item);
		}
		
		private function destroy(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			nonSelectedFriendsSignal.removeAll();
			nonSelectedFriendsSignal = null;
			selectedFriendsSignal.removeAll();
			selectedFriendsSignal = null;
			friendsList = null;
			friends = null;
		}
	}
}