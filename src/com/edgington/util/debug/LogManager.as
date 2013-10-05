package com.edgington.util.debug
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.testflight.TestFlight;
	import com.greensock.TweenLite;
	
	import flash.utils.getQualifiedClassName;

	public class LogManager
	{	
		private static var _LOGGER_INSTANCE:LogManager;
		
		private var showCreate:Boolean = false;
		private var showDestroy:Boolean = false;
		private var showInfo:Boolean = false;
		private var showDebug:Boolean = true;
		private var showWarning:Boolean = true;
		private var showError:Boolean = true;
		private var showFatal:Boolean = true;
		private var showServer:Boolean = true;
		private var showFacebook:Boolean = true;
		
		
		private var testFlight:TestFlight;
		private var testFlightReady:Boolean = false;
		
		/**
		 * If you have a testflight enabled app make sure that you change the app token here. If you don't then comment out the tesfflight imports and the testflight related code.
		 */
		public function LogManager()
		{
			if(TestFlight.isSupported){
				if(DynamicConstants.isIOSPlatform()){
					testFlight = new TestFlight("303be3a6-6a43-4f07-a8ef-2aadf59a74d1", true);
					TweenLite.delayedCall(2, setTestFlightReady);
				}
				else if(DynamicConstants.isMobileOS()){
					testFlight = new TestFlight("3d9d30bc-e6c7-4ae4-a9a3-0ad833371262", true);
					TweenLite.delayedCall(2, setTestFlightReady);
				}
			}
		}
		
//		public function setSessionActive(isSessionActive:Boolean):void{
//			if(testFlightReady){
//				testFlight.setSessionActive(isSessionActive);
//			}
//		}
		
		/**
		 * Called after setting up TestFlight.
		 */
		private function setTestFlightReady():void{
			testFlightReady = true;
			if(testFlightReady){
				testFlight.passCheckPoint("FlightPath Initiated");
			}
		}
		
		/**
		 * LOG.createCheckpoint
		 * 
		 * Parse a string during any point at runtime to post a checkpoint
		 */
		public function createCheckpoint(str:String):void{
			if(testFlightReady){
				testFlight.passCheckPoint(str);
			}
		}
		
		/**
		 * Opens the feedback window on iOS
		 */
		public function provideFeedback():void{
			if(testFlightReady){
				testFlight.openFeedBackView();
			}
		}
		
		/**
		 * LOG.create(CLASS)
		 * 
		 * When creating a class at runtime simply put this in the constructor to log that the class has been created
		 * 
		 * EXAMPLE
		 * 
		 * LOG.create(this) //this will trace: "CREATED CLASS: LogManager"
		 */
		public function create(_class:*):void{
			if(showCreate){
				if(_class is String){
					trace("CREATED CLASS: " + _class);
					if(testFlightReady){
						testFlight.log("CREATED CLASS: " + _class);
					}
				}
				else{
					trace("CREATED CLASS: " + getQualifiedClassName(_class).split("::")[1])
					if(testFlightReady){
						testFlight.log("CREATED CLASS: " + getQualifiedClassName(_class).split("::")[1]);
					}
				}
			}
		}
		
		/**
		 * LOG.destroy(CLASS)
		 * 
		 * When destroying a class at runtime simply put this in the destroy method to log that the class has been destroyed
		 * 
		 * EXAMPLE
		 * 
		 * LOG.destroy(this) //this will trace: "DESTORYED CLASS: LogManager"
		 */
		public function destroy(_class:*):void{
			if(showDestroy){
				if(_class is String){
					trace("DESTROYED CLASS: " + _class);		
					if(testFlightReady){
						testFlight.log("DESTROYED CLASS: " + _class);
					}
				}
				else{
					trace("DESTROYED CLASS: " + getQualifiedClassName(_class).split("::")[1]);
					if(testFlightReady){
						testFlight.log("DESTROYED CLASS: " + getQualifiedClassName(_class).split("::")[1]);
					}
				}
			}
		}
		
		/**
		 * LOG.info
		 * 
		 * Simple logging method parse anything into it (usually a string) and it will be traced, if more than one argument is parsed it will trace all arguments independantly prefixed with there index.
		 * 
		 * EXAMPLE
		 * 
		 * LOG.info("Hello") //this will trace: "INFO: Hello"
		 * 
		 * LOG.info(12, "Ollie", "Awesome") //this will trace: "INFO [0]: 12 \n INFO [1]: Ollie \n INFO [2]: Awesome"
		 */
		public function info(...args):void{
			if(showInfo){
				if(args.length > 1){
					for(var i:int = 0; i < args.length; i++){
						trace("INFO ["+i+"]: " + args[i]);
					}
				}
				else if(args.length != 0){
					trace("INFO: " + args[0]);
					if(testFlightReady){
						testFlight.log("INFO: " + args[0]);
					}
				}
			}
		}
		
		/**
		 * LOG.warning
		 * 
		 * Simple logging method parse anything into it (usually a string) and it will be traced, if more than one argument is parsed it will trace all arguments independantly prefixed with there index.
		 * 
		 * EXAMPLE
		 * 
		 * LOG.warning("Hello") //this will trace: "[WARNING]: Hello"
		 * 
		 * LOG.warning(12, "Ollie", "Awesome") //this will trace: "[WARNING] [0]: 12 \n [WARNING] [1]: Ollie \n [WARNING] [2]: Awesome"
		 */
		public function warning(...args):void{
			if(showWarning){
				if(args.length > 1){
					for(var i:int = 0; i < args.length; i++){
						trace("[WARNING] ["+i+"]: " + args[i]);
					}
				}
				else if(args.length != 0){
					trace("[WARNING]: " + args[0]);
					if(testFlightReady){
						testFlight.log("[WARNING]: " + args[0]);
					}
				}
			}
		}
		
		/**
		 * LOG.debug
		 * 
		 * Simple logging method parse anything into it (usually a string) and it will be traced, if more than one argument is parsed it will trace all arguments independantly prefixed with there index.
		 * 
		 * EXAMPLE
		 * 
		 * LOG.debug("Hello") //this will trace: "[DEBUG]: Hello"
		 * 
		 * LOG.debug(12, "Ollie", "Awesome") //this will trace: "[DEBUG] [0]: 12 \n [DEBUG] [1]: Ollie \n [DEBUG] [2]: Awesome"
		 */
		public function debug(...args):void{
			if(showDebug){
				if(args.length > 1){
					for(var i:int = 0; i < args.length; i++){
						trace("[DEBUG] ["+i+"]: " + args[i]);
					}
				}
				else if(args.length != 0){
					trace("[DEBUG]: " + args[0]);
					if(testFlightReady){
						testFlight.log("[DEBUG]: " + args[0]);
					}
				}
			}
		}
		
		/**
		 * LOG.error
		 * 
		 * Simple logging method parse anything into it (usually a string) and it will be traced, if more than one argument is parsed it will trace all arguments independantly prefixed with there index.
		 * 
		 * EXAMPLE
		 * 
		 * LOG.error("Hello") //this will trace: "[[ERROR]]: Hello"
		 * 
		 * LOG.error(12, "Ollie", "Awesome") //this will trace: "[[ERROR]] [0]: 12 \n [[ERROR]] [1]: Ollie \n [[ERROR]] [2]: Awesome"
		 */
		public function error(...args):void{
			if(showError){
				if(args.length > 1){
					for(var i:int = 0; i < args.length; i++){
						trace("[[ERROR]] ["+i+"]: " + args[i]);
					}
				}
				else if(args.length != 0){
					trace("[[ERROR]]: " + args[0]);
					if(testFlightReady){
						testFlight.log("[[ERROR]]: " + args[0]);
					}
				}
			}
		}
		
		/**
		 * LOG.fatal
		 * 
		 * Simple logging method parse anything into it (usually a string) and it will be traced, if more than one argument is parsed it will trace all arguments independantly prefixed with there index.
		 * 
		 * EXAMPLE
		 * 
		 * LOG.fatal("Hello") //this will trace: "[[[FATAL]]]: Hello"
		 * 
		 * LOG.fatal(12, "Ollie", "Awesome") //this will trace: "[[[FATAL]]] [0]: 12 \n [[[FATAL]]] [1]: Ollie \n [[[FATAL]]] [2]: Awesome"
		 */
		public function fatal(...args):void{
			if(showFatal){
				if(args.length > 1){
					for(var i:int = 0; i < args.length; i++){
						trace("[[[FATAL]]] ["+i+"]: " + args[i]);
					}
				}
				else if(args.length != 0){
					trace("[[[FATAL]]]: " + args[0]);
					if(testFlightReady){
						testFlight.log("[[[FATAL]]]: " + args[0]);
					}
				}
			}
		}
		
		/**
		 * LOG.facebook
		 * 
		 * If you have a Facebook enabled application this can be used to log facebook stuff independantly of other logs.
		 * 
		 * EXAMPLE
		 * 
		 * LOG.facebook("Hello") //this will trace: "[#FACEBOOK#]: Hello"
		 * 
		 * LOG.facebook(12, "Ollie", "Awesome") //this will trace: "[#FACEBOOK#] [0]: 12 \n [#FACEBOOK#] [1]: Ollie \n [#FACEBOOK#] [2]: Awesome"
		 */
		public function facebook(...args):void{
			if(showFacebook){
				if(args.length > 1){
					for(var i:int = 0; i < args.length; i++){
						trace("[#FACEBOOK#] ["+i+"]: " + args[i]);
					}
				}
				else if(args.length != 0){
					trace("[#FACEBOOK#]: " + args[0]);
					if(testFlightReady){
						testFlight.log("[#FACEBOOK#]: " + args[0]);
					}
				}
			}
		}
		
		/**
		 * LOG.server
		 * 
		 * If you have a server enabled application this can be used to log server stuff independantly of other logs.
		 * 
		 * EXAMPLE
		 * 
		 * LOG.server("Hello") //this will trace: "[#SERVER#]: Hello"
		 * 
		 * LOG.server(12, "Ollie", "Awesome") //this will trace: "[#SERVER#] [0]: 12 \n [#SERVER#] [1]: Ollie \n [#SERVER#] [2]: Awesome"
		 */
		public function server(...args):void{
			if(showServer){
				if(args.length > 1){
					for(var i:int = 0; i < args.length; i++){
						trace("[#SERVER#] ["+i+"]: " + args[i]);
					}
				}
				else if(args.length != 0){
					trace("[#SERVER#]: " + args[0]);
					if(testFlightReady){
						testFlight.log("[#SERVER#]: " + args[0]);
					}
				}
			}
		}
		
		/**
		 * Required for easy access of the class instance.
		 */
		public static function LOGGER_INSTANCE():LogManager{
			if(_LOGGER_INSTANCE == null){
				_LOGGER_INSTANCE = new LogManager();
			}
			return _LOGGER_INSTANCE;
		}
	}
}