package com.edgington.view.huds.elements
{
	import com.edgington.constants.CanvasConstants;
	import com.edgington.constants.Constants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.GameProxy;
	import com.edgington.model.SettingsProxy;
	import com.edgington.view.game.Canvas;
	
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
	public class element_inGameStarRating extends Sprite
	{
		
		private var stars:ui_star_accumilator;
		
		private var currentColorTransform:ColorTransform;
		
		private var gameProxy:GameProxy;
		
		private var currentStar:int = 1;
		
		//When moving onto a new star we want to make sure it doesn't use score ratio from the previous star.
		//This variable will store the score amount to deduct to make the ratio correct.
		private var previousStarScoreAmount:int;
		
		public function element_inGameStarRating()
		{
			super();
			
			gameProxy = GameProxy.getInstance();
			
			addListeners();
			
			setupVisuals();
		}
		
		private function addListeners():void{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			gameProxy.scoreUpdateSignal.add(checkScore);
			gameProxy.colourChange.add(changeColour);
			gameProxy.activeStarPowerSignal.add(changeColour);
		}
		
		private function setupVisuals():void{
			stars = new ui_star_accumilator();
			//36 because the in game hud height is 44 and muliplied by the message scale. this leaves margins eitehr side of the stars;
			stars.height = 36*DynamicConstants.MESSAGE_SCALE;
			stars.scaleX = stars.scaleY;
			stars.star_1_mask.scaleX = 0;
			stars.star_2_mask.scaleX = 0;
			stars.star_3_mask.scaleX = 0;
			stars.star_4_mask.scaleX = 0;
			stars.star_5_mask.scaleX = 0;
			
			this.addChild(stars);
		}
		
		private function checkScore():void{
			if(gameProxy.score < gameProxy.scoreCalculations.star_1){
				stars.star_1_mask.scaleX = gameProxy.score / gameProxy.scoreCalculations.star_1;
			}
			else if(gameProxy.score < gameProxy.scoreCalculations.star_2){
				if(currentStar == 1){
					currentStar++;
					if(DynamicConstants.DEVICE_NAME == Constants.IPAD_4PLUS || DynamicConstants.DEVICE_NAME == Constants.IPHONE_5PLUS){
						stars.star1.blendMode = BlendMode.ADD;	
					}
					stars.star_1_mask.scaleX = 1;
					previousStarScoreAmount = gameProxy.scoreCalculations.star_1;
				}
				stars.star_2_mask.scaleX = (gameProxy.score-previousStarScoreAmount) / (gameProxy.scoreCalculations.star_2-previousStarScoreAmount);
			}
			else if(gameProxy.score < gameProxy.scoreCalculations.star_3){
				if(currentStar == 2){
					currentStar++;
					if(DynamicConstants.DEVICE_NAME == Constants.IPAD_4PLUS || DynamicConstants.DEVICE_NAME == Constants.IPHONE_5PLUS){
						stars.star2.blendMode = BlendMode.ADD;
					}
					stars.star_1_mask.scaleX = 1;
					stars.star_2_mask.scaleX = 1;
					previousStarScoreAmount = gameProxy.scoreCalculations.star_2;
				}
				stars.star_3_mask.scaleX = (gameProxy.score-previousStarScoreAmount) / (gameProxy.scoreCalculations.star_3-previousStarScoreAmount);
			}
			else if(gameProxy.score < gameProxy.scoreCalculations.star_4){
				if(currentStar == 3){
					currentStar++;
					if(DynamicConstants.DEVICE_NAME == Constants.IPAD_4PLUS || DynamicConstants.DEVICE_NAME == Constants.IPHONE_5PLUS){
						stars.star3.blendMode = BlendMode.ADD;
					}
					stars.star_1_mask.scaleX = 1;
					stars.star_2_mask.scaleX = 1;
					stars.star_3_mask.scaleX = 1;
					previousStarScoreAmount = gameProxy.scoreCalculations.star_3;
				}
				stars.star_4_mask.scaleX = (gameProxy.score-previousStarScoreAmount) / (gameProxy.scoreCalculations.star_4-previousStarScoreAmount);
			}
			else if(gameProxy.score < gameProxy.scoreCalculations.star_5){
				if(currentStar == 4){
					currentStar++;
					if(DynamicConstants.DEVICE_NAME == Constants.IPAD_4PLUS || DynamicConstants.DEVICE_NAME == Constants.IPHONE_5PLUS){
						stars.star4.blendMode = BlendMode.ADD;
					}
					stars.star_1_mask.scaleX = 1;
					stars.star_2_mask.scaleX = 1;
					stars.star_3_mask.scaleX = 1;
					stars.star_4_mask.scaleX = 1;
					previousStarScoreAmount = gameProxy.scoreCalculations.star_4;
				}
				stars.star_5_mask.scaleX = (gameProxy.score-previousStarScoreAmount) / (gameProxy.scoreCalculations.star_5-previousStarScoreAmount);
			}
			else{
				if(currentStar == 5){
					if(DynamicConstants.DEVICE_NAME == Constants.IPAD_4PLUS || DynamicConstants.DEVICE_NAME == Constants.IPHONE_5PLUS){
						stars.star5.blendMode = BlendMode.ADD;
					}
					currentStar++;
					stars.star_1_mask.scaleX = 1;
					stars.star_2_mask.scaleX = 1;
					stars.star_3_mask.scaleX = 1;
					stars.star_4_mask.scaleX = 1;
					stars.star_5_mask.scaleX = 1;
				}
			}
		}
		
		private function changeColour():void{
			currentColorTransform = new ColorTransform();
			if(gameProxy.starPowerActive){
				if(DynamicConstants.DEVICE_NAME == Constants.IPAD_4PLUS || DynamicConstants.DEVICE_NAME == Constants.IPHONE_5PLUS){
					stars.blendMode = BlendMode.ADD;
				}
				currentColorTransform.color = CanvasConstants[SettingsProxy.getInstance().currentTheme.toUpperCase()+"_MULTIPLIER_STAR_COLOR"][0];
			}
			else{
				stars.blendMode = BlendMode.NORMAL;
				currentColorTransform.color = CanvasConstants[SettingsProxy.getInstance().currentTheme.toUpperCase()+"_COLORS_SECONDARY"][Canvas.nextColour];
			}
			stars.star1.transform.colorTransform = currentColorTransform;
			stars.star2.transform.colorTransform = currentColorTransform;
			stars.star3.transform.colorTransform = currentColorTransform;
			stars.star4.transform.colorTransform = currentColorTransform;
			stars.star5.transform.colorTransform = currentColorTransform;
		}
		
		private function destroy(e:Event):void{
			gameProxy.colourChange.remove(changeColour);
			gameProxy.activeStarPowerSignal.remove(changeColour);
			gameProxy.scoreUpdateSignal.remove(checkScore);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			
			stars = null;
			gameProxy = null;
			currentColorTransform = null;
		}
	}
}