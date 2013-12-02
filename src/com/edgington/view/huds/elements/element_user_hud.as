package com.edgington.view.huds.elements
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.SoundConstants;
	import com.edgington.control.Control;
	import com.edgington.model.SoundManager;
	import com.edgington.model.calculators.LevelCalculator;
	import com.edgington.model.facebook.FacebookManager;
	import com.edgington.net.GiftData;
	import com.edgington.net.UserData;
	import com.edgington.types.FontFaceType;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.localisation.getfont;
	import com.edgington.util.localisation.gettext;
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.osflash.signals.Signal;
	
	public class element_user_hud extends Sprite
	{
		
		public static var HEIGHT:int;
		
		private var barBackground:ui_main_menu_bar_background;
		private var profilePicture:element_profile_picture;
		
		private var credits:credits_box;
		
		private var level:ui_level_box;
		
		private var inbox:ui_button_inbox;
		private var inbox_badge:badge_indicator;
		
		private var store:ui_buton_store;
		private var settings:ui_button_settings;
		
		private var achievements:ui_button_achievements;
		
		private var inboxCount:int = 0;
		
		public var currentHudSignal:Signal;
		
		private var largeState:Boolean = true; // If the hud is in it's "large" state this will be true;
		
		private var tweens:Vector.<TweenMax>;
		
		//If true the hud will be on the right and not the left.
		private var RIGHT:Boolean = true;
		
		private var profilePictureSize:int = 150;
		private var buttonPercentageScale:Number = .30;
		
		
		public function element_user_hud()
		{
			super();
			
			addListeners();
			
			setupVisuals();
			
			GiftData.getInstance().getGifts();
		}
		
		private function addListeners():void{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			UserData.getInstance().userDataSignal.add(handleUserDataUpdate);
			GiftData.getInstance().giftDataSignal.add(handleGiftDataUpdate);
		}
		
		private function setupVisuals():void{
			
			barBackground = new ui_main_menu_bar_background();
			barBackground.height = DynamicConstants.SCREEN_HEIGHT*0.07;
			barBackground.width = DynamicConstants.SCREEN_WIDTH;
			barBackground.cacheAsBitmap = true;
			
			if(FacebookManager.getInstance().checkIfUserIsLoggedIn() /*|| FacebookConstants.DEBUG_FACEBOOK_ALLOWED*/){
//				if(FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
//					profilePicture = new element_profile_picture(null, FacebookConstants.DEBUG_USER_ID);
//				}
//				else{
					profilePicture = new element_profile_picture(null, FacebookManager.getInstance().currentLoggedInUser.id);		
//				}
			}
			
			profilePicture.width = profilePicture.height = profilePictureSize*DynamicConstants.MESSAGE_SCALE;
			profilePicture.y = DynamicConstants.BUTTON_SPACING;
			
			level = new ui_level_box();
			
			getfont(level.txt_level, FontFaceType.BOLD);
			getfont(level.txt_percentage, FontFaceType.BOLD);
			
			level.height = profilePicture.height*buttonPercentageScale;
			level.scaleX = level.scaleY;
			level.txt_level.text = String(LevelCalculator.getLevel(UserData.getInstance().userProfile.xp));
			level.txt_percentage.text = gettext("user_hud_level_percentage", {percentage:LevelCalculator.getNextLevelPercentage(UserData.getInstance().userProfile.xp)});
			level.bar.scaleX = LevelCalculator.getNextLevelPercentage(UserData.getInstance().userProfile.xp) * 0.01;
			level.y = Math.max(barBackground.height - level.height*.5, DynamicConstants.BUTTON_SPACING);
			
			credits = new credits_box();
			
			getfont(credits.txt_label, FontFaceType.BOLD);
			
			credits.height = profilePicture.height*buttonPercentageScale;
			credits.scaleX = credits.scaleY;
			credits.txt_label.text = String(UserData.getInstance().userProfile.credits);
			credits.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			credits.y = Math.max(barBackground.height - credits.height*.5, DynamicConstants.BUTTON_SPACING);
			
			inbox = new ui_button_inbox();
			inbox.height = credits.height;
			inbox.scaleX = inbox.scaleY;
			inbox.y = credits.y;
			
			inbox_badge = new badge_indicator();
			getfont(inbox_badge.txt_label, FontFaceType.BOLD);
			inbox_badge.scaleX = inbox_badge.scaleY = DynamicConstants.DEVICE_SCALE;
			
			inbox_badge.y = inbox.y;
			inbox_badge.visible = false;
			
			inbox.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			inbox.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			inbox.addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
			
			achievements = new ui_button_achievements();
			achievements.scaleX = achievements.scaleY = inbox.scaleX;
			achievements.y = credits.y;
			achievements.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			achievements.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			achievements.addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
			
			store = new ui_buton_store();
			store.scaleX = store.scaleY = inbox.scaleX;
			store.y = credits.y;
			store.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			store.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			store.addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
			
			settings = new ui_button_settings();
			settings.scaleX = settings.scaleY = inbox.scaleX;
			settings.y = credits.y;
			settings.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			settings.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			settings.addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
			
			if(RIGHT){
				profilePicture.x = DynamicConstants.SCREEN_WIDTH - DynamicConstants.BUTTON_SPACING - profilePicture.width;
				level.x =  profilePicture.x - DynamicConstants.BUTTON_SPACING - level.width;
				credits.x = level.x - DynamicConstants.BUTTON_SPACING - credits.width;
				
				inbox.x = credits.x - DynamicConstants.BUTTON_SPACING - inbox.width;
				
				achievements.x = inbox.x - DynamicConstants.BUTTON_SPACING - achievements.width;
				
				store.x = achievements.x - DynamicConstants.BUTTON_SPACING - store.width;

				settings.x = store.x - DynamicConstants.BUTTON_SPACING - settings.width;
			
			}
			else{
				profilePicture.x = DynamicConstants.BUTTON_SPACING;
				
				credits.x = profilePicture.x +profilePicture.width+ DynamicConstants.BUTTON_SPACING;
				
				inbox.x = credits.x + credits.width + DynamicConstants.BUTTON_SPACING;
				
				achievements.x = inbox.x + inbox.width + DynamicConstants.BUTTON_SPACING;
				
				store.x = achievements.x + achievements.width + DynamicConstants.BUTTON_SPACING;
				
				settings.x = store.x + store.width + DynamicConstants.BUTTON_SPACING;
			}
			inbox_badge.x = inbox.x + inbox.width;
			
			this.addChild(barBackground);
			this.addChild(profilePicture);
			this.addChild(level);
			this.addChild(credits);
			this.addChild(inbox);
			this.addChild(achievements);
			this.addChild(store);
			this.addChild(settings);
			this.addChild(inbox_badge);
			
			element_user_hud.HEIGHT = this.height;
		}
		
		public function animate(animateIn:Boolean = true):void{
			//Animate to the large version if it's not already.
			if(animateIn && !largeState){
				largeState = true;
				largeScale();
			}
			//If not that we want to animate to the small scale.
			else if(!animateIn && largeState){
				largeState = false;
				smallScale();
			}
		}
		
		private function smallScale():void{
			cleanAllTweens();
			inbox_badge.scaleX = inbox_badge.scaleY = DynamicConstants.DEVICE_SCALE*.5;
			inbox_badge.txt_label.visible = false;
			if(RIGHT){
				tweens.push(TweenMax.to(profilePicture, 0.5, {height:barBackground.height-2, width:barBackground.height-2, x:DynamicConstants.SCREEN_WIDTH - (barBackground.height-2), y:1, ease:Quad.easeOut}));
				tweens.push(TweenMax.to(level, 0.5, {height:barBackground.height-2, y:1, ease:Quad.easeOut, onUpdate:updateElementsWidthSmall}));
				tweens.push(TweenMax.to(credits, 0.5, {height:barBackground.height-2, y:1, ease:Quad.easeOut, onUpdate:updateElementsWidthSmall}));
				tweens.push(TweenMax.to(inbox, 0.5, {height:barBackground.height-2, y:1, ease:Quad.easeOut, onUpdate:updateElementsWidthSmall}));
				tweens.push(TweenMax.to(achievements, 0.5, {height:barBackground.height-2, y:1, ease:Quad.easeOut, onUpdate:updateElementsWidthSmall}));
				tweens.push(TweenMax.to(store, 0.5, {height:barBackground.height-2, y:1, ease:Quad.easeOut, onUpdate:updateElementsWidthSmall}));
				tweens.push(TweenMax.to(settings, 0.5, {height:barBackground.height-2, y:1, ease:Quad.easeOut, onUpdate:updateElementsWidthSmall}));
			}
			else{
				tweens.push(TweenMax.to(profilePicture, 0.5, {height:barBackground.height-2, width:barBackground.height-2, x:1, y:1, ease:Quad.easeOut}));
				tweens.push(TweenMax.to(level, 0.5, {height:barBackground.height-2, x:tweens[0].vars.x + tweens[0].vars.width, y:1, ease:Quad.easeOut, onUpdate:updateElementsWidthSmall}));
				tweens.push(TweenMax.to(credits, 0.5, {height:barBackground.height-2, y:1, ease:Quad.easeOut, onUpdate:updateElementsWidthSmall}));
				tweens.push(TweenMax.to(inbox, 0.5, {height:barBackground.height-2, y:1, ease:Quad.easeOut, onUpdate:updateElementsWidthSmall}));
				tweens.push(TweenMax.to(achievements, 0.5, {height:barBackground.height-2, y:1, ease:Quad.easeOut, onUpdate:updateElementsWidthSmall}));
				tweens.push(TweenMax.to(store, 0.5, {height:barBackground.height-2, y:1, ease:Quad.easeOut, onUpdate:updateElementsWidthSmall}));
				tweens.push(TweenMax.to(settings, 0.5, {height:barBackground.height-2, y:1, ease:Quad.easeOut, onUpdate:updateElementsWidthSmall}));	
			}
		}
		private function largeScale():void{
			cleanAllTweens();
			inbox_badge.scaleX = inbox_badge.scaleY = DynamicConstants.DEVICE_SCALE;
			inbox_badge.txt_label.visible = false;
			inbox_badge.txt_label.visible = true;
			if(RIGHT){
				tweens.push(TweenMax.to(profilePicture, 0.5, {height:profilePictureSize*DynamicConstants.MESSAGE_SCALE, width:profilePictureSize*DynamicConstants.MESSAGE_SCALE, x: DynamicConstants.SCREEN_WIDTH - DynamicConstants.BUTTON_SPACING - (profilePictureSize*DynamicConstants.MESSAGE_SCALE), y:DynamicConstants.BUTTON_SPACING, ease:Quad.easeOut}));
				tweens.push(TweenMax.to(level, 0.5, {height:tweens[0].vars.height*buttonPercentageScale, y:Math.max(DynamicConstants.BUTTON_SPACING, barBackground.height - ((tweens[0].vars.height*buttonPercentageScale)*.5)), ease:Quad.easeOut, onUpdate:updateElementsWidthLarge}));
				tweens.push(TweenMax.to(credits, 0.5, {height:tweens[0].vars.height*buttonPercentageScale, y:Math.max(DynamicConstants.BUTTON_SPACING, barBackground.height - ((tweens[0].vars.height*buttonPercentageScale)*.5)), ease:Quad.easeOut, onUpdate:updateElementsWidthLarge}));
				tweens.push(TweenMax.to(inbox, 0.5, {height:tweens[1].vars.height, y:Math.max(DynamicConstants.BUTTON_SPACING, barBackground.height - ((tweens[1].vars.height)*.5)), ease:Quad.easeOut, onUpdate:updateElementsWidthLarge, onComplete:updateInbox}));
				tweens.push(TweenMax.to(achievements, 0.5, {height:tweens[1].vars.height, y:Math.max(DynamicConstants.BUTTON_SPACING, barBackground.height - ((tweens[1].vars.height)*.5)), ease:Quad.easeOut, onUpdate:updateElementsWidthLarge}));
				tweens.push(TweenMax.to(store, 0.5, {height:tweens[1].vars.height, y:Math.max(DynamicConstants.BUTTON_SPACING, barBackground.height - ((tweens[1].vars.height)*.5)), ease:Quad.easeOut, onUpdate:updateElementsWidthLarge}));
				tweens.push(TweenMax.to(settings, 0.5, {height:tweens[1].vars.height, y:Math.max(DynamicConstants.BUTTON_SPACING, barBackground.height - ((tweens[1].vars.height)*.5)), ease:Quad.easeOut, onUpdate:updateElementsWidthLarge}));
			}
			else{
				tweens.push(TweenMax.to(profilePicture, 0.5, {height:profilePictureSize*DynamicConstants.MESSAGE_SCALE, width:profilePictureSize*DynamicConstants.MESSAGE_SCALE, x:DynamicConstants.BUTTON_SPACING, y:DynamicConstants.BUTTON_SPACING, ease:Quad.easeOut}));
				tweens.push(TweenMax.to(credits, 0.5, {height:tweens[0].vars.height*buttonPercentageScale, y:Math.max(DynamicConstants.BUTTON_SPACING, barBackground.height - ((tweens[0].vars.height*buttonPercentageScale)*.5)), ease:Quad.easeOut, onUpdate:updateElementsWidthLarge}));
				tweens.push(TweenMax.to(inbox, 0.5, {height:tweens[1].vars.height, y:Math.max(DynamicConstants.BUTTON_SPACING, barBackground.height - ((tweens[1].vars.height)*.5)), ease:Quad.easeOut, onUpdate:updateElementsWidthLarge, onComplete:updateInbox}));
				tweens.push(TweenMax.to(achievements, 0.5, {height:tweens[1].vars.height, y:Math.max(DynamicConstants.BUTTON_SPACING, barBackground.height - ((tweens[1].vars.height)*.5)), ease:Quad.easeOut, onUpdate:updateElementsWidthLarge}));
				tweens.push(TweenMax.to(store, 0.5, {height:tweens[1].vars.height, y:Math.max(DynamicConstants.BUTTON_SPACING, barBackground.height - ((tweens[1].vars.height)*.5)), ease:Quad.easeOut, onUpdate:updateElementsWidthLarge}));
				tweens.push(TweenMax.to(settings, 0.5, {height:tweens[1].vars.height, y:Math.max(DynamicConstants.BUTTON_SPACING, barBackground.height - ((tweens[1].vars.height)*.5)), ease:Quad.easeOut, onUpdate:updateElementsWidthLarge}));
			}
		}
		private function updateElementsWidthSmall():void{
			if(RIGHT){
				level.scaleX = level.scaleY;
				level.x = profilePicture.x - level.width;
				credits.scaleX = credits.scaleY;
				credits.x = level.x - credits.width;
				inbox.scaleX = inbox.scaleY;
				inbox.x = credits.x - inbox.width;
				achievements.scaleX = achievements.scaleY;
				achievements.x = inbox.x - achievements.width;
				store.scaleX = store.scaleY;
				store.x = achievements.x - store.width
				settings.scaleX = settings.scaleY;
				settings.x = store.x - settings.width;
			}
			else{
				level.scaleX = level.scaleY;
				level.x = profilePicture.x + profilePicture.width;
				credits.scaleX = credits.scaleY;
				credits.x + level.x + level.width;
				inbox.scaleX = inbox.scaleY;
				inbox.x = credits.x + credits.width;
				achievements.scaleX = achievements.scaleY;
				achievements.x = inbox.x + inbox.width;
				store.scaleX = store.scaleY;
				store.x = achievements.x + achievements.width;
				settings.scaleX = settings.scaleY;
				settings.x = store.x + store.width;
			}
			inbox_badge.x = inbox.x + inbox.width*0.8;
			inbox_badge.y = inbox.y+inbox.height*.25;
		}
		private function updateElementsWidthLarge():void{
			if(RIGHT){
				level.scaleX = level.scaleY;
				level.x = profilePicture.x - level.width - DynamicConstants.BUTTON_SPACING;
				credits.scaleX = credits.scaleY;
				credits.x = level.x - credits.width - DynamicConstants.BUTTON_SPACING;
				inbox.scaleX = inbox.scaleY;
				inbox.x = credits.x - inbox.width  - DynamicConstants.BUTTON_SPACING;
				achievements.scaleX = achievements.scaleY;
				achievements.x = inbox.x - achievements.width  - DynamicConstants.BUTTON_SPACING;
				store.scaleX = store.scaleY;
				store.x = achievements.x - store.width - DynamicConstants.BUTTON_SPACING;
				settings.scaleX = settings.scaleY;
				settings.x = store.x - settings.width - DynamicConstants.BUTTON_SPACING;
			}
			else{
				level.scaleX = level.scaleY;
				level.x = profilePicture.x +profilePicture.width+ DynamicConstants.BUTTON_SPACING;
				credits.scaleX = credits.scaleY;
				credits.x = level.x +level.width+ DynamicConstants.BUTTON_SPACING;
				inbox.scaleX = inbox.scaleY;
				inbox.x = credits.x + credits.width+DynamicConstants.BUTTON_SPACING;
				achievements.scaleX = achievements.scaleY;
				achievements.x = inbox.x + inbox.width+DynamicConstants.BUTTON_SPACING;
				store.scaleX = store.scaleY;
				store.x = achievements.x + achievements.width+DynamicConstants.BUTTON_SPACING;
				settings.scaleX = settings.scaleY;
				settings.x = store.x + store.width+DynamicConstants.BUTTON_SPACING;
			}
			inbox_badge.x = inbox.x + inbox.width;
			inbox_badge.y = inbox.y;
		}
		
		private function updateInbox():void{
			GiftData.getInstance().getGifts();
		}
		
		private function cleanAllTweens():void{
			if(tweens != null){
				while(tweens.length > 0){
					tweens[0].kill();
					tweens[0] = null;
					tweens.shift();
				}
			}
			tweens = new Vector.<TweenMax>;
		}
		
		private function handleMouseDown(e:MouseEvent):void{
			if(!Control.disableMouse){
				e.currentTarget.gotoAndStop(2);
			}
		}
		private function handleMouseUp(e:MouseEvent):void{
			if(!Control.disableMouse){
				SoundManager.getInstance().loadAndPlaySFX(SoundConstants.SFX_BUTTON_CLICK, "", 1);
				e.currentTarget.gotoAndStop(1);
				switch(e.currentTarget){
					case credits:
						DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.PURCHASES;
						break;
					case inbox:
						DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_INBOX;
						break;
					case store:
						DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.PURCHASES;
						break;
					case settings:
						DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_SETTINGS;
						break;
					case achievements:
						DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_ACHIEVEMENTS;
						break;
				}
				currentHudSignal.dispatch();
			}
		}
		private function handleMouseOut(e:MouseEvent):void{
			e.currentTarget.gotoAndStop(1);
		}
		
		//When ever the user data is updateed this is fired.
		private function handleUserDataUpdate():void{
			credits.txt_label.text = String(UserData.getInstance().userProfile.credits);
			level.txt_level.text = String(LevelCalculator.getLevel(UserData.getInstance().userProfile.xp));
			level.txt_percentage.text = gettext("user_hud_level_percentage", {percentage:LevelCalculator.getNextLevelPercentage(UserData.getInstance().userProfile.xp)});
			level.bar.scaleX = LevelCalculator.getNextLevelPercentage(UserData.getInstance().userProfile.xp) * 0.01;
			if(FacebookManager.getInstance().checkIfUserIsLoggedIn()/* || FacebookConstants.DEBUG_FACEBOOK_ALLOWED*/){
//				if(FacebookConstants.DEBUG_FACEBOOK_ALLOWED){
//					profilePicture.changeImage(FacebookConstants.DEBUG_USER_ID);
//				}
//				else{
					profilePicture.changeImage(FacebookManager.getInstance().currentLoggedInUser.id);		
//				}
			}
		}
		
		private function handleGiftDataUpdate():void{
			inboxCount = GiftData.getInstance().gifts.length;
			if(inboxCount > 0){
				inbox_badge.visible = true;
				if(largeState){
					inbox_badge.x = inbox.x + inbox.width;
					inbox_badge.y = inbox.y;
				}
				else{
					inbox_badge.x = inbox.x + inbox.width*0.8;
					inbox_badge.y = inbox.y+inbox.height*.25;
				}
				if(inboxCount > 99){
					inbox_badge.txt_label.text = "+99";
				}
				else{
					inbox_badge.txt_label.text = String(inboxCount);
				}
			}
			else{
				inbox_badge.visible = false;
			}
		}
		
		private function destroy(e:Event):void{
			cleanAllTweens();
			
			UserData.getInstance().userDataSignal.remove(handleUserDataUpdate);
			GiftData.getInstance().giftDataSignal.remove(handleGiftDataUpdate);
			
			credits.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			
			inbox.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			inbox.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			inbox.removeEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
			
			achievements.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			achievements.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			achievements.removeEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
			
			store.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			store.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			store.removeEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
			
			settings.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			settings.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			settings.removeEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
			
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			
			barBackground = null;
			
			
			profilePicture = null;
			
			credits = null;
			
			level = null;
			
			inbox = null;
			inbox_badge = null;
			
			store = null;
			settings = null;
			
			achievements = null;
			
			currentHudSignal = null;
			
			tweens = null;
			
		}
	}
}