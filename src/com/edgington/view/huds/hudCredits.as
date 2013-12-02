package com.edgington.view.huds
{
	import com.doitflash.consts.Easing;
	import com.doitflash.consts.Orientation;
	import com.doitflash.consts.ScrollConst;
	import com.doitflash.utils.scroll.TouchScroll;
	import com.edgington.constants.Constants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.types.FontFaceType;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.TextFieldManager;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.getfont;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.elements.element_mainButton;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import org.osflash.signals.Signal;
	
	public class hudCredits extends AbstractHud
	{
		
		private var readyToRemoveSignal:Signal;
		
		private var buttonOptions:Vector.<String> = new <String>["BACK"];
		
		private var backButton:element_mainButton;
		
		private var creditsHolder:Sprite;
		
		private var creditsLogo:ui_audiobrush_logo;
		
		private var textFields:Vector.<TextField>;
		
		private var _scroller:TouchScroll;
		
		public function hudCredits(removeSignal:Signal)
		{
			super();
			
			readyToRemoveSignal = removeSignal;
			
			addListeners();
			
			setupVisuals();
			
			addElements();
			
			setScroller();
		}
		
		public function addListeners():void{
			LOG.createCheckpoint("MENU: Credits");
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			superRemoveSignal.addOnce(readyForRemoval);
		}
		
		private function setupVisuals():void{
			backButton = new element_mainButton(gettext("credits_back_button"), buttonOptions[0]);
			backButton.x = DynamicConstants.SCREEN_MARGIN;
			backButton.y = DynamicConstants.SCREEN_HEIGHT - DynamicConstants.SCREEN_MARGIN - backButton.height;
			
			
			
			creditsHolder = new Sprite();
			creditsLogo = new ui_audiobrush_logo();
			creditsLogo.scaleX = creditsLogo.scaleY = DynamicConstants.MESSAGE_SCALE;
			creditsLogo.x = (DynamicConstants.SCREEN_WIDTH*.5) - (creditsLogo.width*.5);
			creditsLogo.y = DynamicConstants.SCREEN_MARGIN;
			creditsHolder.addChild(creditsLogo);
			
			textFields = new Vector.<TextField>();
			
			var tf1:TextField = TextFieldManager.createTextField(gettext("credits_developed_by"), FONT_audiobrush_content, Constants.DARK_WHITE_COLOUR, 24*DynamicConstants.MESSAGE_SCALE, false, TextFieldAutoSize.CENTER);
			tf1.y = creditsLogo.y + creditsLogo.height + DynamicConstants.BUTTON_SPACING;
			tf1.x = creditsLogo.x + (creditsLogo.width*.5) - (tf1.width*.5)
			tf1.cacheAsBitmap = true;
			textFields.push(tf1);
				
			var tf2:TextField = TextFieldManager.createTextField("Ollie Edgington", FONT_audiobrush_content_bold, Constants.NORMAL_WHITE_COLOUR, 32*DynamicConstants.MESSAGE_SCALE, false, TextFieldAutoSize.CENTER);
			tf2.y = tf1.y + (tf1.textHeight*1.1);
			tf2.x = creditsLogo.x + (creditsLogo.width*.5) - (tf2.width*.5);
			tf2.cacheAsBitmap = true;
			textFields.push(tf2);

			var tf3:TextField = TextFieldManager.createTextField(gettext("credits_server_management"), FONT_audiobrush_content, Constants.DARK_WHITE_COLOUR, 24*DynamicConstants.MESSAGE_SCALE, false, TextFieldAutoSize.CENTER);
			tf3.y = tf2.y + (tf2.textHeight*2.1);
			tf3.x = creditsLogo.x + (creditsLogo.width*.5) - (tf3.width*.5);
			tf3.cacheAsBitmap = true;
			textFields.push(tf3);
			
			var tf4:TextField = TextFieldManager.createTextField("Jon Parsons", FONT_audiobrush_content_bold, Constants.NORMAL_WHITE_COLOUR, 32*DynamicConstants.MESSAGE_SCALE, false, TextFieldAutoSize.CENTER);
			tf4.y = tf3.y + (tf3.textHeight*1.1);
			tf4.x = creditsLogo.x + (creditsLogo.width*.5) - (tf4.width*.5);
			tf4.cacheAsBitmap = true;
			textFields.push(tf4);
			
			var tf5:TextField = TextFieldManager.createTextField(gettext("credits_community"), FONT_audiobrush_content, Constants.DARK_WHITE_COLOUR, 24*DynamicConstants.MESSAGE_SCALE, false, TextFieldAutoSize.CENTER);
			tf5.y = tf4.y + (tf4.textHeight*2.1);
			tf5.x = creditsLogo.x + (creditsLogo.width*.5) - (tf5.width*.5);
			tf5.cacheAsBitmap = true;
			textFields.push(tf5);
			
			var tf6:TextField = TextFieldManager.createCentrallyAllignedTextField("Vernon Wroe\nMatt Clark\nSimone Edgington", FONT_audiobrush_content_bold, Constants.NORMAL_WHITE_COLOUR, 32*DynamicConstants.MESSAGE_SCALE, true, tf1.textWidth*2);
			tf6.y = tf5.y + (tf5.textHeight*1.1);
			tf6.x = creditsLogo.x + (creditsLogo.width*.5) - (tf6.width*.5);
			tf6.cacheAsBitmap = true;
			textFields.push(tf6);
			
			var tf7:TextField = TextFieldManager.createTextField(gettext("credits_voice"), FONT_audiobrush_content, Constants.DARK_WHITE_COLOUR, 24*DynamicConstants.MESSAGE_SCALE, false, TextFieldAutoSize.CENTER);
			tf7.y = tf6.y + (tf6.textHeight + (tf4.textHeight*1.1));//different setup
			tf7.x = creditsLogo.x + (creditsLogo.width*.5) - (tf7.width*.5);
			tf7.cacheAsBitmap = true;
			textFields.push(tf7);
			
			var tf8:TextField = TextFieldManager.createTextField("Alex Lorimer", FONT_audiobrush_content_bold, Constants.NORMAL_WHITE_COLOUR, 32*DynamicConstants.MESSAGE_SCALE, false, TextFieldAutoSize.CENTER);
			tf8.y = tf7.y + (tf7.textHeight*1.1);
			tf8.x = creditsLogo.x + (creditsLogo.width*.5) - (tf8.width*.5);
			tf8.cacheAsBitmap = true;
			textFields.push(tf8);
			
			var tf9:TextField = TextFieldManager.createTextField(gettext("credits_developed_with"), FONT_audiobrush_content, Constants.DARK_WHITE_COLOUR, 24*DynamicConstants.MESSAGE_SCALE, false, TextFieldAutoSize.CENTER);
			tf9.y = tf8.y + (tf8.textHeight*2.1);
			tf9.x = creditsLogo.x + (creditsLogo.width*.5) - (tf9.width*.5);
			tf9.cacheAsBitmap = true;
			textFields.push(tf9);
			
			var tf10:TextField = TextFieldManager.createTextField("Adobe AIR", FONT_audiobrush_content_bold, Constants.NORMAL_WHITE_COLOUR, 32*DynamicConstants.MESSAGE_SCALE, false, TextFieldAutoSize.CENTER);
			tf10.y = tf9.y + (tf9.textHeight*1.1);
			tf10.x = creditsLogo.x + (creditsLogo.width*.5) - (tf10.width*.5);
			tf10.cacheAsBitmap = true;
			textFields.push(tf10);
			
			var tf11:TextField = TextFieldManager.createTextField(gettext("credits_thanks"), FONT_audiobrush_content, Constants.DARK_WHITE_COLOUR, 24*DynamicConstants.MESSAGE_SCALE, false, TextFieldAutoSize.CENTER);
			tf11.y = tf10.y + (tf10.textHeight*2.1);
			tf11.x = creditsLogo.x + (creditsLogo.width*.5) - (tf11.width*.5);
			tf11.cacheAsBitmap = true;
			textFields.push(tf11);
			
			var tf12:TextField = TextFieldManager.createCentrallyAllignedTextField("Raymond Walt\nOlivier Perron\nMarcel Thieß", FONT_audiobrush_content_bold, Constants.NORMAL_WHITE_COLOUR, 32*DynamicConstants.MESSAGE_SCALE, true, tf1.textWidth*2);
			tf12.y = tf11.y + (tf11.textHeight*1.1);
			tf12.x = creditsLogo.x + (creditsLogo.width*.5) - (tf12.width*.5);
			tf12.cacheAsBitmap = true;
			textFields.push(tf12);
			
			for(var i:int = 0; i < textFields.length; i++){
				creditsHolder.addChild(textFields[i]);
			}
			
			var blankSprite:Sprite = new Sprite();
			blankSprite.graphics.beginFill(0x000000);
			blankSprite.graphics.drawRect(0, 0, 1, 1);
			blankSprite.graphics.endFill();
			
			blankSprite.x = tf12.x;
			blankSprite.y = tf12.y + (400 * DynamicConstants.DEVICE_SCALE);
			
			creditsHolder.addChild(blankSprite);
			
			creditsHolder.x = -(DynamicConstants.SCREEN_WIDTH - creditsHolder.width)*.5;
			
			addButton(backButton);
			
			buttonSignal.add(handleInteraction);
			
			onScreenElements.push(backButton, creditsHolder);
		}
		
		private function handleInteraction(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_SETTINGS;
					cleanButtons();
					break;
			}
		}
		
		public function readyForRemoval():void{
			super.destroy();
			readyToRemoveSignal.dispatch();
		}
		
		private function destroy(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
		}
		
		private function setScroller():void
		{
			if (!_scroller) 
			{
				_scroller =  new TouchScroll();
			}
			
			//------------------------------------------------------------------------------ set Scroller
			_scroller.maskContent = creditsHolder;
			_scroller.maskWidth = creditsHolder.width;
			_scroller.maskHeight = DynamicConstants.SCREEN_HEIGHT;
			_scroller.enableVirtualBg = true;
			_scroller.mouseWheelSpeed = 5;
			
			_scroller.orientation = Orientation.VERTICAL; // accepted values: Orientation.AUTO, Orientation.VERTICAL, Orientation.HORIZONTAL
			_scroller.easeType = Easing.Strong_easeOut;
			_scroller.scrollSpace = 0;
			_scroller.aniInterval = .5;
			_scroller.blurEffect = false;
			_scroller.lessBlurSpeed = 3;
			//_scroller.yPerc = 0; // min value is 0, max value is 100
			//_scroller.xPerc = 0; // min value is 0, max value is 100
			_scroller.mouseWheelSpeed = 2;
			_scroller.isMouseScroll = false;
			_scroller.isTouchScroll = true;
			_scroller.bitmapMode = ScrollConst.WEAK;
			; // use it for smoother scrolling, special when working on mobile devices, accepted values: "normal", "weak", "strong"
			_scroller.isStickTouch = false;
			_scroller.holdArea = 10;
			
			_scroller.x = (DynamicConstants.SCREEN_WIDTH*.5) - (creditsHolder.width*.5);
			_scroller.y = 0;
			
			this.addChildAt(_scroller, 0);
		}
	}
}