package com.edgington.net
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.FacebookConstants;
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.net.helpers.NetResponceHandler;
	import com.edgington.util.debug.LOG;
	import com.edgington.valueobjects.net.ServerProductsVO;
	
	import flash.net.SharedObject;

	public class ProductsData extends BaseData
	{
		private static var INSTANCE:ProductsData;
		
		private var userData:SharedObject = SharedObject.getLocal("ab_userData");
		
		private var userProducts:Vector.<ServerProductsVO>;
		
		public function ProductsData()
		{
			LOG.create(this);
			super("products", "products");
			
			var serverProductsVO:Vector.<ServerProductsVO>;
			if(userData.data.products == null){
				userData.data.products = new Vector.<ServerProductsVO>;
				serverProductsVO = userData.data.products;
				LOG.info("Created a new products list");
				saveData();
			}
			else{
				//If the user exists in the cache, load the user in to the userData variable.
				serverProductsVO = new Vector.<ServerProductsVO>;
				for(var i:int = 0; i < userData.data.products.length; i++){
					serverProductsVO.push(new ServerProductsVO(JSON.parse(JSON.stringify(userData.data.products[i]))));
				}
			}
			userProducts = serverProductsVO;
			
		}
		
		/**
		 * Get products for user
		 */
		public function getProducts():void{
			if(DynamicConstants.IS_CONNECTED && FacebookManager.getInstance().checkIfUserIsLoggedIn() || FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
				if(FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
					GET(new NetResponceHandler(onProductsReceived, onProductsFailed), false, FacebookConstants.DEBUG_USER_ID);
				}
				else{
					GET(new NetResponceHandler(onProductsReceived, onProductsFailed), false, FacebookManager.getInstance().currentLoggedInUser.id);
				}
			}
		}
		
		/**
		 * Checks to see if the user already has the product
		 * 
		 * If they do it will return the quantity, if they don't it will return 0 (false)
		 */
		public function doesUserHaveProduct(purchaseID:String):int{
			var hasAlreadyPurchase:int = 0;
			for(var i:int = 0; i < userProducts.length; i++){
				if(userProducts[i].productID == purchaseID && userProducts[i].quantity > 0){
					hasAlreadyPurchase = userProducts[i].quantity;
					break;
				}
			}
			return hasAlreadyPurchase;
		}
		
		/**
		 * On receiving the products for a user from the database
		 */
		private function onProductsReceived(e:Object = null):void{
			if(e && e.length > 0){
				userProducts = new Vector.<ServerProductsVO>;
				for(var i:int = 0; i < e.length; i++){
					userProducts.push(new ServerProductsVO(e[i]));
				}
				saveData();
			}
			else{
				userProducts = new Vector.<ServerProductsVO>;
				LOG.info("Users has no products");
			}
			saveData();
		}
		private function onProductsFailed():void{
			LOG.error("There was a problem downloading the users products");
		}
		
		/**
		 * Purchase new item fro account
		 */
		public function createNewPurchase(productID:String, quantity:int = 1 ):void{
			var serverProductsVO:ServerProductsVO = new ServerProductsVO();
			if(DynamicConstants.IS_CONNECTED && FacebookManager.getInstance().checkIfUserIsLoggedIn() || FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
				if(FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
					serverProductsVO.productID = productID;
					serverProductsVO.fb_id = FacebookConstants.DEBUG_USER_ID;
					serverProductsVO.quantity = quantity;
				}
				else{
					serverProductsVO.productID = productID;
					serverProductsVO.fb_id = FacebookManager.getInstance().currentLoggedInUser.id;
					serverProductsVO.quantity = quantity;
				}
				PUT(new NetResponceHandler(onItemPurchaseSuccess, onItemPurchaseFailed), serverProductsVO.fb_id, JSON.parse(JSON.stringify(serverProductsVO)));
			}
		}
		
		private function onItemPurchaseSuccess(e:Object = null):void{
			if(e && ServerProductsVO.checkObject(e)){
				userProducts.push(new ServerProductsVO(e));
				saveData();
			}
			else{
				if(e){
					LOG.error("Response from server does not contain a valid product object");
				}
			}
		}
		private function onItemPurchaseFailed():void{
			LOG.error("There was a problem adding the requested item");	
		}
		
		/**
		 * If the product can run out, this is how the quantity is reduced. Parse the amount to reduce it by, the default is 1
		 */
		public function useProduct(productID:String, amountToUse:int = 1):void{
			var serverProductsVO:ServerProductsVO;
			for(var i:int = 0; i < userProducts.length; i++){
				if(userProducts[i].productID == productID){
					serverProductsVO = userProducts[i];
					break;
				}
			}
			if(serverProductsVO == null){
				LOG.fatal("User does not have this product ("+productID+"), please make sure that you have checked it existed in the players inventory (ProductsData.doesUserHaveProduct) checkbefore attempting to use it,");
				return;
			}
			if(amountToUse > serverProductsVO.quantity){
				LOG.fatal("User does not have enough of this product ("+productID+"), please make sure that you have checked there is enough before calling this method. (ProductsData.doesUserHaveProduct) will return quantity");
			}
			if(DynamicConstants.IS_CONNECTED && FacebookManager.getInstance().checkIfUserIsLoggedIn() || FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
				serverProductsVO.quantity -= amountToUse;
				for(i = 0; i < userProducts.length; i++){
					if(userProducts[i].productID == productID){
						userProducts[i].quantity -= amountToUse;
						break;
					}
				}
				POST(new NetResponceHandler(onUseItemSuccess, onUseItemFailed), serverProductsVO.fb_id, JSON.parse(JSON.stringify(serverProductsVO)));
			}
		}
		
		private function onUseItemSuccess(e:Object = null):void{
			if(e && ServerProductsVO.checkObject(e)){
				//The item was successfully updated. No need to do anything further.
			}
			else{
				if(e){
					LOG.error("Response from server does not contain a valid product object - this is a problem that needs to be double checked");
				}
			}
		}
		private function onUseItemFailed():void{
			LOG.error("There was a problem updating the quantity of an item on the server");
		}
		
		private function saveData():void{
			userData.data.products = userProducts;
			userData.flush();
		}
		
		public static function getInstance():ProductsData{
			if(INSTANCE == null){
				INSTANCE = new ProductsData();
			}
			return INSTANCE;
		}
	}
}