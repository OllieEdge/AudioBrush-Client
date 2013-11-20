package com.edgington.view
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.GameLevelInformationHandler;
	import com.edgington.model.GameProxy;
	import com.edgington.model.SoundManager;
	import com.edgington.model.TutorialManager;
	import com.edgington.model.audio.AudioModel;
	import com.edgington.model.calculators.LevelCalculator;
	import com.edgington.model.calculators.ScoreCalculator;
	import com.edgington.model.events.AudioEvent;
	import com.edgington.net.TournamentData;
	import com.edgington.net.UserData;
	import com.edgington.types.DifficultyTypes;
	import com.edgington.types.GameStateTypes;
	import com.edgington.view.game.Canvas;
	import com.edgington.view.game.InGameHud;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.AudioPlaybackMode;
	import flash.media.SoundMixer;
	
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
			
			SoundManager.instance.pauseBGM();
			SoundMixer.audioPlaybackMode = AudioPlaybackMode.MEDIA;
			
			if(GameLevelInformationHandler.checkIfAvailable()){
				GameLevelInformationHandler.deleteInstance();
			}
			GameLevelInformationHandler.getInstance().levelBeforeGame = LevelCalculator.getLevel(UserData.getInstance().userProfile.xp);
			GameLevelInformationHandler.getInstance().xpBeforeGame = UserData.getInstance().userProfile.xp;
			
			gameProxy = GameProxy.getInstance();
			gameProxy.isTournament = TournamentData.getInstance().isThisGameATournamentGame;
			gameProxy.isTutorial = AudioModel.getInstance().isTutorial;
			gameProxy.currentTrackDetails = AudioModel.getInstance().currentTrackDetails;
			gameProxy.currentTrackDifficulty = AudioModel.getInstance().difficulty;
			gameProxy.currentBeatRatio = AudioModel.getInstance().beatRatio;
			gameProxy.currentHectiness = AudioModel.getInstance().hecticness;
			gameProxy.normalBeatsFromAnalyser = AudioModel.getInstance().musicAnalyser.normalBeats;
			gameProxy.rogueBeatsFromAnalyser = AudioModel.getInstance().musicAnalyser.rogueBeats;
			gameProxy.scoreCalculations = ScoreCalculator.getMaximumScore(gameProxy.normalBeatsFromAnalyser);
			gameProxy.pauseSignal.add(pauseGame);
			gameProxy.tutorialSignal.add(tutorialPause);
			gameProxy.killGameEarlySignal.add(killGameEarly);
			gameProxy.difficulty = DifficultyTypes.difficultyStringIDToID(AudioModel.getInstance().difficulty);
			
			canvas = new Canvas();
			this.addChild(canvas);
			
			gameHud = new InGameHud();
			this.addChild(gameHud);
			
			addListeners();
		}
		
		private function addListeners():void{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			trackStatusSignal = AudioModel.getInstance().trackStatusSignal;
			trackStatusSignal.add(onTrackStatus);
		}
		
		private function killGameEarly():void{
			killEarly = true;
			AudioModel.getInstance().pause();
			canvas.removeAllListeners();
			readyToRemove();
		}
		
		private function pauseGame(pauseGame:Boolean):void{
			if(pauseGame){
				canvas.pause();
				AudioModel.getInstance().pause();
			}
			else{
				AudioModel.getInstance().resume();
				canvas.resume();
			}
		}
		
		private function tutorialPause(pauseGame:Boolean, tutorialSection:int = 0):void{
			if(pauseGame){
				gameProxy.activeGame = false;
				canvas.pause();
				AudioModel.getInstance().pause();
			}
			else{
				gameProxy.activeGame = true;
				AudioModel.getInstance().resume();
				canvas.resume();
			}
		}
		
		private function onTrackStatus(audioEvent:String, arg:Number = 0):void{
			if(audioEvent == AudioEvent.TRACK_COMPLETE && !gameProxy.isTutorial){
				//generateOpenGraphActivity();
				DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.SUMMARY_MENU;
				canvas.removeAllListeners();
				readyToRemove();
			}
			else if(audioEvent == AudioEvent.TRACK_COMPLETE && gameProxy.isTutorial){
				DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_MAIN;
				canvas.removeAllListeners();
				readyToRemove();
			}
		}
		
		private function readyToRemove():void{
			readyToRemoveSignal.dispatch();
		}
		
		private function destroy(e:Event):void{
			SoundMixer.audioPlaybackMode = AudioPlaybackMode.AMBIENT;
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			gameProxy.tutorialSignal.remove(tutorialPause);
			TutorialManager.deleteInstance();
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			gameProxy.beatCollected(-5, false, -1, false);
			gameProxy = null;
			if(killEarly || GameProxy.getInstance().isTutorial){
				if(killEarly && GameLevelInformationHandler.checkIfAvailable()){
					GameLevelInformationHandler.deleteInstance();
				}
				GameProxy.deleteInstance();
			}
			
			trackStatusSignal.removeAll();
			trackStatusSignal = null;
			readyToRemoveSignal = null;
		}
	}
}