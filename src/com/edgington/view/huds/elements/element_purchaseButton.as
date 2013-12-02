package com.edgington.view.huds.elements
{
	import com.adobe.ane.productStore.Product;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.ProductConstants;
	import com.edgington.model.events.ButtonEvent;
	import com.edgington.types.FontFaceType;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.getfont;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.interfaces.IAudioBrushButton;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.globalization.CurrencyFormatter;
	import flash.system.Capabilities;
	import flash.text.TextFieldAutoSize;
	
	import org.osflash.signals.Signal;
	
	public class element_purchaseButton extends Sprite implements IAudioBrushButton
	{
		private const PADDING:int = 20;
		
		private var button:ui_mainPurchaseButton;
		
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
		
		public var purchaseData:Product;
		
		private var purchaseIcon:MovieClip;
		
		public function element_purchaseButton(purchaseData:Product, _buttonOption:String, setWidth:int)
		{
			super();
			this.purchaseData = purchaseData;
			this.buttonOption = _buttonOption;
			
			button = new ui_mainPurchaseButton();
			
			getfont(button.txt_container.txt_title, FontFaceType.BOLD);
			getfont(button.txt_container.txt_description, FontFaceType.REGULAR);
			getfont(button.txt_container.txt_saving, FontFaceType.REGULAR);
			getfont(button.txt_container.txt_price, FontFaceType.BOLD);
			
			this.addChild(button);
			buttonSignal = new Signal();
			
			button.txt_container.txt_title.text = gettext("purchase_menu_"+purchaseData.identifier+"_title");
			button.txt_container.txt_title.autoSize = TextFieldAutoSize.LEFT;
			button.txt_container.txt_description.text = gettext("purchase_menu_"+purchaseData.identifier+"_description");
			button.txt_container.txt_description.autoSize = TextFieldAutoSize.LEFT;
			button.txt_container.txt_saving.text = gettext("purchase_menu_"+purchaseData.identifier+"_saving");
			button.txt_container.txt_saving.autoSize = TextFieldAutoSize.RIGHT;
			
			var local:String = purchaseData.priceLocale.split("@")[0];
			var currencyCode:String = purchaseData.priceLocale.split("=")[1];
			var cf:CurrencyFormatter = new CurrencyFormatter(local);
			cf.formattingWithCurrencySymbolIsSafe(currencyCode);
			
			
			button.txt_container.txt_price.text = cf.format(purchaseData.price, true);
			button.txt_container.txt_price.autoSize = TextFieldAutoSize.RIGHT;
			
			setWidth = (setWidth*(1/DynamicConstants.BUTTON_PURCHASE_SCALE));
			
			this.scaleX = this.scaleY = DynamicConstants.BUTTON_PURCHASE_SCALE;
			button.scaler.width = setWidth-button.scaler.x;
			button.txt_container.txt_price.x = setWidth - button.scaler.x - button.txt_container.txt_price.textWidth - PADDING;
			button.txt_container.txt_saving.x = setWidth - button.scaler.x - button.txt_container.txt_saving.textWidth - PADDING;
			
			switch(purchaseData.identifier){
				case ProductConstants.ADDITIONAL_CREDITS_25:
					purchaseIcon = new ui_purchase_icon_small();
					break;
				case ProductConstants.ADDITIONAL_CREDITS_55:
					purchaseIcon = new ui_purchase_icon_medium();
					break;
				case ProductConstants.ADDITIONAL_CREDITS_310:
					purchaseIcon = new ui_purchase_icon_large();
					break;
			}
			
			purchaseIcon.x = 9;
			purchaseIcon.y = 7;
			button.addChild(purchaseIcon);
				
			_width = this.getBounds(this).width;
			
			textSizeXScale = button.scaler.scaleX;
			overSizeXScale = textSizeXScale + 0.1;
			
			button.txt_container.visible = false;
			button.scaler.scaleX = 0;
			
			button.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			button.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			button.addEventListener(MouseEvent.ROLL_OUT, rollOut);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			
		//	_width = _width*this.scaleX;
			
			scalerTween = TweenLite.to(button.scaler, 0.4, {scaleX:textSizeXScale, ease:Back.easeOut, delay:0.5+(Math.random()*0.5), onComplete:showButton});
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
				rotateTween = TweenLite.to(purchaseIcon, 0.6, {scaleX:2, scaleY:2, alpha:0, ease:Quad.easeIn});
				scalerTween = TweenLite.to(button.scaler, 0.6, {scaleX:0, ease:Back.easeIn, onComplete:cleanButton});
				textTween = TweenLite.to(button.txt_container, 0.2, {alpha:0});
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
			
			LOG.info("Cleaned purchase button: " + button.txt_container.txt_title.text);
			
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
			button.txt_container.alpha = 0;
			button.txt_container.cacheAsBitmap = true;
			button.txt_container.visible = true;
			textTween = TweenLite.to(button.txt_container, 0.3, {alpha:1, ease:Linear.easeIn});
		}
		
		/**
		 * If this button has been pressed
		 */
		private function cleanButton():void{
			cleanTween(rotateTween);
			cleanTween(scalerTween);
			cleanTween(textTween);
			cleanTween(rotaterTween);
			if(button){
				buttonTween = TweenLite.to(button, 0.2, {alpha:0, onComplete:dispatchButtonPress});
			}
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
			destroy(null);
		}
		
		/**
		 * If this button is no longer required we need to animate it off. Option to delay
		 */
		public function removeButton(delay:Number = 0):void{
			scalerTween = TweenLite.to(button.scaler, 0.4, {scaleX:0, ease:Back.easeIn, onComplete:cleanFromExternal, delay:delay});
			textTween = TweenLite.to(button.txt_container, 0.2, {alpha:0, delay:delay});
			rotateTween = TweenLite.to(purchaseIcon, 0.4, {scaleX:2, scaleY:2, alpha:0, ease:Quad.easeIn});
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
