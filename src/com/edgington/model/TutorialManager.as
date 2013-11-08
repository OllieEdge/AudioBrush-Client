package com.edgington.model
{
	import com.edgington.util.debug.LOG;

	public class TutorialManager
	{
		
		private static var INSTANCE:TutorialManager;
		
		public var currentTutorialStage:int = 0;
		
		public var rogueBeatStage:int = 5;
		
		public var soundPositionStage_1:Number = 0;
		public var soundPositionStage_2:Number = 0.1;
		public var soundPositionStage_3:Number = 0.2;
		public var soundPositionStage_4:Number = 0.4;
		
		private var currentBeatsOnStage1:int = 0;
		private var currentBeatsOnStage3:int = 0;
		private var currentBeatsOnStage5:int = 0;
		
		public function TutorialManager()
		{
			LOG.create(TutorialManager);
		}
		
		public function getCurrentTutorialID():String{
			return "tutorial_" + currentTutorialStage;
		}
		
		public function increaseBeatsOnStage1():void{
			currentBeatsOnStage1++;
			if(currentBeatsOnStage1 == 5){
				currentTutorialStage++;
				LOG.debug("TUTORIAL: Increased tutorial stage to - " + currentTutorialStage);
				GameProxy.INSTANCE.tutorialSignal.dispatch(true, currentTutorialStage);
			}
		}
		
		public function increaseBeatsOnStage3():void{
			currentBeatsOnStage3++;
			if(currentBeatsOnStage3 == 10){
				currentTutorialStage++;
				LOG.debug("TUTORIAL: Increased tutorial stage to - " + currentTutorialStage);
				GameProxy.INSTANCE.tutorialSignal.dispatch(true, currentTutorialStage);
			}
		}
		
		public function increaseBeatsOnStage5():void{
			currentBeatsOnStage5++;
			if(currentBeatsOnStage5 == 4){
				currentTutorialStage++;
				LOG.debug("TUTORIAL: Increased tutorial stage to - " + currentTutorialStage);
				GameProxy.INSTANCE.tutorialSignal.dispatch(true, currentTutorialStage);
			}
		}
		
		public static function deleteInstance():void{
			INSTANCE = null;
			LOG.createCheckpoint("TUTORIAL: Finished");
		}
		
		public static function getInstance():TutorialManager{
			if(INSTANCE == null){
				INSTANCE = new TutorialManager();
			}
			return INSTANCE;
		}
	}
}