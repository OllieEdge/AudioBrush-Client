package com.edgington.view.huds.elements
{
	
	import com.edgington.constants.CanvasConstants;
	import com.edgington.constants.GameConstants;
	import com.edgington.model.GameProxy;
	import com.edgington.model.SettingsProxy;
	import com.edgington.types.HandDirectionType;
	import com.edgington.util.TextFieldManager;
	import com.edgington.view.game.Canvas;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	
	public class element_multiplier extends Sprite
	{
		
		private var hud:ui_multiplier;
		private var currentMultiplier:int = 1;
		
		private var currentMutliplierStage:Number;
		
		private var gameProxy:GameProxy;
		
		private var multiText:TextField;
		
		private var textHolder:Sprite;
		
		private var currentColorTransform:ColorTransform;
		private var textCurrentColorTransform:ColorTransform;
		
		public function element_multiplier()
		{
			super();
			
			gameProxy = GameProxy.getInstance();
			
			hud = new ui_multiplier();
			currentColorTransform = hud.colour.transform.colorTransform;
			hud.gotoAndStop(1);
			
			textHolder = new Sprite();
			multiText = TextFieldManager.createCentrallyAllignedTextField("x1", FONT_audiobrush_content_bold, CanvasConstants[SettingsProxy.getInstance().currentTheme.toUpperCase()+"_OVERLAY_TEXT_COLOR"][0], 35);
			multiText.x = 55;
			multiText.y = 55;
			
			
			if(SettingsProxy.getInstance().handSelection == HandDirectionType.RIGHT_HAND){
				hud.scaleX = -hud.scaleX;
				multiText.x = -95;
			}
			textHolder.cacheAsBitmap = true;
			textHolder.addChild(multiText);
			
			this.addChild(hud);
			this.addChild(textHolder);
			
			this.cacheAsBitmap = true;
			
			gameProxy.multiplierSignal.add(addNewBeat);
			gameProxy.colourChange.add(changeColour);
			gameProxy.activeStarPowerSignal.add(changeColour);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		public function addNewBeat():void{
			currentMultiplier = gameProxy.multiplier;
			if(gameProxy.starPowerActive){
				if(currentMultiplier == GameConstants.MAXIMUM_MULTIPLIER*2){
					currentMutliplierStage = 1;
				}
				else{
					currentMutliplierStage = (gameProxy.currentNormalHitStreak - (((currentMultiplier/2)-1)*GameConstants.BEATS_PER_MULTIPLIER)) / (((currentMultiplier/2)*GameConstants.BEATS_PER_MULTIPLIER)-(((currentMultiplier/2)-1)*GameConstants.BEATS_PER_MULTIPLIER));
				}
			}
			else{
				if(currentMultiplier == GameConstants.MAXIMUM_MULTIPLIER){
					currentMutliplierStage = 1;
				}
				else{
					currentMutliplierStage = (gameProxy.currentNormalHitStreak - ((currentMultiplier-1)*GameConstants.BEATS_PER_MULTIPLIER)) / ((currentMultiplier*GameConstants.BEATS_PER_MULTIPLIER)-((currentMultiplier-1)*GameConstants.BEATS_PER_MULTIPLIER));
				}
			}
			if(currentMutliplierStage <= 1){
				hud.gotoAndStop(Math.round(currentMutliplierStage*hud.totalFrames));
				hud.colour.transform.colorTransform = currentColorTransform;
			}
			multiText.text = "x"+currentMultiplier;
		}
		
		private function changeColour():void{
			currentColorTransform = new ColorTransform();
			if(gameProxy.starPowerActive){
				currentColorTransform.color = CanvasConstants[SettingsProxy.getInstance().currentTheme.toUpperCase()+"_MULTIPLIER_STAR_COLOR"][0];
			}
			else{
				currentColorTransform.color = CanvasConstants[SettingsProxy.getInstance().currentTheme.toUpperCase()+"_COLORS_SECONDARY"][Canvas.nextColour];
			}
			hud.colour.transform.colorTransform = currentColorTransform;
			
			textCurrentColorTransform = new ColorTransform();
			if(gameProxy.starPowerActive){
				textCurrentColorTransform.color = CanvasConstants[SettingsProxy.getInstance().currentTheme.toUpperCase()+"_OVERLAY_TEXT_COLOR"][1];
			}
			else{
				textCurrentColorTransform.color = CanvasConstants[SettingsProxy.getInstance().currentTheme.toUpperCase()+"_OVERLAY_TEXT_COLOR"][0];
			}
			textHolder.transform.colorTransform = textCurrentColorTransform;
		}
		
		
		private function destroy(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			gameProxy.colourChange.remove(changeColour);
			gameProxy.multiplierSignal.remove(addNewBeat);
			gameProxy = null;
		}
	}
}