package com.edgington.view.game.analysis
{
	import com.edgington.NativeMediaManager.NativeMediaVO;
	import com.edgington.constants.Constants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.SettingsProxy;
	import com.edgington.model.audio.AudioMainModel;
	import com.edgington.net.UserData;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.assets.AssetLoader;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_mainButton;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import org.osflash.signals.Signal;
	
	public class ViewTrackAnalysis extends AbstractHud implements IAbstractHud
	{
		
		private var trackTitle:ui_trackAnalysisTitle;
		private var trackAnalysis:ui_trackAnalysis;
		
		private var graphScreenMarginPercentage:Number = 0.2;
		
		private var trackData:NativeMediaVO;
		
		private var hecticnessLineGraph:MovieClip;
		private var sectionsDisplay:MovieClip;
		private var starSectionsDisplay:MovieClip;
		
		private var graphWidth:int = 0;
		private var graphHeight:int = 0;
		
		private var scale:Number = 0.02;
		
		private var hecticnessLineColour:uint = 0xfcee21;
		private var sectionLineColour:uint = 0xff00ff;
		private var starSectionColour:uint = 0x7ac943;
		
		private var stepAmount:int;
		
		private var normalised:Number = 0;
		private var lastValue:Number = 0;
		
		private var drawingStarSection:Boolean = false;
		private var starSectionStartingX:int = 0;
		
		private var readyToRemoveSignal:Signal;
		
		private var playButton:element_mainButton;
		private var cancelButton:element_mainButton;
		
		private var buttonOptions:Vector.<String> = new <String>["BACK", "PLAY"]; 
		
		public function ViewTrackAnalysis(removeSignal:Signal)
		{
			super();
			
			addListeners();
			
			setupVisuals();
			
			addElements();
			
			readyToRemoveSignal = removeSignal;
		}
		
		public function addListeners():void{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			superRemoveSignal.addOnce(readyForRemoval);
		}
		
		public function setupVisuals():void{
			trackData = AudioMainModel.getInstance().currentTrackDetails;
			
			trackAnalysis = new ui_trackAnalysis();
			trackAnalysis.graph.width = DynamicConstants.SCREEN_WIDTH-(DynamicConstants.SCREEN_WIDTH*graphScreenMarginPercentage)
			trackAnalysis.x = DynamicConstants.SCREEN_WIDTH*.5 - trackAnalysis.width*.5;
			trackAnalysis.y = DynamicConstants.SCREEN_HEIGHT*.5;
			trackAnalysis.txt_track.x = trackAnalysis.graph.x + (trackAnalysis.graph.width*.5) - (trackAnalysis.txt_track.width*.5);
			trackAnalysis.txt_track.y = trackAnalysis.graph.y + trackAnalysis.graph.height + 10;
			trackAnalysis.txt_hecticness.x = trackAnalysis.graph.x - trackAnalysis.txt_hecticness.width - 10;
			trackAnalysis.cacheAsBitmap = true;
			onScreenElements.push(trackAnalysis);
			
			trackTitle = new ui_trackAnalysisTitle();
			
			if(trackData != null && trackData.trackTitle != null){
				trackTitle.txt_title.text = trackData.trackTitle;
				trackTitle.txt_artist.text = trackData.artistName;
			}
			else{
				trackTitle.txt_title.text = "Debug Mode";
			}
			
			var trackTitleScale:Number = 1;
			trackTitleScale = Math.min(1, DynamicConstants.SCREEN_WIDTH/trackTitle.width);
			trackTitle.scaleX = trackTitle.scaleY = trackTitleScale;
			trackTitle.cacheAsBitmap = true;
			trackTitle.x = (DynamicConstants.SCREEN_WIDTH*.5) - (trackTitle.width *.5);
			trackTitle.y = DynamicConstants.SCREEN_MARGIN;
			
			if(UserData.getInstance().unlimited){
				playButton = new element_mainButton(gettext("analysis_play_button"), buttonOptions[1]);
			}
			else{
				playButton = new element_mainButton(gettext("analysis_play_button"), buttonOptions[1], Constants.TRACK_PLAY_COST);
			}
			playButton.x = trackTitle.x + trackTitle.width - playButton.width;
			playButton.y = trackTitle.y + trackTitle.height + DynamicConstants.BUTTON_SPACING;
			
			cancelButton = new element_mainButton(gettext("analysis_cancel_button"), buttonOptions[0]);
			cancelButton.x = trackTitle.x;
			cancelButton.y = trackTitle.y + trackTitle.height + DynamicConstants.BUTTON_SPACING;
			
			addButton(playButton);
			addButton(cancelButton);
			
			buttonSignal.add(handleInteraction);
			
			graphWidth = trackAnalysis.graph.width;
			graphHeight = trackAnalysis.graph.height;
			
			onScreenElements.push(trackTitle, playButton, cancelButton);
			
			hecticnessLineGraph = new MovieClip();
			hecticnessLineGraph.x = trackAnalysis.graph.x;
			hecticnessLineGraph.y = trackAnalysis.graph.y;
			trackAnalysis.addChild(hecticnessLineGraph);
			
			sectionsDisplay = new MovieClip();
			sectionsDisplay.x = trackAnalysis.graph.x;
			sectionsDisplay.y = trackAnalysis.graph.y;
			trackAnalysis.addChild(sectionsDisplay);
			
			starSectionsDisplay = new MovieClip();
			starSectionsDisplay.x = trackAnalysis.graph.x;
			starSectionsDisplay.y = trackAnalysis.graph.y;
			trackAnalysis.addChildAt(starSectionsDisplay, 0);
			
			drawTrackAnalysis();
		}
		
		private function handleInteraction(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_MAIN;
					cleanButtons();
					break
				case buttonOptions[1]:
					if(!UserData.getInstance().unlimited){
						UserData.getInstance().useCredits(Constants.TRACK_PLAY_COST);
					}
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.GAME_MAIN;
					cleanButtons();
					break;
			}
		}
		
		private function drawTrackAnalysis():void{
			var fluxThresholds:Vector.<Vector.<Number>> = AudioMainModel.getInstance().analyser.fluxThresholds;
			var sections:Array = AudioMainModel.getInstance().analyser.sections;
			var starSections:Array = AudioMainModel.getInstance().analyser.starSections;
			var currentSection:int = 0;
			stepAmount = Math.floor(fluxThresholds.length/graphWidth);
			normalised = fluxThresholds[0][0];
			lastValue = normalised;
			hecticnessLineGraph.graphics.moveTo(0, graphHeight+(normalised*scale)*-1);
			for(var i:int = 0; i < graphWidth; i++){
				normalised += (fluxThresholds[stepAmount*i][0] - lastValue)*.02;
				lastValue = normalised;
				var param1:Number = graphHeight+(normalised*scale)*-1;
				hecticnessLineGraph.graphics.lineStyle(2, hecticnessLineColour);
				hecticnessLineGraph.graphics.beginFill(hecticnessLineColour);
				hecticnessLineGraph.graphics.lineTo(i, param1);
				hecticnessLineGraph.graphics.moveTo(i, param1);
				hecticnessLineGraph.graphics.endFill();
				if(sections.length > currentSection && sections[currentSection] < stepAmount*i){
					drawNewSection(i);
					if(drawingStarSection){
						endStarSection(i);
					}
					for(var r:int = 0; r < starSections.length; r++){
						if(currentSection == starSections[r]){
							drawingStarSection = true;
							starSectionStartingX = i;
						}
					}
					currentSection++;
				}
			}
			
			if(hecticnessLineGraph.height > graphHeight){
				var mc:MovieClip = new MovieClip();
				mc.addChild(hecticnessLineGraph);
				mc.x = trackAnalysis.graph.x;
				mc.y = trackAnalysis.graph.y;
				trackAnalysis.addChild(mc);
				hecticnessLineGraph.height = graphHeight;
				
				
				var hecticnessBounds:Rectangle = mc.getBounds(mc);
				mc.y = trackAnalysis.graph.y-(hecticnessBounds.topLeft.y);
			}
			
			hecticnessLineGraph.cacheAsBitmap = true;
		}
		
		private function drawNewSection(xPos:int):void{
			if(xPos > 5){
				sectionsDisplay.graphics.lineStyle(1, sectionLineColour, 0.3);
				sectionsDisplay.graphics.moveTo(xPos, graphHeight);
				sectionsDisplay.graphics.beginFill(sectionLineColour, 0.1);
				sectionsDisplay.graphics.lineTo(xPos, 0);
				sectionsDisplay.graphics.endFill();
			}
		}
		
		private function endStarSection(xPos:int):void{
			drawingStarSection = false;
			var matrix:Matrix = new Matrix();
			matrix.scale(0.2, 0.2);
			starSectionsDisplay.graphics.beginBitmapFill(AssetLoader.imageDictionary[SettingsProxy.getInstance().currentTheme+"_gameStarBackground"], matrix, true);
			starSectionsDisplay.graphics.drawRect(starSectionStartingX, 0, xPos-starSectionStartingX, graphHeight);
			starSectionsDisplay.graphics.endFill();
			starSectionsDisplay.alpha = 0.8;
		}
		
		public function readyForRemoval():void{
			super.destroy();
			readyToRemoveSignal.dispatch();
		}
		
		private function destroy(e:Event):void{
			LOG.createCheckpoint("Track Analysis Viewed");
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			hecticnessLineGraph = null;
			sectionsDisplay = null;
			starSectionsDisplay = null;
			trackTitle = null;
			trackAnalysis = null;
			readyToRemoveSignal = null;
			playButton = null;
			cancelButton = null;
		}
	}
}