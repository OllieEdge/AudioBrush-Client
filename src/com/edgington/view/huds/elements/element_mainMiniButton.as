package com.edgington.view.huds.elements
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.events.ButtonEvent;
	import com.edgington.view.huds.interfaces.IAudioBrushButton;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	
	import org.osflash.signals.Signal;
	
	public class element_mainMiniButton extends Sprite implements IAudioBrushButton
	{
		private const PADDING:int = 20;
		
		private var button:ui_miniMainButton;
		
		private var _enabled:Boolean = true;
		
		private var _width:Number;
		
		private var textSizeXScale:Number; // the scale of the text compared to original format size
		private var overSizeXScale:Number;
		
		private var scalerTween:TweenLite;
		private var textTween:TweenLite;
		private var buttonTween:TweenLite;
		private var rotateTween:TweenLite;
		private var rotaterTween:TweenMax;
		
		private var canTween:Boolean = true;
		
		private var _buttonIsClean:Boolean = false;
		private var _buttonSignal:Signal;
		
		private var buttonOption:String;
		
		public function element_mainMiniButton(_str:String, _buttonOption:String)
		{
			super();
			
			this.buttonOption = _buttonOption;
			
			button = new ui_miniMainButton();
			
			this.addChild(button);
			buttonSignal = new Signal();
			
			button.txt_label.text = _str;
			button.txt_label.autoSize = TextFieldAutoSize.LEFT;
			button.scaler.width = button.txt_label.textWidth + PADDING;
			_width = this.getBounds(this).width;
			textSizeXScale = button.scaler.scaleX;
			overSizeXScale = textSizeXScale + 0.1;
			
			button.txt_label.visible = false;
			button.scaler.scaleX = 0;
			
			button.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			button.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			button.addEventListener(MouseEvent.ROLL_OUT, rollOut);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			
			this.scaleX = this.scaleY = DynamicConstants.BUTTON_MINI_SCALE;
			_width = _width*this.scaleX;
			
			scalerTween = TweenLite.to(button.scaler, 0.4, {scaleX:textSizeXScale, ease:Back.easeOut, delay:0.5+(Math.random()*0.5), onComplete:showButton});
			rotaterTween = TweenMax.to(button.rotater, 3*textSizeXScale, {startAt:{frame:1}, frame:120, ease:Linear.easeNone, repeat:-1});
		}

		public function set buttonIsClean(value:Boolean):void
		{
			_buttonIsClean = value;
		}

		private function mouseDown(e:MouseEvent):void{
			if(canTween){
				cleanTween(scalerTween);
				scalerTween = TweenLite.to(button.scaler, 0.4, {scaleX:overSizeXScale, ease:Back.easeOut});
			}
		}
		
		private function mouseUp(e:MouseEvent):void{
			if(canTween){
				canTween = false;
				cleanTween(scalerTween);
				cleanTween(textTween);
				rotateTween = TweenLite.to(button.rotater.getChildAt(0), 0.6, {scaleX:2, scaleY:2, alpha:0, ease:Quad.easeIn});
				scalerTween = TweenLite.to(button.scaler, 0.6, {scaleX:0, ease:Back.easeIn, onComplete:cleanButton});
				textTween = TweenLite.to(button.txt_label, 0.2, {alpha:0});
				buttonSignal.dispatch(ButtonEvent.BUTTON_PRESSED, buttonOption);
			}
		}
		
		private function rollOut(e:MouseEvent):void{
			if(canTween){
				cleanTween(scalerTween);
				scalerTween = TweenLite.to(button.scaler, 0.4, {scaleX:textSizeXScale, ease:Back.easeOut});
			}
		}
		
		public function get enabled():Boolean{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void{
			_enabled = value;
		}
		
		private function destroy(e:Event):void{
			button.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			button.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			button.removeEventListener(MouseEvent.ROLL_OUT, rollOut);
			
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			
			cleanTween(textTween);
			cleanTween(scalerTween);
			cleanTween(rotateTween);
			cleanTween(buttonTween);
			cleanTween(rotaterTween);
			
			while(button.numChildren > 0){
				button.removeChildAt(0);
			}
			
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			this.button = null;
		}
		
		private function cleanTween(tween:TweenLite):void{
			if(tween != null){
				tween.complete();
				tween.kill();
				tween = null;
			}
		}
		
		private function showButton():void{
			button.txt_label.alpha = 0;
			button.txt_label.cacheAsBitmap = true;
			button.txt_label.visible = true;
			textTween = TweenLite.to(button.txt_label, 0.3, {alpha:1, ease:Linear.easeIn});
		}
		
		/**
		 * If this button has been pressed
		 */
		private function cleanButton():void{
			cleanTween(rotateTween);
			cleanTween(scalerTween);
			cleanTween(textTween);
			cleanTween(rotaterTween);
			buttonTween = TweenLite.to(button, 0.2, {alpha:0, onComplete:dispatchButtonPress});
			//button.ro
		}
		
		/**
		 * If the clean request is due to a external removal
		 */
		private function cleanFromExternal():void{
			cleanTween(rotateTween);
			cleanTween(scalerTween);
			cleanTween(textTween);
			cleanTween(rotaterTween);
			buttonTween = TweenLite.to(button, 0.1, {alpha:0, onComplete:reportClean});
		}
		
		private function reportClean():void{
			cleanTween(buttonTween);
			buttonIsClean = true;
			buttonSignal.dispatch(ButtonEvent.BUTTON_CLEAN);
		}
		
		/**
		 * If this button is no longer required we need to animate it off. Option to delay
		 */
		public function removeButton(delay:Number = 0):void{
			scalerTween = TweenLite.to(button.scaler, 0.4, {scaleX:0, ease:Back.easeIn, onComplete:cleanFromExternal, delay:delay});
			textTween = TweenLite.to(button.txt_label, 0.2, {alpha:0, delay:delay});
			rotateTween = TweenLite.to(button.rotater.getChildAt(0), 0.4, {scaleX:2, scaleY:2, alpha:0, ease:Quad.easeIn});
		}
		
		private function dispatchButtonPress():void{
			cleanTween(buttonTween);
			buttonIsClean = true;
			buttonSignal.dispatch(ButtonEvent.BUTTON_CLEAN);
		}
		
		public function get buttonSignal():Signal
		{
			return _buttonSignal;
		}
		
		public function set buttonSignal(value:Signal):void
		{
			_buttonSignal = value;
		}
		
		public function get buttonIsClean():Boolean
		{
			return _buttonIsClean;
		}
		
		override public function get width():Number{
			return _width;
		}
	}
}

