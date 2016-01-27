package com.edgington.model.payments
{
	import com.adobe.ane.productStore.Product;
	import com.adobe.ane.productStore.ProductEvent;
	import com.adobe.ane.productStore.ProductStore;
	import com.adobe.ane.productStore.Transaction;
	import com.adobe.ane.productStore.TransactionEvent;
	import com.edgington.constants.ProductConstants;
	import com.edgington.model.events.TransactionABEvent;
	import com.edgington.net.UserData;
	import com.edgington.util.Base64;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.greensock.TweenLite;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.Responder;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	import org.osflash.signals.Signal;
	
	public class MobilePurchaseManager extends EventDispatcher
	{
		
		private static var _INSTANCE:MobilePurchaseManager;
		
		private var storeKit:ProductStore;
		
		public var avaliable:Boolean = false;
		
		private const allowOnDesktop:Boolean = true; //debug
		
		private var AppStoreProducts:Vector.<String> = new <String>[ProductConstants.ADDITIONAL_CREDITS_25, ProductConstants.ADDITIONAL_CREDITS_55, ProductConstants.ADDITIONAL_CREDITS_310];
		private var loadedProducts:Vector.<Product>;
		
		private const CALL_GENERATE_TRANSACTION_LOG:String = "mobileUserManager.generateNewPurchaseRecord";
		private const CALL_FAILED_TRANSACTION:String = "mobileUserManager.failedTransaction";
		private const CALL_USER_CANCELLED_TRANSACTION:String = "mobileUserManager.cancelledTransaction";
		private var RES_TRANSACTION_LOG_REPORT:Responder;
		
		private var currentTransactionProductID:String;
		private var currentTransactionIdentifier:String;
		
		public var transactionSignal:Signal;
		public var creditsUpdate:Signal;
				
		private var waitingForPendingTransactions:Boolean = false;
		
		public var isLoaded:Boolean = false;
		public var errorLoading:Boolean = false;
		
		public function MobilePurchaseManager(e:SingletonEnforcer)
		{
			super(null);
			
//			if(DynamicConstants.isIOSPlatform()){
//				allowOnDesktop = false;
//			}
			
			LOG.create(this);
			transactionSignal = new Signal();
			creditsUpdate = new Signal();
			TweenLite.delayedCall(0.1, checkStoreAvailability);
		}
		
		
		/**
		 * Checks to see if the purchasing is avaliable on the current platform and sets up listeners
		 */
		public function checkStoreAvailability():Boolean{
			if(ProductStore.isSupported)
			{
				storeKit=new ProductStore();
				if(!storeKit.available)
				{
					trace("this device has purchases disabled.");
					dispatchEvent(new Event(Event.COMPLETE));
					isLoaded = true;
				}
				else{
				
					storeKit.addEventListener(ProductEvent.PRODUCT_DETAILS_SUCCESS,onProductsLoaded);
					storeKit.addEventListener(ProductEvent.PRODUCT_DETAILS_FAIL, onProductsFailed);
					// Listen for events.
					
					storeKit.addEventListener(TransactionEvent.PURCHASE_TRANSACTION_SUCCESS, onPurchaseSuccess);
					storeKit.addEventListener(TransactionEvent.PURCHASE_TRANSACTION_CANCEL, onPurchaseUserCancelled);
					storeKit.addEventListener(TransactionEvent.PURCHASE_TRANSACTION_FAIL, onPurchaseFailed);
					
					storeKit.addEventListener(TransactionEvent.RESTORE_TRANSACTION_SUCCESS, onTransactionsRestored);
					storeKit.addEventListener(TransactionEvent.RESTORE_TRANSACTION_FAIL, onTransactionRestoreFailed);
					storeKit.addEventListener(TransactionEvent.RESTORE_TRANSACTION_COMPLETE,  onTransactionsRestoredComplete);
					
					storeKit.requestProductsDetails(AppStoreProducts);
				}
				
			}
			else {
				trace("StoreKit not avaliable on this platform");
			}
			if(allowOnDesktop){
				avaliable = true;
				loadedProducts = new Vector.<Product>;
				loadedProducts.push(new Product("25 Credits", "Description", ProductConstants.ADDITIONAL_CREDITS_25, "en_GB@currency=GBP", 0.69));
				loadedProducts.push(new Product("55 Credits", "Description", ProductConstants.ADDITIONAL_CREDITS_55, "en_GB@currency=GBP", 1.49));
				loadedProducts.push(new Product("310 Credits", "Description", ProductConstants.ADDITIONAL_CREDITS_310, "en_GB@currency=GBP", 6.99));
				dispatchEvent(new Event(Event.COMPLETE));
				isLoaded = true;
			}
			return avaliable;
		}
		
		public function getProducts():Vector.<Product>{
			return loadedProducts;
		}
		
		public function purchaseSmallCredits():void{
			if(allowOnDesktop){
				TweenLite.delayedCall(1, transactionSignal.dispatch, [TransactionABEvent.TRANSACTION_COMPLETE, gettext("purchase_menu_success_beta", {title:getProductNameByID(AppStoreProducts[0])})]);
				UserData.getInstance().addCredits(25);
			}
			else{
				storeKit.makePurchaseTransaction(AppStoreProducts[0], 1);
			}
		}
		
		public function purchaseMediumCredits():void{
			if(allowOnDesktop){
				TweenLite.delayedCall(1, transactionSignal.dispatch, [TransactionABEvent.TRANSACTION_COMPLETE, gettext("purchase_menu_success_beta", {title:getProductNameByID(AppStoreProducts[1])})]);
				UserData.getInstance().addCredits(55);
			}
			else{
				storeKit.makePurchaseTransaction(AppStoreProducts[1], 1);
			}
		}
		
		public function purchaseLargeCredits():void{
			if(allowOnDesktop){
				TweenLite.delayedCall(1, transactionSignal.dispatch, [TransactionABEvent.TRANSACTION_COMPLETE, gettext("purchase_menu_success_beta", {title:getProductNameByID(AppStoreProducts[2])})]);
				UserData.getInstance().addCredits(310);
			}
			else{
				storeKit.makePurchaseTransaction(AppStoreProducts[2], 1);
			}
		}
		
		private function getProductNameByID(productID:String):String{
			for(var i:int = 0; i < loadedProducts.length; i++){
				if(loadedProducts[i].identifier == productID){
					return loadedProducts[i].title;
				}
			}
			return "Unknown Purchase";
		}
		
		private function onProductsLoaded(e:ProductEvent):void
		{
			avaliable = true;
			LOG.debug("Products loaded.");
			// save the products that were loaded locally  for later use.
			loadedProducts = new Vector.<Product>;
			
			var i:uint=0;
			while(e.products && i < e.products.length)
			{
				loadedProducts.push(e.products[i]);
				i++;
			}
			
			if(storeKit.pendingTransactions == null || storeKit.pendingTransactions.length == 0){
				dispatchEvent(new Event(Event.COMPLETE));
				isLoaded = true;
			}
			else{
				storeKit.dispatchEvent(new TransactionEvent(TransactionEvent.PURCHASE_TRANSACTION_FAIL, false, false, storeKit.pendingTransactions));
				waitingForPendingTransactions = true;
			}
		}
		
		private function onProductsFailed(e:ProductEvent):void{
			avaliable = false;
			LOG.error("Loading products failed");
			if(storeKit.pendingTransactions == null || storeKit.pendingTransactions.length == 0){
				dispatchEvent(new Event(Event.COMPLETE));
				isLoaded = true;
			}
			else{
				waitingForPendingTransactions = true;
			}
		}
		
		private function onPurchaseSuccess(e:TransactionEvent):void
		{
			var i:uint=0;
			var t:Transaction;
			while(e.transactions && i < e.transactions.length)
			{
				t = e.transactions[i];
				printTransaction(t);
				i++;
				var Base:Base64=new Base64();
				var encodedReceipt:String = Base64.Encode(t.receipt);
				var req:URLRequest = new URLRequest("https://sandbox.itunes.apple.com/verifyReceipt");
				req.method = URLRequestMethod.POST;
				req.data = "{\"receipt-data\" : \""+ encodedReceipt+"\"}";
				var ldr:URLLoader = new URLLoader(req);
				ldr.load(req);
				ldr.addEventListener(Event.COMPLETE,function(e:Event):void{
					trace("LOAD COMPLETE: " + ldr.data);
					storeKit.addEventListener(TransactionEvent.FINISH_TRANSACTION_SUCCESS, finishTransactionSucceeded);
					storeKit.finishTransaction(t.identifier);
				});
				
				trace("Called Finish on/Finish Transaction " + t.identifier); 
			}
			
			getPendingTransaction(storeKit);
			
			storeKit.addEventListener(TransactionEvent.FINISH_TRANSACTION_SUCCESS, finishTransactionSucceeded);
			storeKit.finishTransaction(e.transactions[0].identifier);
		}
		
		protected function finishTransactionSucceeded(e:TransactionEvent):void{
			
			for(var t:int = 0 ; t < e.transactions.length; t++)
			{
				if(e.transactions[t].error == null || e.transactions[t].error == ""){
					if(e.transactions.length == 1 && loadedProducts){
						transactionSignal.dispatch(TransactionABEvent.TRANSACTION_COMPLETE, gettext("purchase_menu_purchase_sucessfull", {title:getProductNameByID(e.transactions[t].productIdentifier)}));
					}
					
					switch(e.transactions[t].productIdentifier){
						case ProductConstants.ADDITIONAL_CREDITS_25:
							UserData.getInstance().addCredits(25);
							LOG.createCheckpoint("PURCHASE: 25 Credits");
							break;
						case ProductConstants.ADDITIONAL_CREDITS_55:
							UserData.getInstance().addCredits(55);
							LOG.createCheckpoint("PURCHASE: 55 Credits");
							break;
						case ProductConstants.ADDITIONAL_CREDITS_310:
							UserData.getInstance().addCredits(310);
							LOG.createCheckpoint("PURCHASE: 310 Credits");
							break;
					}
				}
				
				printTransaction(e.transactions[t]);
			}
			
			if(waitingForPendingTransactions && storeKit.pendingTransactions == null || storeKit.pendingTransactions.length == 0){
				waitingForPendingTransactions = false;
				dispatchEvent(new Event(Event.COMPLETE));
				isLoaded = true;
			}
		}
		
		private function onPurchaseFailed(e:TransactionEvent):void
		{
			
			var i:uint=0;
			while(e.transactions && i < e.transactions.length)
			{
				if(e.transactions.length == 1){
					transactionSignal.dispatch(TransactionABEvent.TRANSACTION_FAILED, gettext("purchase_menu_purchase_native_error", {error:e.transactions[0].error}));
				}
				var t:Transaction = e.transactions[i];
				printTransaction(t);
				LOG.error("Failure purchasing '"+e.transactions[i].productIdentifier+"', reason: "+e.transactions[i].error);
				i++;
				trace("FinishTransactions" + t.identifier);
				storeKit.addEventListener(TransactionEvent.FINISH_TRANSACTION_SUCCESS, finishTransactionSucceeded);
				storeKit.finishTransaction(t.identifier);
			}
			
			
			
			getPendingTransaction(storeKit);
		}
		
		private function onPurchaseUserCancelled(e:TransactionEvent):void
		{
			LOG.debug("The user canceled the purchase for '"+e.transactions[0].productIdentifier+"'");
			transactionSignal.dispatch(TransactionABEvent.TRANSACTION_FAILED, gettext("purchase_menu_purchase_connection_error"));
		}
		
		private function onTransactionsRestored(e:TransactionEvent):void
		{
			LOG.debug("Transactions restored.");
		}
		
		private function onTransactionRestoreFailed(e:TransactionEvent):void
		{
			LOG.error("An error occurred in restore purchases:"+e.transactions[0].error);		
		}
		
		private function onTransactionsRestoredComplete(e:TransactionEvent):void
		{
			LOG.debug("Transactions restore complete.");
		}
		
		public function getPendingTransaction(prdStore:ProductStore):void
		{
			trace("pending transaction");
			var transactions:Vector.<Transaction> = prdStore.pendingTransactions; 
			var i:uint=0;
			while(transactions && i<transactions.length)
			{
				var t:Transaction = transactions[i];
				printTransaction(t);
				i++;
			}
		}
		
		public function printTransaction(t:Transaction):void
		{
			LOG.debug("-------------------in Print Transaction----------------------");
			LOG.debug("identifier :"+t.identifier);
			LOG.debug("productIdentifier: "+ t.productIdentifier);
			LOG.debug("productQuantity: "+t.productQuantity);
			LOG.debug("date: "+t.date);
			LOG.debug("receipt: "+t.receipt);
			LOG.debug("error: "+t.error);
			LOG.debug("originalTransaction: "+t.originalTransaction);
			if(t.originalTransaction)
				printTransaction(t.originalTransaction);
			LOG.debug("---------end of print transaction----------------------------");
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