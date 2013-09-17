package com.edgington.model.audio
{
	import org.osflash.signals.Signal;

	public class AudioEventDispatcher
	{
		
		private var audioModel:AudioMainModel
		
		private var colourSignal:Signal;
		private var preColourSignal:Signal;
		private var starPowerSignal:Signal;
		private var beatSignal:Signal;
		private var addBeatSignal:Signal;
		
		private var trackPosition:int;
		private var preColourWarningTime:int = 10; //warning before colour change time FPS
		
		private var currentSection:int = 0;
		private var preColourSection:int = 0;
		
		private var preCheckToMake:int = 0;
		
		private var lastCheckPosition_AddBeat:int = 20;
		private var lastCheckPosition_Beat:int = 5;
				
		public function AudioEventDispatcher(colourSignal:Signal, starPowerSignal:Signal, preColourSignal:Signal, beatSignal:Signal, addBeatSignal:Signal)
		{
			
			audioModel = AudioMainModel.getInstance();
			
			this.colourSignal = colourSignal;
			this.starPowerSignal = starPowerSignal;
			this.preColourSignal = preColourSignal;
			this.beatSignal = beatSignal;
			this.addBeatSignal = addBeatSignal;
		}
		
		/**
		 * This is called during the game update which basically make sure the analysis is following the correct part of the track.
		 * It will also dispatch the appropiate events whenn needed
		 */
		public function playHeadPositon():void{
			trackPosition = audioModel.parser.getNextWindow(audioModel.soundChannel.position);
			
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
				if(trackPosition+20 < audioModel.analyser.beats.length){
					if(audioModel.analyser.beats[trackPosition+20][0] != 0){
						lastCheckPosition_AddBeat = trackPosition+20;
						addBeatSignal.dispatch(trackPosition+20);
					}
					if(audioModel.analyser.beats[trackPosition][0] != 0){
						lastCheckPosition_Beat = trackPosition;
						beatSignal.dispatch(trackPosition);
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