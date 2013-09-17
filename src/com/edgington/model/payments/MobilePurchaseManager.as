package com.edgington.model.payments
{
	import com.edgington.constants.ProductConstants;
	import com.edgington.model.events.TransactionEvent;
	import com.edgington.net.UserData;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.greensock.TweenLite;
	import com.milkmangames.nativeextensions.ios.StoreKit;
	import com.milkmangames.nativeextensions.ios.StoreKitProduct;
	import com.milkmangames.nativeextensions.ios.events.StoreKitErrorEvent;
	import com.milkmangames.nativeextensions.ios.events.StoreKitEvent;
	
	import flash.events.EventDispatcher;
	import flash.net.Responder;
	
	import org.osflash.signals.Signal;
	
	public class MobilePurchaseManager extends EventDispatcher
	{
		
		private static var _INSTANCE:MobilePurchaseManager;
		
		private var storeKit:StoreKit;
		
		public var avaliable:Boolean = false;
		
		private var allowOnDesktop:Boolean = true; //debug
		
		
		
		private var AppStoreProducts:Vector.<String> = new <String>[ProductConstants.ADDITIONAL_CREDITS_25, ProductConstants.ADDITIONAL_CREDITS_55, ProductConstants.ADDITIONAL_CREDITS_310, ProductConstants.ADDITIONAL_UNLIMITED];
		private var loadedProducts:Vector.<StoreKitProduct>;
		
		private const CALL_GENERATE_TRANSACTION_LOG:String = "mobileUserManager.generateNewPurchaseRecord";
		private const CALL_FAILED_TRANSACTION:String = "mobileUserManager.failedTransaction";
		private const CALL_USER_CANCELLED_TRANSACTION:String = "mobileUserManager.cancelledTransaction";
		private var RES_TRANSACTION_LOG_REPORT:Responder;
		
		private var currentTransactionProductID:String;
		private var currentTransactionIdentifier:String;
		
		public var transactionSignal:Signal;
		public var creditsUpdate:Signal;
				
		public function MobilePurchaseManager(e:SingletonEnforcer)
		{
			super(null);
			LOG.create(this);
			transactionSignal = new Signal();
			creditsUpdate = new Signal();
			checkStoreAvailability();
		}
		
		
		/**
		 * Checks to see if the purchasing is avaliable on the current platform and sets up listeners
		 */
		public function checkStoreAvailability():Boolean{
			if(StoreKit.isSupported())
			{
				storeKit=StoreKit.create();
				if(!StoreKit.storeKit.isStoreKitAvailable())
				{
					trace("this device has purchases disabled.");
				}
				else{
					// Listen for events.
					StoreKit.storeKit.addEventListener(StoreKitEvent.PRODUCT_DETAILS_LOADED,onProductsLoaded);
					StoreKit.storeKit.addEventListener(StoreKitEvent.PURCHASE_SUCCEEDED,onPurchaseSuccess);
					StoreKit.storeKit.addEventListener(StoreKitEvent.PURCHASE_CANCELLED,onPurchaseUserCancelled);
					StoreKit.storeKit.addEventListener(StoreKitEvent.TRANSACTIONS_RESTORED,onTransactionsRestored);
					// adding error events. always listen for these to avoid your program failing.
					StoreKit.storeKit.addEventListener(StoreKitErrorEvent.PRODUCT_DETAILS_FAILED,onProductDetailsFailed);
					StoreKit.storeKit.addEventListener(StoreKitErrorEvent.PURCHASE_FAILED,onPurchaseFailed);
					StoreKit.storeKit.addEventListener(StoreKitErrorEvent.TRANSACTION_RESTORE_FAILED,onTransactionRestoreFailed);
					
					StoreKit.storeKit.loadProductDetails(AppStoreProducts);
				}
				
			}
			else {
				trace("StoreKit not avaliable on this platform");
			}
			if(allowOnDesktop){
				avaliable = true;
				loadedProducts = new Vector.<StoreKitProduct>;
				var fakeStoreProduct:StoreKitProduct = new StoreKitProduct();
				fakeStoreProduct.price = "£0.69";
				fakeStoreProduct.title = "25 Credits";
				fakeStoreProduct.description = "Description";
				fakeStoreProduct.productId = ProductConstants.ADDITIONAL_CREDITS_25;
				fakeStoreProduct.localizedPrice = "£0.69";
				loadedProducts.push(fakeStoreProduct);
				fakeStoreProduct = new StoreKitProduct();
				fakeStoreProduct.price = "£1.49";
				fakeStoreProduct.title = "55 Credits";
				fakeStoreProduct.description = "Description";
				fakeStoreProduct.productId = ProductConstants.ADDITIONAL_CREDITS_55;
				fakeStoreProduct.localizedPrice = "£1.49";
				loadedProducts.push(fakeStoreProduct);
				fakeStoreProduct = new StoreKitProduct();
				fakeStoreProduct.price = "£2.99";
				fakeStoreProduct.title = "Unlimited Track Plays";
				fakeStoreProduct.description = "Description";
				fakeStoreProduct.productId = ProductConstants.ADDITIONAL_UNLIMITED
				fakeStoreProduct.localizedPrice = "£2.99";
				loadedProducts.push(fakeStoreProduct);
				fakeStoreProduct = new StoreKitProduct();
				fakeStoreProduct.price = "£6.99";
				fakeStoreProduct.title = "250 Credits";
				fakeStoreProduct.description = "Description";
				fakeStoreProduct.productId = ProductConstants.ADDITIONAL_CREDITS_310;
				fakeStoreProduct.localizedPrice = "£6.99";
				loadedProducts.push(fakeStoreProduct);
			}
			return avaliable;
		}
		
		public function getProducts():Vector.<StoreKitProduct>{
			return loadedProducts;
		}
		
		public function getStandardProfilePrice():String{
			for each(var storeProduct:StoreKitProduct in loadedProducts){
				if(storeProduct.productId == AppStoreProducts[0]){
					return storeProduct.localizedPrice;
				}
			}
			return null;
		}
		
		public function getAdditionalProfilePrice():String{
			for each(var storeProduct:StoreKitProduct in loadedProducts){
				if(storeProduct.productId == AppStoreProducts[1]){
					return storeProduct.localizedPrice;
				}
			}
			return null;
		}
		
		public function purchaseSmallCredits():void{
			if(allowOnDesktop){
				TweenLite.delayedCall(1, transactionSignal.dispatch, [TransactionEvent.TRANSACTION_COMPLETE, gettext("purchase_menu_success_beta", {title:getProductNameByID(AppStoreProducts[0])})]);
				UserData.getInstance().addCredits(25);
			}
			else{
				StoreKit.storeKit.purchaseProduct(AppStoreProducts[0], 1);
			}
		}
		
		public function purchaseMediumCredits():void{
			if(allowOnDesktop){
				TweenLite.delayedCall(1, transactionSignal.dispatch, [TransactionEvent.TRANSACTION_COMPLETE, gettext("purchase_menu_success_beta", {title:getProductNameByID(AppStoreProducts[1])})]);
				UserData.getInstance().addCredits(55);
			}
			else{
				StoreKit.storeKit.purchaseProduct(AppStoreProducts[1], 1);
			}
		}
		
		public function purchaseLargeCredits():void{
			if(allowOnDesktop){
				TweenLite.delayedCall(1, transactionSignal.dispatch, [TransactionEvent.TRANSACTION_COMPLETE, gettext("purchase_menu_success_beta", {title:getProductNameByID(AppStoreProducts[2])})]);
				UserData.getInstance().addCredits(310);
			}
			else{
				StoreKit.storeKit.purchaseProduct(AppStoreProducts[2], 1);
			}
		}
		
		public function purchaseUnlimitedTrackPlays():void{
			if(allowOnDesktop){
				TweenLite.delayedCall(1, transactionSignal.dispatch, [TransactionEvent.TRANSACTION_COMPLETE, gettext("purchase_menu_success_beta", {title:getProductNameByID(AppStoreProducts[3])})]);
				UserData.getInstance().unlimitedPurchased();
			}
			else{
				StoreKit.storeKit.purchaseProduct(AppStoreProducts[3], 1);
			}
		}
		
		private function getProductNameByID(productID:String):String{
			for(var i:int = 0; i < loadedProducts.length; i++){
				if(loadedProducts[i].productId == productID){
					return loadedProducts[i].title;
				}
			}
			return "Unknown Purchase";
		}
		
		private function onProductsLoaded(e:StoreKitEvent):void
		{
			avaliable = true;
			trace("products loaded.");
			// save the products that were loaded locally  for later use.
			this.loadedProducts=e.validProducts;
			
			// if any of the product ids we tried to pass in were not found on the server,
			// we won't be able to by them so something is wrong.
			if (e.invalidProductIds!=null)
			{
				
				if (e.invalidProductIds.length>0)
				{
					avaliable = false;
					trace("[ERR]: these products not valid:"+e.invalidProductIds.join(","));
					return;
				}
			}
		}
		
		private function onProductDetailsFailed(e:StoreKitErrorEvent):void
		{
			avaliable = false;
			trace("ERR loading products:"+e.text);
		}
		
		private function onPurchaseSuccess(e:StoreKitEvent):void
		{
			transactionSignal.dispatch(TransactionEvent.TRANSACTION_COMPLETE, gettext("purchase_menu_purchase_sucessfull", {title:getProductNameByID(e.productId)}));
			switch(e.productId){
				case ProductConstants.ADDITIONAL_CREDITS_25:
					UserData.getInstance().addCredits(25);
					break;
				case ProductConstants.ADDITIONAL_CREDITS_55:
					UserData.getInstance().addCredits(55);
					break;
				case ProductConstants.ADDITIONAL_CREDITS_310:
					UserData.getInstance().addCredits(310);
					break;
				case ProductConstants.ADDITIONAL_UNLIMITED:
					UserData.getInstance().unlimitedPurchased();
					break;
			}
			trace("Successful purchase of '"+e.productId+"'");
		}
		
		private function onPurchaseFailed(e:StoreKitErrorEvent):void
		{
			transactionSignal.dispatch(TransactionEvent.TRANSACTION_FAILED, gettext("purchase_menu_purchase_native_error", {error:e.text}));
			trace("Failure purchasing '"+e.productId+"', reason:"+e.text);
		}
		
		private function onPurchaseUserCancelled(e:StoreKitEvent):void
		{
			trace("the user canceled the purchase for '"+e.productId+"'");
			transactionSignal.dispatch(TransactionEvent.TRANSACTION_FAILED, gettext("purchase_menu_purchase_connection_error"));
		}
		
		private function onTransactionsRestored(e:StoreKitEvent):void
		{
			trace("transactions restored.");
		}
		
		private function onTransactionRestoreFailed(e:StoreKitErrorEvent):void
		{
			trace("an error occurred in restore purchases:"+e.text);		
		}
		
		public static function get INSTANCE():MobilePurchaseManager{
			if(_INSTANCE == null){
				_INSTANCE = new MobilePurchaseManager(new SingletonEnforcer());
			}
			return _INSTANCE;
		}
	}
}

class SingletonEnforcer{
	
}