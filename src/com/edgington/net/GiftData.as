package com.edgington.net
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.FacebookConstants;
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.model.facebook.FacebookProfileVO;
	import com.edgington.net.helpers.NetResponceHandler;
	import com.edgington.util.debug.LOG;
	import com.edgington.valueobjects.net.ServerGiftVO;
	import com.milkmangames.nativeextensions.GVFacebookRequestFilter;
	import com.milkmangames.nativeextensions.GoViral;
	import com.milkmangames.nativeextensions.events.GVFacebookEvent;
	
	import org.osflash.signals.Signal;
	
	public class GiftData extends BaseData
	{
		private static var INSTANCE:GiftData;
		
		public var gifts:Vector.<ServerGiftVO>;
		
		public var giftDataSignal:Signal;
		
		public var giftsSent:Boolean = false;
		private var friendsWithAccountStored:Array;
		private var friendsWithoutAccountStored:Array;
		private var facebookIDStored:String;
		private var creditsStored:int;
		private var productStored:String;
		private var productQuantityStored:int;
		
		public function GiftData()
		{
			LOG.create(this);
			super("gift", "gifts");
			giftDataSignal = new Signal();
			gifts = new Vector.<ServerGiftVO>;
		}
		
		/**
		 * Get all gifts for this user
		 */
		public function getGifts():void{
			if(DynamicConstants.IS_CONNECTED && FacebookManager.getInstance().checkIfUserIsLoggedIn() || FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
				GET(new NetResponceHandler(onGiftsReceived, onGiftsReceivedFailed), false,	UserData.getInstance().userProfile._id);
			}
		}
		
		/**
		 * When we press accept and send this is the method that will make the server handle it.
		 */
		public function acceptAndSend(gifts:Vector.<ServerGiftVO>):void{
			
			var giftIDs:Array = new Array();
			for(var i:int = 0; i < gifts.length; i++){
				giftIDs.push(gifts[i]._id);
			}
			
			var obj:Object = new Object();
			obj.giftids = giftIDs;
			
			POST(new NetResponceHandler(onAcceptAndSendComplete, onAcceptAndSendFailed), "", obj);
		}
		
		/**
		 * Post gifts to friends
		 */
		public function postGifts(friends:Vector.<String>, credits:int = 0, productID:String = "", productQuantity:int = 0):void{
			var facebookID:String = "";
			giftsSent = false;
			
			//From the parsed friends array this will contain all the ID's that have an AudioBrush account.
			var friendsWithAccount:Array = new Array();
			//From the parsed friends array this will contain all the ID's that do not have an AudioBrush account - 
			//this can be used to post a request to Facebook
			var friendsWithoutAccount:Array = new Array();
			
			if(DynamicConstants.IS_CONNECTED && FacebookManager.getInstance().checkIfUserIsLoggedIn() || FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
				if(FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
					facebookID = FacebookConstants.DEBUG_USER_ID;
					friendsWithAccount.push(FacebookConstants.DEBUG_USER_ID, 0);//This is Ollie
					friendsWithoutAccount.push("100005846082918");//This is Spok Reborn
				}
				else{
					//Store the friends wiht install so we dont have to reference the FBManager all the time.
					var actualFriendsWithInstall:Vector.<FacebookProfileVO> = new Vector.<FacebookProfileVO>;
					actualFriendsWithInstall = FacebookManager.getInstance().currentLoggedInUserFriendsWithInstall.concat();
					var hasAccount:Boolean;
					facebookID = FacebookManager.getInstance().currentLoggedInUser.id;
					for(var i:int = 0; i < friends.length; i++){
						for(var f:int = 0; f < actualFriendsWithInstall.length; f++){
							hasAccount = false;
							if(friends[i] == actualFriendsWithInstall[f].rawFacebookData.id){
								hasAccount = true;
								friendsWithAccount.push(friends[i]);
								break;
							}
						}
						if(!hasAccount){
							friendsWithoutAccount.push(friends[i]);
						}
					}
					
					GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_FINISHED, facebookRequestsSent);
					GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_CANCELED, facebookRequestsSent);
					GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_FAILED, facebookRequestsSent);
					GoViral.goViral.showFacebookRequestDialog("Hey! I've sent you some free credits, can you help me out by sending some back? Thanks!", "Send your free credits!", null, GVFacebookRequestFilter.ALL, friends.toString(), null, true);
				}
				facebookIDStored = facebookID;
				friendsWithAccountStored = friendsWithAccount.concat();
				friendsWithoutAccountStored = friendsWithoutAccount.concat();
				creditsStored = credits;
				productQuantityStored = productQuantity;
				productStored = productID;
				
				if(FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
					sendGiftsWhenReady();
				}
			}
		}
		
		private function facebookRequestsSent(e:GVFacebookEvent):void{
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_FINISHED, facebookRequestsSent);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_CANCELED, facebookRequestsSent);
			GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_FAILED, facebookRequestsSent);
			if(e.type == GVFacebookEvent.FB_DIALOG_FINISHED){
				sendGiftsWhenReady();
			}
			else{
				LOG.warning("There was a problem when submitting to Facebook, either it failed or was canceled by the user.");
				giftsSent = false;
				giftDataSignal.dispatch();
			}
		}
		
		private function sendGiftsWhenReady():void{
			if(facebookIDStored != ""){
				if(friendsWithAccountStored.length > 0){
					var obj:Object = new Object();
					obj.to = friendsWithAccountStored;
					obj.from = facebookIDStored;
					obj.credits = creditsStored;
					obj.productID = productStored;
					obj.productQuantity = productQuantityStored;
					
					PUT(new NetResponceHandler(onGiftsSentSuccess, onGiftsSentFailed), "", obj);
				}
				else if(friendsWithoutAccountStored.length > 0){
					giftsSent = true;
					giftDataSignal.dispatch();
					LOG.debug("There were friends without accounts: " + friendsWithoutAccountStored);
				}
			}
			facebookIDStored = null;
			friendsWithAccountStored = null;
			friendsWithoutAccountStored = null;
			creditsStored = 0;
			productQuantityStored = 0;
			productStored = null;
		}
		
		
		private function onGiftsReceived(e:Object = null):void{
			gifts = new Vector.<ServerGiftVO>;
			if(e && e.length > 0){
				for(var i:int = 0; i < e.length; i++){
					if(ServerGiftVO.checkObject(e[i])){
						var gift:ServerGiftVO = new ServerGiftVO(e[i]);
						gifts.push(gift);
					}
				}
			}
			else{
				if(e && e.length == 0){
					LOG.warning("There were no gifts recevied");
				}
				else{
					LOG.error("There was a problem getting gifts");
				}
			}
			giftDataSignal.dispatch();
		}
		private function onGiftsReceivedFailed():void{
			LOG.error("there was a problem whilst attempting to get the gifts.");
			giftDataSignal.dispatch();
		}
		
		private function onGiftsSentSuccess(e:Object = null):void{
			giftsSent = true;
			if(e && e.length > 0){
				giftDataSignal.dispatch();
			}
			else{
				if(e && e.length == 0){
					LOG.warning("There were no gifts sent");
				}
				else{
					LOG.error("There was a problem sending gifts to the receiptients");
				}
			}
		}
		private function onGiftsSentFailed():void{
			giftsSent = false;
			giftDataSignal.dispatch();
			LOG.error("There was a problem sending gifts to the receiptients");
		}
		
		private function onAcceptAndSendComplete(e:Object = null):void{
			UserData.getInstance().getUser();
			ProductsData.getInstance().getProducts();
		}
		private function onAcceptAndSendFailed():void{
			LOG.error("There was a problem with the accept and send");
			UserData.getInstance().getUser();
			ProductsData.getInstance().getProducts();
		}
		
		public static function getInstance():GiftData{
			if(INSTANCE == null){
				INSTANCE = new GiftData();
			}
			return INSTANCE;
		}
	}
}
