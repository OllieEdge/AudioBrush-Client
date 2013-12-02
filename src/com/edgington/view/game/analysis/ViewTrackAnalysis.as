package com.edgington.view.game.analysis
{
	import com.edgington.constants.Constants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.ipodlibrary.ILMediaItem;
	import com.edgington.model.SettingsProxy;
	import com.edgington.model.SoundManager;
	import com.edgington.model.audio.AudioModel;
	import com.edgington.net.TournamentData;
	import com.edgington.net.TrackData;
	import com.edgington.net.UserData;
	import com.edgington.types.DeviceTypes;
	import com.edgington.types.DifficultyTypes;
	import com.edgington.types.FontFaceType;
	import com.edgington.types.GameStateTypes;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.getfont;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.assets.AssetLoader;
	import com.edgington.view.huds.base.AbstractHud;
	import com.edgington.view.huds.base.IAbstractHud;
	import com.edgington.view.huds.elements.element_mainButton;
	
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	import org.osflash.signals.Signal;
	
	public class ViewTrackAnalysis extends AbstractHud implements IAbstractHud
	{
		
		private var trackTitle:ui_trackAnalysisTitle;
		private var trackAnalysis:ui_trackAnalysis;
		
		private var graphScreenMarginPercentage:Number = 0.2;
		
		private var trackData:ILMediaItem;
		
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
		
		private var allValues:Number = 0;
		
		private var trackImage:TrackData;
		
		public function ViewTrackAnalysis(removeSignal:Signal)
		{
			super();
			
			SoundManager.instance.pauseBGM();

			addListeners();
			
			setupVisuals();
			
			addElements();
			
			readyToRemoveSignal = removeSignal;
		}
		
		public function addListeners():void{
			LOG.createCheckpoint("MENU: Track Analysis");
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			superRemoveSignal.addOnce(readyForRemoval);
		}
		
		public function setupVisuals():void{
			trackData = AudioModel.getInstance().currentTrackDetails;
			
			trackTitle = new ui_trackAnalysisTitle();
			
			getfont(trackTitle.txt_title, FontFaceType.BOLD);
			getfont(trackTitle.txt_artist, FontFaceType.REGULAR);
			getfont(trackTitle.txt_difficulty, FontFaceType.BOLD);
			
			if(trackData != null && trackData.trackTitle != null){
				trackTitle.txt_title.text = trackData.trackTitle;
				trackTitle.txt_artist.text = trackData.artist;
			}
			else{
				trackTitle.txt_title.text = "Debug Mode";
			}
			
			trackTitle.scaleX = trackTitle.scaleY = DynamicConstants.MESSAGE_SCALE;
			trackTitle.cacheAsBitmap = true;
			trackTitle.x = (DynamicConstants.SCREEN_WIDTH*.5) - (trackTitle.width *.5);
			trackTitle.y = DynamicConstants.SCREEN_MARGIN;
			
			trackImage = new TrackData(new <String>[trackData.trackTitle, trackData.artist], trackTitle.picture);
			
			
			
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(Constants.DARK_WHITE_COLOUR, 1);
			if(DeviceTypes.IPHONE == DynamicConstants.DEVICE_TYPE){
				sprite.graphics.drawRect(0, 0, DynamicConstants.SCREEN_WIDTH-(DynamicConstants.SCREEN_MARGIN*2), DynamicConstants.SCREEN_HEIGHT - (DynamicConstants.SCREEN_MARGIN*3.5) - trackTitle.height);
			}
			else{
				sprite.graphics.drawRect(0, 0, DynamicConstants.SCREEN_WIDTH-(DynamicConstants.SCREEN_MARGIN*2), DynamicConstants.SCREEN_HEIGHT - (DynamicConstants.SCREEN_MARGIN*2.5) - trackTitle.height);
			}
			sprite.graphics.endFill();
			sprite.x = DynamicConstants.SCREEN_WIDTH*.5 - sprite.width*.5;
			sprite.y = trackTitle.y + trackTitle.height + DynamicConstants.BUTTON_SPACING;
			
			var graphSprite:Sprite = new Sprite();
			graphSprite.graphics.beginFill(Constants.DARK_FONT_COLOR);
			graphSprite.graphics.drawRect(0, 0, sprite.width-(25*DynamicConstants.DEVICE_SCALE), sprite.height-(25*DynamicConstants.DEVICE_SCALE));
			graphSprite.graphics.endFill();
			graphSprite.x = sprite.x + ((sprite.width*.5) - (graphSprite.width*.5));
			graphSprite.y = sprite.y + ((sprite.height*.5) - (graphSprite.height*.5));
			
			graphWidth = graphSprite.width;
			graphHeight = graphSprite.height;
			
			
			
			sectionsDisplay = new MovieClip();
			graphSprite.addChild(sectionsDisplay);
			
			starSectionsDisplay = new MovieClip();
			graphSprite.addChild(starSectionsDisplay);
			
			hecticnessLineGraph = new MovieClip();
			hecticnessLineGraph.y = graphSprite.height;
			graphSprite.addChild(hecticnessLineGraph);
			
			onScreenElements.push(trackTitle, sprite, graphSprite);
					
			if(UserData.getInstance().unlimited){
				playButton = new element_mainButton(gettext("analysis_play_button"), buttonOptions[1]);
			}
			else{
				if(AudioModel.getInstance().isTournament){
					playButton = new element_mainButton(gettext("analysis_play_button"), buttonOptions[1], TournamentData.getInstance().currentActiveTournament.COST);			
				}
				else{
					playButton = new element_mainButton(gettext("analysis_play_button"), buttonOptions[1], Constants.TRACK_PLAY_COST);	
				}
			}
			
			playButton.x = sprite.x + sprite.width - playButton.width;
			playButton.y = sprite.y + sprite.height + DynamicConstants.BUTTON_SPACING;
			
			cancelButton = new element_mainButton(gettext("analysis_cancel_button"), buttonOptions[0]);
			cancelButton.x = sprite.x;
			cancelButton.y = sprite.y + sprite.height + DynamicConstants.BUTTON_SPACING;
			
			addButton(playButton);
			addButton(cancelButton);
			
			buttonSignal.add(handleInteraction);
		
			onScreenElements.push(playButton, cancelButton);

			drawTrackAnalysis();
			var difficultyIcon:MovieClip;
		
			switch(AudioModel.getInstance().difficulty){
				case DifficultyTypes.DIFFICULTY_EASY:
					trackTitle.txt_difficulty.text = gettext("difficulty_name_easy").toUpperCase();
					trackTitle.difficulty_icon.gotoAndStop(1);
					difficultyIcon = new ui_difficulty_easy() as MovieClip;
					break;
				case DifficultyTypes.DIFFICULTY_NORMAL:
					trackTitle.txt_difficulty.text = gettext("difficulty_name_normal").toUpperCase();
					trackTitle.difficulty_icon.gotoAndStop(2);
					difficultyIcon = new ui_difficulty_normal() as MovieClip;
					break;
				case DifficultyTypes.DIFFICULTY_HARD:
					trackTitle.txt_difficulty.text = gettext("difficulty_name_hard").toUpperCase();
					trackTitle.difficulty_icon.gotoAndStop(3);
					difficultyIcon = new ui_difficulty_hard() as MovieClip;
					break;
				case DifficultyTypes.DIFFICULTY_EXTREME:
					trackTitle.txt_difficulty.text = gettext("difficulty_name_expert").toUpperCase();
					trackTitle.difficulty_icon.gotoAndStop(4);
					difficultyIcon = new ui_difficulty_expert() as MovieClip;
					break;
				case DifficultyTypes.DIFFICULTY_INSANE:
					trackTitle.txt_difficulty.text = gettext("difficulty_name_insane").toUpperCase();
					trackTitle.difficulty_icon.gotoAndStop(5);
					difficultyIcon = new ui_difficulty_insane() as MovieClip;
					break;
			}
			difficultyIcon.height = graphHeight*.7;
			difficultyIcon.scaleX = difficultyIcon.scaleY;
			difficultyIcon.y = graphHeight * .5;
			difficultyIcon.x = graphWidth * .5;
			difficultyIcon.alpha = 0.3;
			difficultyIcon.blendMode = BlendMode.ADD;
			graphSprite.addChildAt(difficultyIcon, 1);
			graphSprite.cacheAsBitmap = true;
		}
		
		private function handleInteraction(buttonOption:String):void{
			switch(buttonOption){
				case buttonOptions[0]:
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.MENU_MAIN;
					cleanButtons();
					break
				case buttonOptions[1]:
					if(!UserData.getInstance().unlimited){
						if(AudioModel.getInstance().isTournament){
							UserData.getInstance().useCredits(TournamentData.getInstance().currentActiveTournament.COST);
						}
						else{
							UserData.getInstance().useCredits(Constants.TRACK_PLAY_COST);
						}
					}
					DynamicConstants.CURRENT_GAME_STATE = GameStateTypes.GAME_MAIN;
					cleanButtons();
					break;
			}
		}
		
		private function drawTrackAnalysis():void{
			
			var fluxThresholds:Vector.<Vector.<Number>> = AudioModel.getInstance().analyser.fluxThresholds;
			var sections:Array = AudioModel.getInstance().analyser.sections;
			var starSections:Array = AudioModel.getInstance().analyser.starSections;
			var currentSection:int = 0;
			stepAmount = Math.floor(fluxThresholds.length/graphWidth);
			
			
			var highestFluxThreshold:Number = 0;
			var lowestFluxThreshold:Number  = 0;
			var averageFluxThresholds:Number = 0;
			var numberOfResults:uint = 0;
			
			for(var i:int = 0; i < graphWidth; i++){
				averageFluxThresholds += fluxThresholds[stepAmount*i][0];
				if(fluxThresholds[stepAmount*i][0] > highestFluxThreshold){
					highestFluxThreshold = fluxThresholds[stepAmount*i][0];
				}
				if(lowestFluxThreshold > fluxThresholds[stepAmount*i][0]){
					lowestFluxThreshold = fluxThresholds[stepAmount*i][0];
				}
				i+=3;
				numberOfResults++;
			}
			
			averageFluxThresholds = averageFluxThresholds / numberOfResults;
			
			normalised = fluxThresholds[0][0];
			scale = graphHeight / highestFluxThreshold;
			lastValue = normalised;
			hecticnessLineGraph.graphics.moveTo(0, normalised*scale*-1);
		
			
			
			for(i = 0; i < graphWidth; i++){
				normalised += (fluxThresholds[stepAmount*i][0] - lastValue)*.04;
				lastValue = normalised;
				var param1:Number = (normalised*scale)*-1;
				allValues += param1;
				hecticnessLineGraph.graphics.lineStyle(2*DynamicConstants.DEVICE_SCALE, Constants.DARK_WHITE_COLOUR);
				hecticnessLineGraph.graphics.beginFill(Constants.DARK_WHITE_COLOUR);
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
				i+=3;
			}
			
			allValues = (allValues / graphWidth)*-1;
			
			AudioModel.getInstance().difficulty = DifficultyTypes.getDifficultyOfGame(averageFluxThresholds, AudioModel.getInstance().analyser.beatRatio);
			AudioModel.getInstance().updateTrackDifficultyCache();
			AudioModel.getInstance().hecticness = DifficultyTypes.getHecticnessRating(averageFluxThresholds);
			AudioModel.getInstance().beatRatio = DifficultyTypes.getBeatRatioRating(AudioModel.getInstance().analyser.beatRatio);

			hecticnessLineGraph.cacheAsBitmap = true;
		}
		
		private function drawNewSection(xPos:int):void{
			if(xPos > 5){
				sectionsDisplay.graphics.lineStyle(1, Constants.DARK_WHITE_COLOUR, 0.3);
				sectionsDisplay.graphics.moveTo(xPos, graphHeight);
				sectionsDisplay.graphics.beginFill(Constants.DARK_WHITE_COLOUR, 0.1);
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
			starSectionsDisplay.alpha = 0.4;
			starSectionsDisplay.blendMode = BlendMode.ADD;
		}
		
		public function readyForRemoval():void{
			super.destroy();
			readyToRemoveSignal.dispatch();
		}
		
		private function destroy(e:Event):void{
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
			
			trackData = null;
			
			readyToRemoveSignal = null;
			
			buttonOptions = null;
			
			trackImage = null;
			
		}
	}
}