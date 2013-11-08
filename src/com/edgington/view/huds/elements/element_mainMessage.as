package com.edgington.view.huds.elements
{
	import com.edgington.constants.DynamicConstants;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Linear;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFormat;
	
	public class element_mainMessage extends Sprite
	{
		
		private var message:ui_mainMessage;
		
		private var scalerScaleX:Number = 0;
		
		private var showRotater:Boolean = false
		
		private var scalerTween:TweenLite;
		private var textTween:TweenMax;
		private var rotaterTween:TweenMax;
		
		private var customLogo:MovieClip;
		
		private var _width:Number;
		
		public function element_mainMessage(_str:String, _showRotater:Boolean = false, customLogo:MovieClip = null)
		{
			super();
			
			this.customLogo = customLogo;
			showRotater = _showRotater;
			message = new ui_mainMessage();
			if(customLogo){
				customLogo.cacheAsBitmap = true;
				customLogo.width = message.background.imgBackground.width;
				customLogo.height = message.background.imgBackground.height;
				message.background.imgBackground.addChild(customLogo);
			}
			this.addChild(message);
			
			
//			message.txt_label.text = _str;
//			
//			message.txt_label.x += Math.round((message.txt_label.width - message.txt_label.textWidth) *.5);
//			message.txt_label.y += Math.round((message.txt_label.height - message.txt_label.textHeight) *.5);
			
			message.txt_label.visible = false;
			scalerScaleX = message.background.scaler.scaleX;
			_width = 641;
			message.background.scaler.scaleX = 0;
			
			this.scaleX = this.scaleY = DynamicConstants.MESSAGE_SCALE;
			_width = _width*this.scaleX;
			
			executeMessageChange(_str);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		private function animateIn():void{
			scalerTween = TweenLite.to(message.background.scaler, 0.4, {scaleX:scalerScaleX, ease:Back.easeOut, delay:0.5+(Math.random()*0.5), onComplete:showMessage});
			cleanTween(rotaterTween);
			if(showRotater){
				message.background.rotater.visible = true;
				rotaterTween = TweenMax.to(message.background.rotater, 2, {startAt:{frame:1}, frame:120, ease:Linear.easeNone, repeat:-1});
			}
			else{
				cleanTween(rotaterTween);
				message.background.rotater.visible = false;
			}
		}
		
		private function showMessage():void{
			message.txt_label.alpha = 0;
			message.txt_label.cacheAsBitmap = true;
			message.txt_label.visible = true;
			textTween = TweenMax.to(message.txt_label, 0.3, {alpha:1, ease:Linear.easeIn});
		}
		
		public function changeMessage(_str:String, _showRotater:Boolean = false, _customLogo:MovieClip = null):void{
			showRotater = _showRotater;
			cleanTween(scalerTween);
			cleanTween(textTween);
			scalerTween = TweenLite.to(message.background.scaler, 0.6, {scaleX:0, ease:Back.easeIn, onComplete:executeMessageChange, onCompleteParams:[_str]});
			textTween = TweenMax.to(message.txt_label, 0.2, {alpha:0, ease:Linear.easeIn});
			
			if(customLogo){
				message.background.imgBackground.removeChild(customLogo);
				customLogo = null;
			}
			
			if(_customLogo){
				customLogo = _customLogo;
				customLogo.cacheAsBitmap = true;
				customLogo.width = message.background.imgBackground.width;
				customLogo.height = message.background.imgBackground.height;
				message.background.imgBackground.addChild(customLogo);
			}
		}
		
		private function executeMessageChange(_str:String):void{
			message.txt_label.height = 118;
			message.txt_label.width = 500;
			message.txt_label.x = 134;
			message.txt_label.y = 0;
				
			message.txt_label.text = _str;
			var textFormat:TextFormat = message.txt_label.getTextFormat();
			textFormat.size = 30;
			message.txt_label.setTextFormat(textFormat);
			while(message.txt_label.textHeight > 112){
				textFormat = message.txt_label.getTextFormat();;
				textFormat.size = int(textFormat.size) -1;
				message.txt_label.setTextFormat(textFormat);
			}
			
			if(message.txt_label.numLines == 1){
				message.txt_label.x += Math.round((message.txt_label.width - message.txt_label.textWidth) *.5);
			}
			message.txt_label.y += Math.round((message.txt_label.height - message.txt_label.textHeight) *.5);
			animateIn();
		}
		
		private function cleanTween(tween:TweenLite):void{
			if(tween != null){
				tween.kill();
				tween = null;
			}
		}
		
		private function destroy(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			
			cleanTween(textTween);
			cleanTween(scalerTween);
			cleanTween(rotaterTween);
			
			while(message.numChildren > 0){
				message.removeChildAt(0);
			}
			
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			this.message = null;
		}
		
		override public function get width():Number{
			return _width;
		}
	}
}