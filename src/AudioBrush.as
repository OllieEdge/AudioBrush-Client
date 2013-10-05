package
{
		import com.edgington.constants.DynamicConstants;
		import com.edgington.constants.FacebookConstants;
		import com.edgington.control.Control;
		import com.edgington.model.GameProxy;
		import com.edgington.model.SettingsProxy;
		import com.edgington.model.SoundManager;
		import com.edgington.model.calculators.LevelCalculator;
		import com.edgington.model.facebook.FacebookCheckIfStillAuthenicated;
		import com.edgington.model.facebook.FacebookManager;
		import com.edgington.model.payments.MobilePurchaseManager;
		import com.edgington.net.SingleSignOnManager;
		import com.edgington.net.UserData;
		import com.edgington.types.GameStateTypes;
		import com.edgington.types.ThemeTypes;
		import com.edgington.util.PushNotificationsManager;
		import com.edgington.util.TextFieldManager;
		import com.edgington.util.debug.LOG;
		import com.edgington.util.localisation.LOCALE_INSTANCE;
		import com.edgington.util.localisation.Locale;
		import com.edgington.view.GameStateHandler;
		import com.edgington.view.assets.AssetLoader;
		import com.edgington.view.model.ScreenManager;
		import com.greensock.TweenLite;
		
		import flash.display.MovieClip;
		import flash.display.Sprite;
		import flash.display.StageAlign;
		import flash.display.StageOrientation;
		import flash.display.StageQuality;
		import flash.display.StageScaleMode;
		import flash.events.Event;
		import flash.events.StageOrientationEvent;
	
	[SWF(backgroundColor='#000000', frameRate='60')]
	
	public class AudioBrush extends Sprite
	{
		
		private var enterFrameClip:Sprite;
		
		private var audioBrushStateManager:GameStateHandler;
		
		private var loadsComplete:int = 0;
		
		private var screenManager:ScreenManager;
		
		private var startupImage:MovieClip;
		private var startupLoader:ui_loading;
		
		private var singleSignOnManager:SingleSignOnManager;
		
		private var checkFacebookIsStillAuthenticated:FacebookCheckIfStillAuthenicated;
		
		//When the player quits the app, set the time so we can find how long they have been away.
		private var inactivityTime:Date;
		
		public function AudioBrush()
		{
			super();
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.LOW;
			
			
			addLoadingScreen();
			
			TweenLite.delayedCall(1, startLoadingGame);
		}
		
		private function startLoadingGame():void{
			LOCALE_INSTANCE = Locale.getInstance();
			LOCALE_INSTANCE.loadXML("languages/" + DynamicConstants.CURRENT_LANGUAGE + ".xml");
			LOCALE_INSTANCE.addEventListener(Event.COMPLETE, setupGame);
			
			MobilePurchaseManager.INSTANCE;
			PushNotificationsManager.getInstance();
			PushNotificationsManager.getInstance().addEventListener(Event.COMPLETE, setupGame);
			PushNotificationsManager.getInstance().setupPN();
			
			SoundManager.getInstance();
			
			TextFieldManager.createCentrallyAllignedTextField("Warm-up fonts", FONT_audiobrush_content, 0xFFFFFF, 10);
			
			FacebookManager.getInstance();
			AssetLoader.getInstance().addEventListener(Event.COMPLETE, setupGame);
		}
		
		private function setupGame(e:Event):void{
			if(loadsComplete == 2){
				//Make sure that we have the levels calculated.
				LevelCalculator.calculateLevels();
				
				LOCALE_INSTANCE.removeEventListener(Event.COMPLETE, setupGame);
				this.removeEventListener(Event.ADDED_TO_STAGE, setupGame);
				PushNotificationsManager.getInstance().removeEventListener(Event.COMPLETE, setupGame);

				//set the screen size
				DynamicConstants.SCREEN_WIDTH = stage.fullScreenWidth;
				DynamicConstants.SCREEN_HEIGHT = stage.fullScreenHeight;
				screenManager = new ScreenManager();
				screenManager.setupDynamicScaling();
				
				enterFrameClip = new Sprite();
				stage.addChild(enterFrameClip);
				
				setupMobileStuff();
				setupListeners();
				
				singleSignOnManager = new SingleSignOnManager();
				singleSignOnManager.statusSignal.add(signSignOnAvailable);
			}
			loadsComplete++;
		}
		
		/**
		 * If Facebook is already Authenticated and the server data has been downloaded this will parse as true
		 */
		private function signSignOnAvailable(isAvailable:Boolean):void{
			singleSignOnManager.destroy();
			singleSignOnManager = null;
			ThemeTypes.populateThemes();
			this.addEventListener(Event.ACTIVATE, handleReActivation);
			this.addEventListener(Event.DEACTIVATE, handleDeActivation);
			if(isAvailable){
				FacebookConstants.DEBUG_FACEBOOK_ALLOWED = false;
				if(SettingsProxy.getInstance().handSelection == null){
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.SETTINGS_HAND_SELECTION;
				}
				else{
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_MAIN;
				}
			}
			else{
				if(DynamicConstants.isMobileOS()){
					//If this is being run on mobile lets double check that we are using the proper facebook.
					FacebookConstants.DEBUG_FACEBOOK_ALLOWED = false;
					
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MESSAGE_FACEBOOK_LOGIN;
				}
				else{
					UserData.getInstance().getUser();
					
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_MAIN;
					
					
				}
			}
			audioBrushStateManager = new GameStateHandler(this);
			TweenLite.delayedCall(1.5, audioBrushStateManager.loadState);
			TweenLite.delayedCall(1.4, removeLoadScreen);
		}
		
		/**
		 * When we are finished loading removes the splash screen
		 */
		private function removeLoadScreen():void{
			if(startupImage != null){
				this.removeChild(startupImage);
				this.removeChild(startupLoader);
				startupImage = null;
				startupLoader = null;
			}
		}
		
		/**
		 * Setup all the required global listeners
		 */
		private function setupListeners():void{
			//Setup the control which includes (at present) all the mouse listeners)
			var control:Control = Control.getInstance();
			control.init(enterFrameClip);
		}
		
		/**
		 * Anything mobile related to admin at start-up is done here
		 */
		private function setupMobileStuff():void{
			var startOrientation:String = stage.orientation;
			if (startOrientation == StageOrientation.DEFAULT || startOrientation == StageOrientation.UPSIDE_DOWN){
				stage.setOrientation(StageOrientation.ROTATED_RIGHT);
			}
			else{
				stage.setOrientation(startOrientation);
			}
			
			stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGING, orientationChangeListener, false, 0, true);
		}
		
		/**
		 * LOCK ORIENTATION TO BOTH LANDSCAPE MODES ONLY.
		 */
		private function orientationChangeListener(e:StageOrientationEvent) : void {
			if (e.afterOrientation == StageOrientation.DEFAULT || e.afterOrientation ==  StageOrientation.UPSIDE_DOWN) {
				e.preventDefault();
			}
		}
		
		/**
		 * Finds when the app is about to be closed.
		 */
		private function handleDeActivation(e:Event):void{
			LOG.debug("Application has been de-activated");
			inactivityTime = new Date();
			if(GameProxy.INSTANCE != null && GameProxy.INSTANCE.activeGame){
				GameProxy.INSTANCE.pauseSignal.dispatch(true);
			}
		}
		
		/**
		 * If the application is closed and then re-activates, we need to make sure that the person is still signed into facebook.
		 */
		private function handleReActivation(e:Event):void{
			LOG.debug("Application has been re-activated");
			var date:Number = new Date().time;
			date = date - inactivityTime.time;
			inactivityTime = null;
			if(date > 7000 && DynamicConstants.CURRENT_GAME_STATE != GameStateTypes.MESSAGE_FACEBOOK_LOGIN){
				if(FacebookManager.getInstance().checkIfUserIsLoggedIn()){
					addLoadingScreen();
					checkFacebookIsStillAuthenticated = new FacebookCheckIfStillAuthenicated();
					checkFacebookIsStillAuthenticated.statusSignal.add(isStillConnectedHandler);
					checkFacebookIsStillAuthenticated.startCheck();
				}
			}
		}
		
		private function isStillConnectedHandler(isConnected:Boolean):void{
			checkFacebookIsStillAuthenticated.destroy();
			checkFacebookIsStillAuthenticated = null;
			if(isConnected){
				
			}
			else{
				DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MESSAGE_FACEBOOK_LOGIN;
				audioBrushStateManager.removeInterfaceSignal.dispatch();
			}
			removeLoadingScreen();
		}
		
		/**
		 * Add loading screen
		 */
		private function addLoadingScreen():void{
			switch(stage.fullScreenWidth){
				case 2048:
					startupImage = new startup_image_ipad_retina() as MovieClip;
					break;
				case 1024:
					startupImage = new startup_image_ipad() as MovieClip;
					break;
				case 1136:
					startupImage = new startup_image_iphone_5() as MovieClip;
					break;
				case 960:
					startupImage = new startup_image_iphone_retina() as MovieClip;
					break;
				default:
					if(stage.fullScreenWidth > 1500){
						startupImage = new startup_image_ipad_retina() as MovieClip;
					}
					else if(stage.fullScreenWidth > 1024){
						if(stage.fullScreenHeight > 960){
							startupImage = new startup_image_ipad() as MovieClip;
						}
						else{
							startupImage = new startup_image_iphone_5() as MovieClip;
						}
					}
					else if(stage.fullScreenHeight > 768){
						startupImage = new startup_image_iphone_5() as MovieClip;
					}
					else{
						startupImage = new startup_image_ipad() as MovieClip;
					}
					startupImage.width = stage.fullScreenWidth;
					startupImage.height = stage.fullScreenHeight;
					startupImage.x = stage.fullScreenWidth*.5 - startupImage.width*.5;
					startupImage.y = stage.fullScreenHeight*.5 - startupImage.height*.5;
					break;
			}
			
			startupLoader = new ui_loading();
			startupLoader.x = stage.fullScreenWidth*.5;
			startupLoader.y = stage.fullScreenHeight*.8;
			
			this.addChild(startupImage);
			this.addChild(startupLoader);
		}
		
		private function removeLoadingScreen():void{
			TweenLite.delayedCall(0.4, removeLoadScreen);
		}
	}
}