package com.edgington.view
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.GameProxy;
	import com.edgington.model.audio.AudioMainModel;
	import com.edgington.model.events.AudioEvent;
	import com.edgington.net.TournamentData;
	import com.edgington.types.GameStateTypes;
	import com.edgington.view.game.Canvas;
	import com.edgington.view.game.InGameHud;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class GameView extends Sprite
	{
		
		private var canvas:Canvas;
		
		private var readyToRemoveSignal:Signal;
		
		private var trackStatusSignal:Signal;
		
		private var gameHud:InGameHud;
		
		private var gameProxy:GameProxy;
		
		private var killEarly:Boolean = false;
		
		public function GameView(removeSignal:Signal)
		{
			readyToRemoveSignal = removeSignal;
			
			gameProxy = GameProxy.getInstance();
			gameProxy.isTournament = TournamentData.getInstance().isThisGameATournamentGame;
			gameProxy.currentTrackDetails = AudioMainModel.getInstance().currentTrackDetails;
			gameProxy.pauseSignal.add(pauseGame);
			gameProxy.killGameEarlySignal.add(killGameEarly);
			
			canvas = new Canvas();
			this.addChild(canvas);
			
			gameHud = new InGameHud();
			this.addChild(gameHud);
			
			addListeners();
		}
		
		private function addListeners():void{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			trackStatusSignal = AudioMainModel.getInstance().trackStatusSignal;
			trackStatusSignal.add(onTrackStatus);
		}
		
		private function killGameEarly():void{
			killEarly = true;
			AudioMainModel.getInstance().pause();
			canvas.removeAllListeners();
			readyToRemove();
		}
		
		private function pauseGame(pauseGame:Boolean):void{
			if(pauseGame){
				canvas.pause();
				AudioMainModel.getInstance().pause();
			}
			else{
				AudioMainModel.getInstance().resume();
				canvas.resume();
			}
		}
		
		private function onTrackStatus(audioEvent:String, arg:Number = 0):void{
			if(audioEvent == AudioEvent.TRACK_COMPLETE){
				//generateOpenGraphActivity();
				DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.SUMMARY_MENU;
				canvas.removeAllListeners();
				readyToRemove();
			}
		}
		
		private function readyToRemove():void{
			readyToRemoveSignal.dispatch();
		}
		
		private function destroy(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			gameProxy.beatCollected(-5, false, -1);
			gameProxy = null;
			if(killEarly){
				GameProxy.deleteInstance();
			}
			
			trackStatusSignal.removeAll();
			trackStatusSignal = null;
			readyToRemoveSignal = null;
		}
	}
}