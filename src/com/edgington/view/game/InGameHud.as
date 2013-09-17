package com.edgington.view.game
{
	import com.edgington.constants.CanvasConstants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.GameConstants;
	import com.edgington.model.GameProxy;
	import com.edgington.model.SettingsProxy;
	import com.edgington.model.audio.AudioMainModel;
	import com.edgington.model.events.BonusEvent;
	import com.edgington.types.DeviceTypes;
	import com.edgington.types.GameStateTypes;
	import com.edgington.types.HandDirectionType;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.miniHudPauseMenu;
	import com.edgington.view.huds.elements.element_multiplier;
	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	import org.osflash.signals.Signal;
	
	public class InGameHud extends Sprite
	{
		
		private var hud:ui_inGameHud;
		
		private var multiplier:element_multiplier;
		
		private var pauseMenu:miniHudPauseMenu;
		private var readyToRemoveSignal:Signal;
		
		
		public function InGameHud()
		{
			super();
			
			addListeners();
			
			hud = new ui_inGameHud();
			hud.scaleX = hud.scaleY = DynamicConstants.MESSAGE_SCALE;
			hud.background.width = DynamicConstants.SCREEN_WIDTH * (1/DynamicConstants.MESSAGE_SCALE);
			hud.background.cacheAsBitmap = true;
			hud.txt_score.x = DynamicConstants.SCREEN_WIDTH* (1/DynamicConstants.MESSAGE_SCALE) - 242;
			hud.txt_title.x = DynamicConstants.SCREEN_WIDTH*.5 - hud.txt_title.width*.5;
			hud.txt_trackInfo.text = AudioMainModel.getInstance().currentTrackDetails.trackTitle + "\nby " + AudioMainModel.getInstance().currentTrackDetails.artistName;
			hud.txt_trackInfo.cacheAsBitmap = true;
			hud.txt_score.text = "0";
			hud.txt_title.text = "";
			hud.pauseButton.addEventListener(MouseEvent.MOUSE_UP, pauseGame);
			hud.starPowerMeter.visible = false;
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(hud.starPowerMeter.width, hud.starPowerMeter.height, (Math.PI/180)*90, 0, 00);
			hud.starPowerMeter.graphics.beginGradientFill(GradientType.LINEAR, CanvasConstants[SettingsProxy.getInstance().currentTheme.toUpperCase()+"_MULTIPLIER_STAR_COLOR"], [1, 1], [100, 255], matrix);
			hud.starPowerMeter.graphics.drawRect(0, 0, hud.starPowerMeter.width, hud.starPowerMeter.height);
			hud.starPowerMeter.graphics.endFill();
			hud.starPowerMeter.removeChildAt(0);
			
			if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
				
			}
			else{
				
			}
			
			multiplier = new element_multiplier();
			multiplier.y = DynamicConstants.SCREEN_HEIGHT - multiplier.height - 8;
			if(SettingsProxy.getInstance().handSelection == HandDirectionType.RIGHT_HAND){
				multiplier.x = multiplier.width + 8;
			}
			else{
				multiplier.x = DynamicConstants.SCREEN_WIDTH - multiplier.width - 8;
			}
			this.addChild(multiplier);
			this.addChild(hud);
		}
		
		private function addListeners():void{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			GameProxy.getInstance().chainSignal.add(newChain);
			GameProxy.getInstance().scoreUpdateSignal.add(updateScore);
			GameProxy.INSTANCE.activeStarPowerSignal.add(handleStarPower);
			readyToRemoveSignal = new Signal();
			readyToRemoveSignal.add(removePauseMenu);
		}
		
		private function newChain(bonusType:String, beatsInARow:int, bonusAmount:int):void{
			if(bonusAmount != 0){
				switch(bonusType){
					case BonusEvent.PERFECT_CHAIN:
						hud.txt_title.text = gettext("chain_perfect_bonus", {score:bonusAmount});
						break;
					case BonusEvent.BEAT_CHAIN:
						hud.txt_title.text = gettext("chain_bonus", {score:bonusAmount});
						break;
				}
			}
		}
		
		private function updateScore():void{
			hud.txt_score.text = String(GameProxy.INSTANCE.score);
			multiplier.addNewBeat();
			if(GameProxy.INSTANCE.starPowerActive){
				TweenLite.killTweensOf(hud.starPowerMeter);
				TweenLite.to(hud.starPowerMeter, 0.3, {scaleX:Math.abs(GameProxy.INSTANCE.beatsHitDuringStarPower) / GameConstants.STAR_POWER_MAXIMUM_ALLOWED, ease:Quad.easeOut});
			}
		}
		
		private function handleStarPower():void{
			if(GameProxy.INSTANCE.starPowerActive){
				hud.starPowerMeter.scaleX = 0;
				TweenLite.to(hud.starPowerMeter, 0.3, {scaleX:Math.abs(GameProxy.INSTANCE.beatsHitDuringStarPower) / GameConstants.STAR_POWER_MAXIMUM_ALLOWED, ease:Quad.easeOut});
				hud.starPowerMeter.visible = true;
			}
			else{
				hud.starPowerMeter.visible = false;
			}
		}
		
		private function pauseGame(e:MouseEvent):void{
			hud.pauseButton.removeEventListener(MouseEvent.MOUSE_UP, pauseGame);
			GameProxy.INSTANCE.pauseSignal.dispatch(true);
			pauseMenu = new miniHudPauseMenu(readyToRemoveSignal);
			this.addChild(pauseMenu);
		}
		
		private function removePauseMenu():void{
			this.removeChild(pauseMenu);
			pauseMenu = null;
			if(DynamicConstants.CURRENT_GAME_STATE == GameStateTypes.GAME_MAIN){
				hud.pauseButton.addEventListener(MouseEvent.MOUSE_UP, pauseGame);
				GameProxy.INSTANCE.pauseSignal.dispatch(false);
			}
			else{
				GameProxy.INSTANCE.killGameEarlySignal.dispatch();
			}
		}
		
		private function destroy(e:Event):void{
			GameProxy.getInstance().chainSignal.remove(newChain);
			GameProxy.getInstance().scoreUpdateSignal.remove(updateScore);
			readyToRemoveSignal.removeAll();
			readyToRemoveSignal = null;
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			
			hud = null;
		}
	}
}