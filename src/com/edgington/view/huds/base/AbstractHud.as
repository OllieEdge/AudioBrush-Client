package com.edgington.view.huds.base
{
	import com.edgington.model.events.ButtonEvent;
	import com.edgington.util.debug.LOG;
	import com.edgington.view.huds.interfaces.IAudioBrushButton;
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	import com.greensock.events.TweenEvent;
	
	import flash.display.Sprite;
	
	import org.osflash.signals.Signal;
	
	public class AbstractHud extends Sprite
	{
		
		protected var onScreenElements:Vector.<Sprite>;
		protected var onScreenTweens:Vector.<TweenMax>;
		
		private var buttons:Vector.<IAudioBrushButton>;
		private var lockAllButton:Boolean = false;
		private var hudHasButtons:Boolean = true;
		private var removeInterfaceAfterButtonsClean:Boolean = false;
		
		protected var hudIsClean:Boolean = true;
		
		protected var superRemoveSignal:Signal;
		protected var buttonSignal:Signal;
		
		public function AbstractHud()
		{
			super();
			
			LOG.create(this);
			
			onScreenElements = new Vector.<Sprite>;
			onScreenTweens = new Vector.<TweenMax>;
			buttons = new Vector.<IAudioBrushButton>;
			superRemoveSignal = new Signal();
			buttonSignal = new Signal();
		}
		
		protected function addElements():void{
			hudIsClean = false
			cleanTweens();
			for(var i:int = 0; i < onScreenElements.length; i++){
				onScreenElements[i].alpha = 1;
				this.addChild(onScreenElements[i]);
				//onScreenTweens.push(TweenMax.to(onScreenElements[i], 0.2, {alpha:1, ease:Linear.easeNone, delay:i*0.1+0.5}));
			}
			//onScreenTweens[onScreenTweens.length-1].addEventListener(TweenEvent.COMPLETE, cleanDisplayTweens);
		}
		
		protected function addAdditionalElements(elements:Vector.<Sprite>):void{
			hudIsClean = false
			cleanTweens();
			for(var i:int = 0; i < elements.length; i++){
				elements[i].alpha = 0;
				this.addChild(elements[i]);
				onScreenElements.push(elements[i]);
				onScreenTweens.push(TweenMax.to(elements[i], 0.2, {alpha:1, ease:Linear.easeNone, delay:i*0.1}));
			}
			onScreenTweens[onScreenTweens.length-1].addEventListener(TweenEvent.COMPLETE, cleanDisplayTweens);
		}
		
		protected function removeSeperateElements(clip:Sprite):void{
			for(var i:int = 0; i < onScreenElements.length; i++){
				if(onScreenElements[i] == clip){
					this.removeChild(onScreenElements[i]);
					onScreenElements.splice(i, 1);
					break;
				}
			}
		}
		
		protected function displayElements():void{
			cleanTweens();
			for(var i:int = 0; i < onScreenElements.length; i++){
				onScreenElements[i].alpha = 0;
				onScreenTweens.push(TweenMax.to(onScreenElements[i], 0.2, {alpha:1, ease:Linear.easeNone, delay:i*0.1+0.5}));
			}
			onScreenTweens[onScreenTweens.length-1].addEventListener(TweenEvent.COMPLETE, cleanDisplayTweens);
		}
		
		protected function hideElements():void{
			cleanTweens();
			for(var i:int = 0; i < onScreenElements.length; i++){
				onScreenElements[i].alpha = 1;
				onScreenTweens.push(TweenMax.to(onScreenElements[i], 0.1, {alpha:0, ease:Linear.easeNone}));
			}
			onScreenTweens[onScreenTweens.length-1].addEventListener(TweenEvent.COMPLETE, cleanDisplayTweens);
		}
		
		protected function removeElements():void{
			cleanTweens();
			for(var i:int = 0; i < onScreenElements.length; i++){
				onScreenElements[i].alpha = 1;
				onScreenTweens.push(TweenMax.to(onScreenElements[i], 0.1, {alpha:0, ease:Linear.easeNone}));
			}
			if(onScreenElements.length > 0){
				onScreenTweens[onScreenTweens.length-1].addEventListener(TweenEvent.COMPLETE, removeAllOnScreenElements);
			}
		}
		
		/**
		 * Adds a button to the button handler
		 */
		protected function addButton(button:IAudioBrushButton):void{
			lockAllButton = false;
			hudHasButtons = true;
			buttons.push(button);
			button.buttonSignal.add(handleButtonEvents);
		}
		
		/**
		 * removes individual buttons
		 */
		protected function removeButton(button:IAudioBrushButton):void{
			button.buttonSignal.removeAll();
			for(var i:int = 0; i < buttons.length; i++){
				if(buttons[i] == button){
					buttons.splice(i, 1);
					i--;
				}
			}
			for(i = 0; i < onScreenElements.length; i++){
				if(onScreenElements[i] == button){
					this.removeChild(onScreenElements[i]);
					onScreenElements.splice(i, 1);
					i--;
				}
			}
		}
		
		/**
		 * Handles all the responses given by the buttons on this hud (if any)
		 */
		private function handleButtonEvents(buttonEventType:String, buttonOption:String = null):void{
			switch(buttonEventType){
				case ButtonEvent.BUTTON_CLEAN:
						var allButtonsClean:Boolean = true;
						for(var i:int = 0; i < buttons.length; i++){
							if(!buttons[i].buttonIsClean){
								allButtonsClean = false;
							}
							else{
								buttons.splice(i, 1);
								i--;
							}
						}
						if(removeInterfaceAfterButtonsClean && allButtonsClean){
							try{
								removeElements();
							}
							catch(e:Error){
								LOG.error("Tried to remove a hud that was already removed");
							}
						}
					break;
				case ButtonEvent.BUTTON_PRESSED:
					if(!lockAllButton){
						buttonSignal.dispatch(buttonOption);
					}
					break;
			}
		}
		
		/**
		 * Removes all the buttons
		 */
		protected function cleanButtons(removeAfterButtonClean:Boolean = true):void{
			removeInterfaceAfterButtonsClean = removeAfterButtonClean;
			lockAllButton = true;
			for(var i:int = 0; i < buttons.length; i++){
				buttons[i].removeButton(Math.random()*0.5);
			}
		}
		
		private function cleanDisplayTweens(e:TweenEvent):void{
			e.currentTarget.removeEventListener(TweenEvent.COMPLETE, cleanDisplayTweens);
			cleanTweens();
		}
		
		private function cleanTweens():void{
			if(onScreenTweens != null){
				if(onScreenTweens.length > 1){
					try{
						for(var i:int = 0; i < onScreenTweens.length; i++){
							if(onScreenTweens[i] != null){
								try{
									onScreenTweens[i].complete();
									onScreenTweens[i].kill();
									onScreenTweens[i] = null;
								}
								catch(e:Error){
									LOG.error("AbstractHud attempted to clean a tween that doesn't exist");
								}
							}
						}
					}
					catch(e:Error){
						LOG.error("Tried to clean tweens of a empty tween array");
					}
				}
				onScreenTweens = new Vector.<TweenMax>;
			}
		}
		
		private function removeAllOnScreenElements(e:TweenEvent):void{
			e.currentTarget.removeEventListener(TweenEvent.COMPLETE, removeAllOnScreenElements);
			cleanTweens();
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			hudIsClean = true;
			superRemoveSignal.dispatch();
		}
		
		public function destroy():void{
			if(hudIsClean){
				buttons = null;
				buttonSignal.removeAll();
				buttonSignal = null;
				onScreenElements = new Vector.<Sprite>;
				onScreenElements = null;
				onScreenTweens = null;
				superRemoveSignal.removeAll();
				superRemoveSignal = null;
				LOG.destroy(this);
			}
			else{
				LOG.fatal("Tried to remove a hud that has not been cleaned");
			}
		}
	}
}