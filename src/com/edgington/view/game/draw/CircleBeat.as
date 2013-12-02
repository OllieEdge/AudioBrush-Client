package com.edgington.view.game.draw
{
	import com.edgington.constants.CanvasConstants;
	import com.edgington.constants.Constants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.GameConstants;
	import com.edgington.model.GameProxy;
	import com.edgington.model.SettingsProxy;
	import com.edgington.model.TutorialManager;
	import com.edgington.types.FontFaceType;
	import com.edgington.util.DrawingShapes;
	import com.edgington.util.localisation.getfont;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.game.Canvas;
	import com.greensock.TweenLite;
	
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	
	import org.osflash.signals.Signal;
	
	public class CircleBeat extends Sprite
	{		
		private var circle:Sprite = new Sprite();
		private var constCircle:Sprite = new Sprite();
		
		private var beatSize:int;
		
		private var minimumScale:Number = 1;
		
		private var circleBeatScale:int = 20;
		private var circlePositionOffset:int = -10;
		
		private var scaleReductionSpeed:Number = 0.05;
		
		private var starBeatScale:int = 10;
		private var starOuterBeatScale:int = 20;
		
		private var beatID:int;
		
		private var hasBeat:Boolean = false;
		public var hit:Boolean = false;
		
		private var updateScale:Boolean = true;
		
		private var superlativeText:TextField;
		
		private var frameCount:int = 0;
		
		private var starBeat:Boolean = false;
		private var starPowerFailedSignal:Signal;
		
		private var currentThemeID:String;
		private var isRogue:Boolean;
		
		private var tutorialMessage:ui_tutorial_arrow;
		
		public function CircleBeat(beatID:int, isRogue:Boolean = false)
		{
			super();
			this.beatID = beatID;
			if(isRogue){
				this.isRogue = isRogue;		
				if(GameProxy.INSTANCE.isTutorial && TutorialManager.getInstance().currentTutorialStage == 5){
					tutorialMessage = new ui_tutorial_arrow();
					getfont(tutorialMessage.txt_label, FontFaceType.BOLD);
					tutorialMessage.txt_label.text = gettext("tutorial_gameplay_message_"+TutorialManager.getInstance().currentTutorialStage);
				}
			}
			else{
				if(GameProxy.INSTANCE.isTutorial && TutorialManager.getInstance().currentTutorialStage == 1 || TutorialManager.getInstance().currentTutorialStage == 2){
					tutorialMessage = new ui_tutorial_arrow();
					getfont(tutorialMessage.txt_label, FontFaceType.BOLD);
					tutorialMessage.txt_label.text = gettext("tutorial_gameplay_message_"+TutorialManager.getInstance().currentTutorialStage);
				}
			}
		
			
			if(DynamicConstants.DEVICE_NAME == Constants.IPAD_4PLUS || DynamicConstants.DEVICE_NAME == Constants.ANDROID_XXL || DynamicConstants.DEVICE_NAME == Constants.ANDROID_XXLDPI){
				circleBeatScale = 40;
				circlePositionOffset = -20;
				starBeatScale = 20;
				starOuterBeatScale = 40;
				scaleReductionSpeed = 0.05;
			}
			
			currentThemeID = SettingsProxy.getInstance().currentTheme;	
			
			if(GameProxy.INSTANCE.starPowerBeatsRemainingBeforeActivation >  0 && !isRogue){
				starBeat = true;
				GameProxy.INSTANCE.starPowerBeatsRemainingBeforeActivation--;
			}
			
			
			if(!starBeat){
				if(isRogue){
					circle.graphics.beginFill(CanvasConstants[currentThemeID.toUpperCase()+"_ROGUE_BEAT_COLOR"][0]);
				}
				else{
					if(GameProxy.INSTANCE.starPowerActive){
						circle.graphics.beginFill(CanvasConstants[currentThemeID.toUpperCase()+"_COLOR_STAR_POWER_SECONDARY"][0]);
					}
					else{
						circle.graphics.beginFill(CanvasConstants[currentThemeID.toUpperCase()+"_COLORS"][Canvas.currentColourIndex]);	
					}
				}
				circle.graphics.drawEllipse(circlePositionOffset, circlePositionOffset, circleBeatScale, circleBeatScale);
				circle.graphics.endFill();
				
				if(isRogue){
					constCircle.graphics.beginFill(CanvasConstants[currentThemeID.toUpperCase()+"_ROGUE_BEAT_COLOR"][1]);
				}
				else{
					if(GameProxy.INSTANCE.starPowerActive){
						constCircle.graphics.beginFill(CanvasConstants[currentThemeID.toUpperCase()+"_COLOR_STAR_POWER"][0]);
					}
					else{
						constCircle.graphics.beginFill(CanvasConstants[currentThemeID.toUpperCase()+"_COLORS_SECONDARY"][Canvas.currentColourIndex]);
					}
				}
				constCircle.graphics.drawEllipse(circlePositionOffset, circlePositionOffset, circleBeatScale, circleBeatScale);
				constCircle.graphics.endFill();
			}
			else{
				starPowerFailedSignal = GameProxy.INSTANCE.starPowerFailedSignal;
				starPowerFailedSignal.addOnce(starPowerFailed);
				
				circle.graphics.beginFill(CanvasConstants[currentThemeID.toUpperCase()+"_COLORS"][Canvas.currentColourIndex]);
				DrawingShapes.drawStar(circle.graphics, 0, 0, 5, starBeatScale*.5, starOuterBeatScale*.5);
				circle.graphics.endFill();
				
				constCircle.graphics.beginFill(CanvasConstants[currentThemeID.toUpperCase()+"_COLORS_SECONDARY"][Canvas.currentColourIndex]);
				DrawingShapes.drawStar(constCircle.graphics, 0, 0, 5, starBeatScale, starOuterBeatScale);
				constCircle.graphics.endFill();
			}
			if(DynamicConstants.DEVICE_NAME == Constants.IPAD_4PLUS || DynamicConstants.DEVICE_NAME == Constants.IPHONE_5PLUS){
				circle.blendMode = BlendMode.ADD;
			}
			
			constCircle.cacheAsBitmap = true;
			
			this.addChild(circle);
			this.addChild(constCircle);
			if(tutorialMessage != null){
				tutorialMessage.scaleX = tutorialMessage.scaleY = DynamicConstants.DEVICE_SCALE;
				this.addEventListener(Event.ADDED_TO_STAGE, addTutorialMessage);
			}
		}
		
		private function addTutorialMessage(e:Event):void{
			this.removeEventListener(Event.ADDED_TO_STAGE, addTutorialMessage);
			parent.addChild(tutorialMessage);
		}
		
		public function updateCircle(beatID:int, beatStrength:Number = 0):void{
			if(this.beatID == beatID){
				hasBeat = true;
				if(isRogue){
					circle.scaleX = circle.scaleY = 3;
				}
				else{
					circle.scaleX = circle.scaleY = GameConstants.BEAT_PULSE_SCALE;
				}
			}
		}
		
		public function tick():void{
			if(hasBeat){
				if(circle.scaleX > minimumScale){
					circle.scaleX -= scaleReductionSpeed;
					circle.scaleY -= scaleReductionSpeed;
				}
			}
			else{
				frameCount++;
			}
			if(tutorialMessage){
				tutorialMessage.x = this.x;
				tutorialMessage.y = this.y;
			}
		}
		
		public function hitDetected():void{
			hit = true;
			
			if(!starBeat){
				if(isRogue){
					constCircle.graphics.beginFill(CanvasConstants[currentThemeID.toUpperCase()+"_ROGUE_BEAT_COLOR"][0]);
				}
				else{
					if(GameProxy.INSTANCE.starPowerActive){
						constCircle.graphics.beginFill(CanvasConstants[currentThemeID.toUpperCase()+"_COLOR_STAR_POWER_SECONDARY"][0]);
					}
					else{
						constCircle.graphics.beginFill(CanvasConstants[currentThemeID.toUpperCase()+"_COLORS"][Canvas.currentColourIndex]);
					}
				}
				constCircle.graphics.drawEllipse(circlePositionOffset, circlePositionOffset, circleBeatScale, circleBeatScale);
				constCircle.graphics.endFill();
			}
			else{
				constCircle.graphics.beginFill(CanvasConstants[currentThemeID.toUpperCase()+"_COLORS"][Canvas.currentColourIndex]);
				DrawingShapes.drawStar(constCircle.graphics, 0, 0, 5, starBeatScale, starOuterBeatScale);
				constCircle.graphics.endFill();	
			}
			
			if(hasBeat && circle.scaleX >= GameConstants.GOOD_THRESHOLD){
				GameProxy.INSTANCE.beatCollected(circle.scaleX, starBeat, beatID, isRogue);
			}
			else if(frameCount >= GameConstants.EARLY_OK_THRESHOLD){
				GameProxy.INSTANCE.beatCollected(Math.min(25, frameCount)/5, starBeat, beatID, isRogue);
			}
			else{
				GameProxy.INSTANCE.beatCollected(-1, starBeat, beatID, isRogue);
			}
			
		}
		
		/**
		 * if this is a star power beat anywhere on the screen (so not only this one) and it's not perfect this function will fire
		 */
		private function starPowerFailed():void{
			starBeat = false;
			circle.graphics.clear();
			if(GameProxy.INSTANCE.starPowerActive){
				circle.graphics.beginFill(CanvasConstants[currentThemeID.toUpperCase()+"_COLOR_STAR_POWER_SECONDARY"][0]);
			}
			else{
				circle.graphics.beginFill(CanvasConstants[currentThemeID.toUpperCase()+"_COLORS"][Canvas.currentColourIndex]);
			}
			circle.graphics.drawEllipse(circlePositionOffset, circlePositionOffset, circleBeatScale, circleBeatScale);
			circle.graphics.endFill();
			
			constCircle.graphics.clear();
			if(GameProxy.INSTANCE.starPowerActive){
				constCircle.graphics.beginFill(CanvasConstants[currentThemeID.toUpperCase()+"_COLOR_STAR_POWER"][0]);
			}
			else{
				constCircle.graphics.beginFill(CanvasConstants[currentThemeID.toUpperCase()+"_COLORS_SECONDARY"][Canvas.currentColourIndex]);
			}
			constCircle.graphics.drawEllipse(circlePositionOffset, circlePositionOffset, circleBeatScale, circleBeatScale);
			constCircle.graphics.endFill();
		}
		
		private function removeText():void{
			TweenLite.delayedCall(1, this.removeChild, [superlativeText]);
		}
		
		public function clean():void{
			if(tutorialMessage){
				if(parent.contains(tutorialMessage)){
					parent.removeChild(tutorialMessage);
					tutorialMessage = null;
				}
			}
		}
		
		public function destroy():void{
			if(starBeat){
				starPowerFailedSignal.remove(starPowerFailed);
			}
			if(!hit){
				GameProxy.INSTANCE.beatCollected(-2, starBeat, beatID, isRogue);
			}
			TweenLite.killTweensOf(superlativeText);
			TweenLite.killDelayedCallsTo(this.removeChild);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			circle = null;
			superlativeText = null;
		}
	}
}