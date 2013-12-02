package com.edgington.view.huds.elements
{
	import com.edgington.constants.Constants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.events.ButtonEvent;
	import com.edgington.net.UserData;
	import com.edgington.types.FontFaceType;
	import com.edgington.util.localisation.getfont;
	import com.edgington.util.localisation.gettext;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class element_bonus extends Sprite
	{
		
		private var bonus:ui_bonus;
		
		private var bonusTimer:Timer;
		
		private var collectButton:element_mainMiniButton;
		private var collectionShowTimer:Timer;
		
		private var collectionProcessed:Boolean = false;
		private var waitingForResetTimer:Boolean = false;
		
		public function element_bonus()
		{
			super();
			
			addListeners();
		}
		
		private function addListeners():void{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			if(UserData.getInstance().bonusTime != 0){
				setupVisuals();
			}
			UserData.getInstance().bonusSignal.addOnce(setupVisuals);
			UserData.getInstance().checkBonusStatus();
		}
		
		private function setupVisuals():void{
			bonus = new ui_bonus();
			
			bonus.scaleX = bonus.scaleY = DynamicConstants.MESSAGE_SCALE;
			bonus.x = DynamicConstants.SCREEN_WIDTH - bonus.width - DynamicConstants.SCREEN_MARGIN;
			bonus.y = DynamicConstants.SCREEN_HEIGHT - bonus.height - DynamicConstants.SCREEN_MARGIN;
		
			this.addChild(bonus);
			
			var bonusTime:Number = caluclateBonusTime();
			if(bonusTime>=Constants.BONUS_DELAY){
				bonusAvailable();
			}
			else{
				checkBonus(null);
				bonusCountDown();
			}
			
			
			
			
		}
		
		/**
		 * This is called if the frist time is loaded with a bonus not available.
		 */
		private function bonusCountDown():void{
			collectionProcessed = false;
			bonus.gotoAndStop(1);
			getfont(bonus.txt_bonus_title, FontFaceType.BOLD);
			getfont(bonus.txt_available_in, FontFaceType.REGULAR);
			getfont(bonus.txt_time, FontFaceType.BOLD);
			bonus.txt_bonus_title.text = gettext("bonus_title");
			bonus.txt_available_in.text = gettext("bonus_available_in_title");
			
			bonusTimer = new Timer(1000, 0);
			bonusTimer.addEventListener(TimerEvent.TIMER, checkBonus);
			bonusTimer.start();
		}
		
		/**
		 * When a bonus is not available this is called every second.
		 */
		private function checkBonus(e:TimerEvent):void{
			var bonusTime:Number = caluclateBonusTime();
			
			if(bonusTime>=Constants.BONUS_DELAY){
				bonusTimer.removeEventListener(TimerEvent.TIMER, checkBonus);
				bonusTimer.stop();
				bonusTimer = null;
				bonusAvailable();
				return;
			}
			
			//This contains the amount of milliseconds until available;
			bonusTime = Constants.BONUS_DELAY - bonusTime;
			
			getfont(bonus.txt_bonus_title, FontFaceType.BOLD);
			getfont(bonus.txt_time, FontFaceType.BOLD);
			bonus.txt_time.text = getTimerText(bonusTime);
		}
		
		/**
		 * When the first time this is loaded and there is a bonus available.
		 */
		private function bonusAvailable():void{
			bonus.gotoAndStop(2);
			
			
			getfont(bonus.txt_available, FontFaceType.REGULAR);
			bonus.txt_bonus_title.text = gettext("bonus_title");
			bonus.txt_available.text = gettext("bonus_available_title");
			
			collectButton = new element_mainMiniButton(gettext("bonus_available_collect_button"), "collect");		
			collectButton.buttonSignal.add(handleButtonSignal);
			collectButton.x = bonus.x + (bonus.width*.5) - (collectButton.width*.5);
			collectButton.y = bonus.y + bonus.height - collectButton.height - (7*DynamicConstants.MESSAGE_SCALE);
			this.addChild(collectButton);
		}
		
		private function handleButtonSignal(eventType:String, buttonOption:String = ""):void{
			if(eventType == ButtonEvent.BUTTON_PRESSED){
				bonus.gotoAndStop(3);
				
				getfont(bonus.txt_collected, FontFaceType.BOLD);
				getfont(bonus.txt_credits, FontFaceType.BOLD);
				bonus.txt_collected.text = gettext("bonus_collected");
				bonus.txt_credits.text = gettext("bonus_credits");
				
				waitingForResetTimer = true;
				
				UserData.getInstance().bonusSignal.add(handleBonusCollected);
				UserData.getInstance().collectBonus();
				
				collectionShowTimer = new Timer(5000, 1);
				collectionShowTimer.addEventListener(TimerEvent.TIMER_COMPLETE, restartBonusCounter);
				collectionShowTimer.start();
			}
			else{
				if(collectButton != null){
					collectButton.buttonSignal.remove(handleButtonSignal);
					this.removeChild(collectButton);
					collectButton = null;
				}
			}
		}
		
		/**
		 * Let's make sure that the bonus has been processed before starting the countdown again.
		 */
		private function handleBonusCollected():void{
			if(!waitingForResetTimer){
				//If the timer has already completed we need to do this straight away.
				checkBonus(null);
				bonusCountDown();
			}
			collectionProcessed = true;
		}
		
		/**
		 * When we've collected the bonus, lets go back to the countdown view.
		 */
		private function restartBonusCounter(e:TimerEvent):void{
		
			
			if(collectionProcessed){
				bonusCountDown();
				checkBonus(null);
			}
			waitingForResetTimer = false;
		}
		
		/**
		 * Returns the amount of time between now and the previous bonus
		 */
		private function caluclateBonusTime():Number{
			var currentTime:Date = DynamicConstants.getCurrentServerTime();
			var bonusTime:Date = UserData.getInstance().userProfile.last_bonus;
			if(bonusTime == null){
				return Constants.BONUS_DELAY;
			}
			return currentTime.time - bonusTime.time;
		}
		
		/**
		 * returns a string in the format of 00:00:00 (HH:MM:SS) from a millisecond duration
		 */
		private function getTimerText(timeSpan):String{
			var time:Number = timeSpan;
			var hours:int = 0;
			var minutes:int = 0;
			var seconds:int = 0;
			var timeString:String = "";
			
			hours = Math.floor(time/3600000);
			minutes = Math.floor((time-(hours*3600000))/60000);
			seconds = Math.floor((time - ((hours*3600000)+(minutes*60000)))/1000);
			
			timeString += hours < 10 ? "0" + hours : hours;
			timeString += ":";
			timeString += minutes < 10 ? "0" + minutes : minutes;
			timeString += ":";
			timeString += seconds < 10 ? "0" + seconds : seconds;
			return timeString;
		}
		
		private function destroy(e:Event):void{
			if(bonusTimer != null){
				bonusTimer.removeEventListener(TimerEvent.TIMER, checkBonus);
				bonusTimer.stop();
				bonusTimer = null;
			}
			if(collectionShowTimer != null){
				collectionShowTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, restartBonusCounter);
				collectionShowTimer.stop();
				collectionShowTimer = null;
			}
			if(collectButton != null){
				collectButton.buttonSignal.remove(handleButtonSignal);
				this.removeChild(collectButton);
				collectButton = null;
			}
			UserData.getInstance().bonusSignal.remove(handleBonusCollected);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			
			collectButton = null;
			bonus = null;
		}
	}
}