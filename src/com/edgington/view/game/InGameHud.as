package com.edgington.view.game
{
	import com.edgington.constants.CanvasConstants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.GameConstants;
	import com.edgington.media.MediaManager;
	import com.edgington.model.GameProxy;
	import com.edgington.model.SettingsProxy;
	import com.edgington.model.audio.AudioMainModel;
	import com.edgington.model.events.BonusEvent;
	import com.edgington.types.DeviceTypes;
	import com.edgington.types.GameStateTypes;
	import com.edgington.types.HandDirectionType;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.miniHudPauseMenu;
	import com.edgington.view.huds.elements.element_inGameStarRating;
	import com.edgington.view.huds.elements.element_multiplier;
	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.utils.Timer;
	
	import org.osflash.signals.Signal;
	
	public class InGameHud extends Sprite
	{
		
		private var hud:ui_inGameHud;
		private var hudBackground:ui_hud_background;
		
		private var multiplier:element_multiplier;
		
		private var liveStarRating:element_inGameStarRating;
		
		private var pauseMenu:miniHudPauseMenu;
		private var readyToRemoveSignal:Signal;
		
		private var trackProgressTimer:Timer;
		
		
		public function InGameHud()
		{
			super();
			
			trackProgressTimer = new Timer(1000);
			addListeners();
			
			hud = new ui_inGameHud();
			hud.scaleX = hud.scaleY = DynamicConstants.MESSAGE_SCALE;
			hud.txt_score.x = DynamicConstants.SCREEN_WIDTH* (1/DynamicConstants.MESSAGE_SCALE) - 242;
			hud.txt_trackInfo.text = AudioMainModel.getInstance().currentTrackDetails.trackTitle + "\nby " + AudioMainModel.getInstance().currentTrackDetails.artistName;
			hud.txt_trackInfo.cacheAsBitmap = true;
			hud.txt_score.text = "0";
			hud.pauseButton.addEventListener(MouseEvent.MOUSE_UP, pauseGame);
			
			hudBackground = new ui_hud_background();
			hudBackground.scaleY = DynamicConstants.MESSAGE_SCALE;
			hudBackground.width = DynamicConstants.SCREEN_WIDTH;
			hudBackground.background.cacheAsBitmap = true;
			hudBackground.starPowerMeter.visible = false;
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(hudBackground.starPowerMeter.width, hudBackground.starPowerMeter.height, (Math.PI/180)*90, 0, 00);
			hudBackground.starPowerMeter.graphics.beginGradientFill(GradientType.LINEAR, CanvasConstants[SettingsProxy.getInstance().currentTheme.toUpperCase()+"_MULTIPLIER_STAR_COLOR"], [1, 1], [100, 255], matrix);
			hudBackground.starPowerMeter.graphics.drawRect(0, 0, hudBackground.starPowerMeter.width, hudBackground.starPowerMeter.height);
			hudBackground.starPowerMeter.graphics.endFill();
			hudBackground.starPowerMeter.removeChildAt(0);
			
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
				
			}
			else{
				
			}
			
			multiplier = new element_multiplier();
			multiplier.scaleX = multiplier.scaleY = DynamicConstants.DEVICE_SCALE;
			multiplier.y = DynamicConstants.SCREEN_HEIGHT - multiplier.height - 8;
			if(SettingsProxy.getInstance().handSelection == HandDirectionType.RIGHT_HAND){
				multiplier.x = multiplier.width + 8;
			}
			else{
				multiplier.x = DynamicConstants.SCREEN_WIDTH - multiplier.width - 8;
			}
			
			liveStarRating = new element_inGameStarRating();
			liveStarRating.x = hudBackground.width*.5 - liveStarRating.width*.5;
			liveStarRating.y = hudBackground.height*.5 - liveStarRating.height*.5;
			
			trackProgressTimer.start();
			
			this.addChild(hudBackground);
			this.addChild(multiplier);
			this.addChild(hud);
			this.addChild(liveStarRating);
		}
		
		private function updateProgressBar(e:TimerEvent):void{
			if(DynamicConstants.isIOSPlatform()){
				hud.ui_progressbar.bar.scaleX = (AudioMainModel.getInstance().soundChannel.position /  MediaManager.INSTANCE.sound.length);
			}
			else{
				hud.ui_progressbar.bar.scaleX = (AudioMainModel.getInstance().soundChannel.position / AudioMainModel.getInstance().soundObject.length);	
			}
		}
		
		private function addListeners():void{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			trackProgressTimer.addEventListener(TimerEvent.TIMER, updateProgressBar);
			GameProxy.getInstance().scoreUpdateSignal.add(updateScore);
			GameProxy.INSTANCE.activeStarPowerSignal.add(handleStarPower);
			GameProxy.INSTANCE.pauseSignal.add(handlePause);
			readyToRemoveSignal = new Signal();
			readyToRemoveSignal.add(removePauseMenu);
		}
		
		private function updateScore():void{
			hud.txt_score.text = String(GameProxy.INSTANCE.score);
			multiplier.addNewBeat();
			if(GameProxy.INSTANCE.starPowerActive){
				TweenLite.killTweensOf(hudBackground.starPowerMeter);
				TweenLite.to(hudBackground.starPowerMeter, 0.3, {scaleX:Math.abs(GameProxy.INSTANCE.beatsHitDuringStarPower) / GameConstants.STAR_POWER_MAXIMUM_ALLOWED, ease:Quad.easeOut});
			}
		}
		
		private function handleStarPower():void{
			if(GameProxy.INSTANCE.starPowerActive){
				hudBackground.starPowerMeter.scaleX = 0;
				TweenLite.to(hudBackground.starPowerMeter, 0.3, {scaleX:Math.abs(GameProxy.INSTANCE.beatsHitDuringStarPower) / GameConstants.STAR_POWER_MAXIMUM_ALLOWED, ease:Quad.easeOut});
				hudBackground.starPowerMeter.visible = true;
			}
			else{
				hudBackground.starPowerMeter.visible = false;
			}
		}
		
		private function pauseGame(e:MouseEvent):void{
			GameProxy.INSTANCE.pauseSignal.dispatch(true);
		}
		
		private function handlePause(isPaused:Boolean):void{
			if(isPaused && pauseMenu == null){
				hud.pauseButton.removeEventListener(MouseEvent.MOUSE_UP, pauseGame);
				pauseMenu = new miniHudPauseMenu(readyToRemoveSignal);
				this.addChild(pauseMenu);
			}
			else if(pauseMenu != null){
				this.removeChild(pauseMenu);
				pauseMenu = null;
			}
		}
		
		private function removePauseMenu():void{
			if(DynamicConstants.CURRENT_GAME_STATE == GameStateTypes.GAME_MAIN){
				GameProxy.INSTANCE.pauseSignal.dispatch(false);
				hud.pauseButton.addEventListener(MouseEvent.MOUSE_UP, pauseGame);
			}
			else{
				GameProxy.INSTANCE.killGameEarlySignal.dispatch();
			}
		}
		
		private function destroy(e:Event):void{
			trackProgressTimer.removeEventListener(TimerEvent.TIMER, updateProgressBar);
			trackProgressTimer = null;
			GameProxy.INSTANCE.activeStarPowerSignal.remove(handleStarPower);
			GameProxy.getInstance().scoreUpdateSignal.remove(updateScore);
			readyToRemoveSignal.removeAll();
			readyToRemoveSignal = null;
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			
			hud = null;
			hudBackground = null;
			multiplier = null;
			liveStarRating = null;
		}
	}
}