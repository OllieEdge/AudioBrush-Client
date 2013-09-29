package
{
		import com.edgington.constants.DynamicConstants;
		import com.edgington.constants.FacebookConstants;
		import com.edgington.control.Control;
		import com.edgington.model.SoundManager;
		import com.edgington.model.facebook.FacebookManager;
		import com.edgington.model.payments.MobilePurchaseManager;
		import com.edgington.net.NetManager;
		import com.edgington.net.UserData;
		import com.edgington.types.GameStateTypes;
		import com.edgington.types.ThemeTypes;
		import com.edgington.util.PushNotificationsManager;
		import com.edgington.util.TextFieldManager;
		import com.edgington.util.localisation.LOCALE_INSTANCE;
		import com.edgington.util.localisation.Locale;
		import com.edgington.view.GameStateHandler;
		import com.edgington.view.assets.AssetLoader;
		import com.edgington.view.model.ScreenManager;
		
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
		
		public function AudioBrush()
		{
			super();
			
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
			
			this.addEventListener(Event.ADDED_TO_STAGE, setupGame);
			
		}
		
		private function setupGame(e:Event):void{
			if(loadsComplete == 3){
				LOCALE_INSTANCE.removeEventListener(Event.COMPLETE, setupGame);
				this.removeEventListener(Event.ADDED_TO_STAGE, setupGame);
				PushNotificationsManager.getInstance().removeEventListener(Event.COMPLETE, setupGame);
				// support autoOrients
				stage.align = StageAlign.TOP_LEFT;
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.quality = StageQuality.LOW;
				
				//set the screen size
				DynamicConstants.SCREEN_WIDTH = stage.fullScreenWidth;
				DynamicConstants.SCREEN_HEIGHT = stage.fullScreenHeight;
				screenManager = new ScreenManager();
				screenManager.setupDynamicScaling();
				
				enterFrameClip = new Sprite();
				stage.addChild(enterFrameClip);
				
				setupMobileStuff();
				setupListeners();
				
				loadGame();
			}
			loadsComplete++;
		}
		
		private function loadGame():void{
			//Make sure that we populate the themes before the background is loaded.
			ThemeTypes.populateThemes();
			
			if(DynamicConstants.isMobileOS()){
				//If this is being run on mobile lets make sure that we use the proper facebook.
				FacebookConstants.DEBUG_FACEBOOK_ALLOWED = false;
				
				DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MESSAGE_FACEBOOK_LOGIN;
			}
			else{
				//NetManager.CORE_URL = "http://192.168.33.10:3000/api/";
				UserData.getInstance().getUser();
				//GiftData.getInstance().postGifts(null, 1);
				DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_MAIN;
			}
			
			audioBrushStateManager = new GameStateHandler(this);
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
	}
}