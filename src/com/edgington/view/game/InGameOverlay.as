package com.edgington.view.game
{
	import com.edgington.constants.CanvasConstants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.GameConstants;
	import com.edgington.model.GameProxy;
	import com.edgington.model.SettingsProxy;
	import com.edgington.types.HandDirectionType;
	import com.edgington.util.TextFieldManager;
	import com.edgington.util.localisation.gettext;
	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;
	
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class InGameOverlay extends Sprite
	{
		
		private var normalChainTextfield:TextField;
		private var normalChainActive:Boolean;
		private var normalChainTween:TweenLite;
		
		private var perfectChainDescription:TextField;
		private var perfectChainTextField:TextField;
		private var perfectChainActive:Boolean;
		private var perfectChainTween:TweenLite;
		
		private var onScreenFields:Vector.<TextField>;
		
		private var currentStreakTotal:int = 0;
		private var streakNotifiers:Vector.<int> = new <int>[10, 20, 50, 75, 100, 150, 200, 300, 400, 500, 750, 1000, int.MAX_VALUE];
		
		private var colourTransform:ColorTransform;
		private var currentThemeID:String;
		
		public function InGameOverlay()
		{
			super();
			
			currentThemeID = SettingsProxy.getInstance().currentTheme;
			
			colourTransform = new ColorTransform();
			colourTransform.color = CanvasConstants[currentThemeID.toUpperCase()+"_OVERLAY_TEXT_COLOR"][0];
			
			onScreenFields = new Vector.<TextField>;
			if(Canvas.handDirection == HandDirectionType.LEFT_HAND){
				normalChainTextfield = TextFieldManager.createTextField("", FONT_audiobrush_content_bold, 0x3a3a3a, 20, false, TextFieldAutoSize.RIGHT);
				perfectChainTextField = TextFieldManager.createTextField("", FONT_audiobrush_content_bold, 0x3a3a3a, 60, false, TextFieldAutoSize.RIGHT);
				perfectChainDescription = TextFieldManager.createTextField(gettext("game_perfect_streak_notification"), FONT_audiobrush_content_bold, 0x3a3a3a, 15, true, TextFieldAutoSize.RIGHT);
			}
			else{
				normalChainTextfield = TextFieldManager.createTextField("", FONT_audiobrush_content_bold, 0x3a3a3a, 20, false, TextFieldAutoSize.LEFT);
				perfectChainTextField = TextFieldManager.createTextField("", FONT_audiobrush_content_bold, 0x3a3a3a, 60, false, TextFieldAutoSize.LEFT);
				perfectChainDescription = TextFieldManager.createTextField(gettext("game_perfect_streak_notification"), FONT_audiobrush_content_bold, 0x3a3a3a, 15, true, TextFieldAutoSize.LEFT);
			}
				
			normalChainTextfield.cacheAsBitmap = true;
			perfectChainTextField.cacheAsBitmap = true;
			perfectChainDescription.cacheAsBitmap = true;
			
			
			this.transform.colorTransform = colourTransform;
			
			addListeners();
		}
		
		private function addListeners():void{
			GameProxy.INSTANCE.beatCollectSignal.add(beatCollected);
			GameProxy.INSTANCE.activeStarPowerSignal.add(changeColor);
		}
		
		private function changeColor():void{
			if(GameProxy.INSTANCE.starPowerActive){
				colourTransform = new ColorTransform();
				colourTransform.color = CanvasConstants[currentThemeID.toUpperCase()+"_OVERLAY_TEXT_COLOR"][1];
			}
			else{
				colourTransform = new ColorTransform();
				colourTransform.color = CanvasConstants[currentThemeID.toUpperCase()+"_OVERLAY_TEXT_COLOR"][0];
			}
			this.transform.colorTransform = colourTransform;
		}
		
		private function beatCollected(beatScale:Number):void{
			if(GameProxy.INSTANCE.currentNormalHitStreak > streakNotifiers[currentStreakTotal]){
				displayNote(gettext("game_streak_notification", {number:streakNotifiers[currentStreakTotal]}));
				currentStreakTotal++;
			}
			else if(beatScale < GameConstants.GOOD_THRESHOLD){
				currentStreakTotal = 0;
				removeField(normalChainTextfield);
			}
			
			if(GameProxy.INSTANCE.currentPerfectHitStreak > 1 && !perfectChainActive){
				perfectChainActive = true;
				perfectChainTextField.text = String(GameProxy.INSTANCE.currentPerfectHitStreak);
				perfectChainTextField.y = DynamicConstants.SCREEN_HEIGHT*.5 - perfectChainTextField.height - DynamicConstants.BUTTON_SPACING*.5;
				perfectChainDescription.y = perfectChainTextField.y - perfectChainDescription.height;
				if(Canvas.handDirection == HandDirectionType.LEFT_HAND){
					perfectChainDescription.x = -DynamicConstants.SCREEN_MARGIN*3;
				}
				else{
					perfectChainDescription.x = DynamicConstants.SCREEN_MARGIN;
				}
				addField(perfectChainTextField);
			}
			else if(beatScale >= 4.9){
				perfectChainTextField.text = String(GameProxy.INSTANCE.currentPerfectHitStreak);
			}
			else if(perfectChainActive){
				perfectChainActive = false;
				removeField(perfectChainTextField);
			}
		}
		
		private function addField(field:TextField):void{
			switch(field){
				case normalChainTextfield:
					cleanTween(normalChainTween);
					if(Canvas.handDirection == HandDirectionType.LEFT_HAND){
						normalChainTextfield.x = 0;
						normalChainTween = TweenLite.to(normalChainTextfield, 0.5, {x:-DynamicConstants.SCREEN_MARGIN*2, ease:Quad.easeOut});
					}
					else{
						normalChainTextfield.x = -normalChainTextfield.textWidth;
						normalChainTween = TweenLite.to(normalChainTextfield, 0.5, {x:DynamicConstants.SCREEN_MARGIN, ease:Quad.easeOut});
					}
					this.addChild(normalChainTextfield);
					break;
				case perfectChainTextField:
					cleanTween(perfectChainTween);
					if(Canvas.handDirection == HandDirectionType.LEFT_HAND){
						perfectChainTextField.x = 0;
						perfectChainTween = TweenLite.to(perfectChainTextField, 0.5, {x:-DynamicConstants.SCREEN_MARGIN*2, ease:Quad.easeOut});
					}
					else{
						perfectChainTextField.x = -perfectChainTextField.textWidth;
						perfectChainTween = TweenLite.to(perfectChainTextField, 0.5, {x:DynamicConstants.SCREEN_MARGIN, ease:Quad.easeOut});
					}
					this.addChild(perfectChainTextField);
					this.addChild(perfectChainDescription);
			}
		}
		
		private function displayNote(str:String):void{
			normalChainTextfield.text = str;
			normalChainTextfield.y = DynamicConstants.SCREEN_HEIGHT*.5 + normalChainTextfield.height + DynamicConstants.BUTTON_SPACING*.5;
			TweenLite.killDelayedCallsTo(removeField);
			cleanTween(normalChainTween);
			if(Canvas.handDirection == HandDirectionType.LEFT_HAND){
				normalChainTextfield.x = 0;
				normalChainTween = TweenLite.to(normalChainTextfield, 0.5, {x:-DynamicConstants.SCREEN_MARGIN*2, ease:Quad.easeOut, onComplete:removeMessage});
			}
			else{
				normalChainTextfield.x = -normalChainTextfield.textWidth;
				normalChainTween = TweenLite.to(normalChainTextfield, 0.5, {x:DynamicConstants.SCREEN_MARGIN, ease:Quad.easeOut, onComplete:removeMessage});
			}
			this.addChild(normalChainTextfield);
		}
		
		private function removeMessage():void{
			TweenLite.delayedCall(3, removeField, [normalChainTextfield]);
		}
		
		private function removeField(field:TextField):void{
			switch(field){
				case normalChainTextfield:
					cleanTween(normalChainTween);
					if(normalChainTextfield.parent != null){
						this.removeChild(normalChainTextfield);
					}
					break;
				case perfectChainTextField:
					cleanTween(perfectChainTween);
					this.removeChild(perfectChainTextField);
					this.removeChild(perfectChainDescription);
					break;
			}
		}
		
		private function cleanTween(tween:TweenLite):void{
			if(tween != null){
				tween.complete(false, true);
				tween.kill();
				tween = null;
			}
		}
	}
}