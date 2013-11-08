package com.edgington.model.audio
{
	import com.edgington.model.GameProxy;
	import com.edgington.model.TutorialManager;
	
	import org.osflash.signals.Signal;

	public class AudioEventDispatcher
	{
		
		private var audioModel:AudioModel
		
		private var colourSignal:Signal;
		private var preColourSignal:Signal;
		private var starPowerSignal:Signal;
		private var beatSignal:Signal;
		private var rogueBeatSignal:Signal;
		private var addBeatSignal:Signal;
		private var addRogueBeatSignal:Signal;
		
		private var trackPosition:int;
		private var preColourWarningTime:int = 10; //warning before colour change time FPS
		
		private var currentSection:int = 0;
		private var preColourSection:int = 0;
		
		private var preCheckToMake:int = 0;
		
		private var lastCheckPosition_AddBeat:int = 20;
		private var lastCheckPosition_Beat:int = 5;
		
		private var band:int = 0;
		private var trackHeading:int = 15;
		
		private var tutorialPlayed:Boolean = false;
				
		public function AudioEventDispatcher(colourSignal:Signal, starPowerSignal:Signal, preColourSignal:Signal, beatSignal:Signal, addBeatSignal:Signal, rogueBeatSignal:Signal, addRogueBeatSignal:Signal)
		{
			
			audioModel = AudioModel.getInstance();
			
			switch(GameProxy.INSTANCE.currentHectiness){
				case 0:
					trackHeading = 30;
					break;
				case 1:
					trackHeading = 25;
					break;
				case 2:
					trackHeading = 20;
					break;
				case 3:
					trackHeading = 15;
					break;
				case 4:
					trackHeading = 15;
					break;
				case 5:
					trackHeading = 10;
					break;
			}
			
			this.colourSignal = colourSignal;
			this.starPowerSignal = starPowerSignal;
			this.preColourSignal = preColourSignal;
			this.beatSignal = beatSignal;
			this.addBeatSignal = addBeatSignal;
			this.addRogueBeatSignal = addRogueBeatSignal;
			this.rogueBeatSignal = rogueBeatSignal;
		}
		
		/**
		 * This is called during the game update which basically make sure the analysis is following the correct part of the track.
		 * It will also dispatch the appropiate events whenn needed
		 */
		public function playHeadPositon():void{
			trackPosition = audioModel.analyser.getNextWindow(audioModel.soundChannel.position);
			
			if(trackPosition != -1){
				if(audioModel.analyser.sections.length > preColourSection && audioModel.analyser.sections[preColourSection] < trackPosition+preColourWarningTime){
					preColourSignal.dispatch();
					preColourSection++;
				}
				
				if (audioModel.analyser.sections.length > currentSection && audioModel.analyser.sections[currentSection] < trackPosition){
					currentSection++;
					for(var i:int = 0; i < audioModel.analyser.starSections.length; i++){
						if(currentSection == audioModel.analyser.starSections[i]){
							starPowerSignal.dispatch();
							break;
						}
					}
					colourSignal.dispatch();
				}
				
//				//Checks for any beats missed due to Frame Rate Drop				
//				if(lastCheckPosition_AddBeat < trackPosition+19){
//					preCheckToMake = (trackPosition + 19) - lastCheckPosition_AddBeat;
//					for(var a:int = 1; a <= preCheckToMake; a++){
//						if(audioModel.analyser.beats[lastCheckPosition_AddBeat+a][0] != 0){
//							LOG.debug("Adding Missed Added Beat @ " + (lastCheckPosition_AddBeat+a));
//							addBeatSignal.dispatch(lastCheckPosition_AddBeat+a);	
//						}
//					}
//					lastCheckPosition_Beat = trackPosition+19;
//				}
//				if(lastCheckPosition_Beat < trackPosition-1){
//					preCheckToMake = (trackPosition - 1) - lastCheckPosition_Beat;
//					for(var b:int = 1; b <= preCheckToMake; b++){
//						if(audioModel.analyser.beats[lastCheckPosition_Beat+b][0] != 0){
//							LOG.debug("Adding Missed Beat @ " + (lastCheckPosition_Beat+b));
//							addBeatSignal.dispatch(lastCheckPosition_Beat+b);	
//						}
//					}
//					lastCheckPosition_Beat = trackPosition-1;
//				}
				
				//Dispatches the beats
				if(trackPosition+trackHeading < audioModel.analyser.beats.length){
					if(audioModel.analyser.beats[trackPosition+trackHeading][band] != 0){
						lastCheckPosition_AddBeat = trackPosition+trackHeading;
						addBeatSignal.dispatch(trackPosition+trackHeading);
					}
					else if(audioModel.analyser.beats[trackPosition+trackHeading][band+1] != 0){
						addRogueBeatSignal.dispatch(trackPosition+trackHeading);
					}
					if(audioModel.analyser.beats[trackPosition][band] != 0){
						lastCheckPosition_Beat = trackPosition;
						beatSignal.dispatch(trackPosition);
					}
					else if(audioModel.analyser.beats[trackPosition][band+1] != 0){
						rogueBeatSignal.dispatch(trackPosition);
					}
				}
				if(GameProxy.INSTANCE.isTutorial){
					if(!tutorialPlayed && trackPosition >= 10){
						tutorialPlayed = true;
						GameProxy.INSTANCE.tutorialSignal.dispatch(true, 0);
					}
					if(TutorialManager.getInstance().currentTutorialStage < 1){
						if(audioModel.soundChannel.position/audioModel.soundObject.length >= TutorialManager.getInstance().soundPositionStage_2){
							audioModel.soundChannel.stop();
							audioModel.soundChannel = audioModel.soundObject.play(TutorialManager.getInstance().soundPositionStage_1 * AudioModel.getInstance().soundObject.length);
						}
					}
					else if(TutorialManager.getInstance().currentTutorialStage < 12){
						if(audioModel.soundChannel.position/audioModel.soundObject.length >= TutorialManager.getInstance().soundPositionStage_3){
							audioModel.soundChannel.stop();
							audioModel.soundChannel = audioModel.soundObject.play(TutorialManager.getInstance().soundPositionStage_2 * AudioModel.getInstance().soundObject.length);
						}
					}
				}
			}
		}
		
		public function destroy():void{
			colourSignal = null;
			addBeatSignal = null;
			beatSignal = null;
			starPowerSignal = null;
			preColourSignal = null;
			
			audioModel = null;
		}
	}
}