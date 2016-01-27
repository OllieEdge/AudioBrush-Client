package
{
		import com.edgington.constants.Constants;
		import com.edgington.constants.DynamicConstants;
		import com.edgington.constants.FontConstants;
		import com.edgington.control.Control;
		import com.edgington.model.GameProxy;
		import com.edgington.model.InitialLoadManager;
		import com.edgington.model.SettingsProxy;
		import com.edgington.model.audio.AudioModel;
		import com.edgington.model.calculators.LevelCalculator;
		import com.edgington.model.facebook.FacebookCheckIfStillAuthenicated;
		import com.edgington.model.facebook.FacebookManager;
		import com.edgington.net.SingleSignOnManager;
		import com.edgington.net.UserData;
		import com.edgington.types.FontFaceType;
		import com.edgington.types.GameStateTypes;
		import com.edgington.types.ThemeTypes;
		import com.edgington.util.LanguageIdentifier;
		import com.edgington.util.TextFieldManager;
		import com.edgington.util.debug.LOG;
		import com.edgington.util.localisation.getfont;
		import com.edgington.view.GameStateHandler;
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
		import flash.media.AudioPlaybackMode;
		import flash.media.SoundMixer;
		import flash.text.TextField;
	
	[SWF(backgroundColor='#000000', frameRate='60', width='1024', height='768')]
	
	public class AudioBrush extends Sprite
	{
		
		private var enterFrameClip:Sprite;
		
		private var audioBrushStateManager:GameStateHandler;
		
		private var screenManager:ScreenManager;
		
		private var startupImage:MovieClip;
		private var startupLoader:ui_loading;
		private var startupLoadingText:TextField
		
		private var singleSignOnManager:SingleSignOnManager;
		
		private var checkFacebookIsStillAuthenticated:FacebookCheckIfStillAuthenicated;
		
		//When the player quits the app, set the time so we can find how long they have been away.
		private var inactivityTime:Date;
		
		private var initialLoadManager:InitialLoadManager;
		
		public function AudioBrush()
		{
			super();
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.LOW;
			
			DynamicConstants.CURRENT_LANGUAGE = LanguageIdentifier.getBestLanguageTagForUser();
			FontConstants.decideNativeFontUse(DynamicConstants.CURRENT_LANGUAGE);
			
			SoundMixer.audioPlaybackMode = AudioPlaybackMode.AMBIENT;
			
			addLoadingScreen();
			
			TweenLite.delayedCall(1.5, startLoadingGame);
		}
		
		private function startLoadingGame():void{
			
			TextFieldManager.createCentrallyAllignedTextField("Warm-up fonts", FONT_audiobrush_content, 0xFFFFFF, 10);
			LOG.createCheckpoint("APP: Initial Load Started"); 
			initialLoadManager = new InitialLoadManager(startupLoadingText);
			initialLoadManager.addEventListener(Event.COMPLETE, setupGame);
		}
		
		private function setupGame(e:Event):void{
				LOG.createCheckpoint("APP: Initial Load Complete");	
				
				AudioModel.getInstance();
				AudioModel.getInstance().getIpodLibrary();
				
				//Make sure that we have the levels calculated.
				LevelCalculator.calculateLevels();
				
				this.removeEventListener(Event.ADDED_TO_STAGE, setupGame);

				//set the screen size
				DynamicConstants.SCREEN_WIDTH = stage.stageWidth;
				DynamicConstants.SCREEN_HEIGHT = stage.stageHeight;
				screenManager = new ScreenManager();
				screenManager.setupDynamicScaling();
				
				enterFrameClip = new Sprite();
				stage.addChild(enterFrameClip);
				
				setupMobileStuff();
				setupListeners();
				
				singleSignOnManager = new SingleSignOnManager(startupLoadingText);
				singleSignOnManager.statusSignal.add(signSignOnAvailable);
		}
		
		/**
		 * If Facebook is already Authenticated and the server data has been downloaded this will parse as true
		 */
		private function signSignOnAvailable(isAvailable:Boolean):void{
			if(singleSignOnManager != null){
				singleSignOnManager.destroy();
				singleSignOnManager = null;
				ThemeTypes.populateThemes();
				this.addEventListener(Event.ACTIVATE, handleReActivation);
				this.addEventListener(Event.DEACTIVATE, handleDeActivation);
				if(isAvailable){
					//FacebookConstants.DEBUG_FACEBOOK_ALLOWED = false;
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
						//FacebookConstants.DEBUG_FACEBOOK_ALLOWED = false;
						
						DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MESSAGE_FACEBOOK_LOGIN;
					}
					else{
						UserData.getInstance().getUser();
						
						DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_MAIN;
						
						
					}
				}
				audioBrushStateManager = new GameStateHandler(this);
				TweenLite.delayedCall(1, audioBrushStateManager.loadState);
				TweenLite.delayedCall(0.9, removeLoadScreen);
			}
		}
		
		/**
		 * When we are finished loading removes the splash screen
		 */
		private function removeLoadScreen():void{
			if(startupImage != null){
				this.removeChild(startupImage);
				this.removeChild(startupLoader);
				this.removeChild(startupLoadingText);
				startupImage = null;
				startupLoader = null;
				startupLoadingText = null;
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
//			if (startOrientation == StageOrientation.DEFAULT || startOrientation == StageOrientation.UPSIDE_DOWN){
//				stage.setOrientation(StageOrientation.ROTATED_RIGHT);
//			}
//			else{
//				stage.setOrientation(startOrientation);
//			}
			
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
			LOG.createCheckpoint("APP: Deactivated");
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
			LOG.createCheckpoint("APP: Activated");
			LOG.debug("Application has been re-activated");
			if(inactivityTime != null){
				var date:Number = new Date().time;
				date = date - inactivityTime.time;
				inactivityTime = null;
				if(date > 7000 && !DynamicConstants.DISABLE_RELOAD){
					if(FacebookManager.getInstance().checkIfUserIsLoggedIn()){
						addLoadingScreen();
						checkFacebookIsStillAuthenticated = new FacebookCheckIfStillAuthenicated();
						checkFacebookIsStillAuthenticated.statusSignal.add(isStillConnectedHandler);
						checkFacebookIsStillAuthenticated.startCheck();
					}
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
			
			startupLoadingText = TextFieldManager.createCentrallyAllignedTextField("by Ollie Edgington", FONT_audiobrush_content_bold, Constants.NORMAL_WHITE_COLOUR, 18);
			getfont(startupLoadingText, FontFaceType.BOLD);
			startupLoadingText.y = startupLoader.y + (startupLoader.height*.5) + 40;
			startupLoadingText.x = startupLoader.x - startupLoadingText.textWidth*.5;
			
			this.addChild(startupImage);
			this.addChild(startupLoader);
			this.addChild(startupLoadingText);
		}
		
		private function removeLoadingScreen():void{
			TweenLite.delayedCall(0.4, removeLoadScreen);
		}
	}
}