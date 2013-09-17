package com.edgington.model.audio.analysis
{
	import com.edgington.model.audio.analysis.MusicParser;
	import com.edgington.valueobjects.AudioCachedVO;
	
	import __AS3__.vec.Vector;
	
	public class MusicAnalyser extends Object
	{
		private var debugMode:Boolean = true;
		private var musicParser:MusicParser;
		private var THRESHOLD_WINDOW_SIZE:int = 22;
		private var THRESHOLD_MULTIPLIER:Number = 2.5;
		private var SECTION_WINDOW_SIZE:int = 22;
		private var SECTION_MULTIPLIER:Number = 3.5;
		private var SECTION_BAND:int = 0;
		
		private var MAXIMUM_STAR_SECTIONS:int = 4;
		
		public var sections:Array;
		public var sectionsAverage:Array;
		public var starSections:Array;
		public var fluxThresholds:Vector.<Vector.<Number>>;
		public var beats:Vector.<Vector.<Number>>;
		public var beatsDetected:Vector.<Number>;
		
		public var BPM:int;
		private var thresholdTimeframe:Vector.<int>;
		private var percentCompleted:int = 0;
		
		public function MusicAnalyser(param1:MusicParser)
		{
			sections = new Array();
			sectionsAverage = new Array();
			starSections = new Array();
			musicParser = param1;
			beatsDetected = new Vector.<Number>(param1.octaveList.length, true);
			fluxThresholds = new Vector.<Vector.<Number>>(param1.totalSamples, true);
			var _loc_2:int = 0;
			while (_loc_2 < param1.totalSamples)
			{
				
				fluxThresholds[_loc_2] = new Vector.<Number>(param1.octaveList.length);
				_loc_2++;
			}
			beats = new Vector.<Vector.<Number>>(param1.totalSamples, true);
			_loc_2 = 0;
			while (_loc_2 < param1.totalSamples)
			{
				
				beats[_loc_2] = new Vector.<Number>(param1.octaveList.length);
				_loc_2++;
			}
			thresholdTimeframe = new Vector.<int>(param1.octaveList.length);
			thresholdTimeframe[0] = 250;
			thresholdTimeframe[1] = 100;
			thresholdTimeframe[2] = 100;
			thresholdTimeframe[3] = 100;
			thresholdTimeframe[4] = 100;
			thresholdTimeframe[5] = 100;
		}
		
		/**
		 * If the track is has already been played before used the cached data
		 * 
		 * JOHN: You won't need this function
		 */
		public function skipFFTAndUsedCachedData(cachedTrack:AudioCachedVO):void{
			sections = cachedTrack.sections;
			sectionsAverage = cachedTrack.sectionsAverage;
			starSections = cachedTrack.starSections;
			fluxThresholds = cachedTrack.fluxThresholds;
			beats = cachedTrack.beats;
			beatsDetected = cachedTrack.beatsDetected;
		}
		
		public function Analyse():void
		{
			var _loc_3:int = 0;
			var _loc_1:int = 0;
			while (_loc_1 < musicParser.octaveList.length)
			{
				calculateSpectralFluxThresholds(_loc_1, fluxThresholds);
				_loc_1++;
			}
			_loc_1 = 0;
			while (_loc_1 < musicParser.octaveList.length)
			{
				
				_loc_3 = thresholdTimeframe[_loc_1] * 44.1 / musicParser.sampleSize;
				beatsDetected[_loc_1] = parseThresholdsForBeats(beats, _loc_1, musicParser.spectralFluxWindows, fluxThresholds, _loc_3);
				_loc_1++;
			}
			calculateSections();
			_loc_1 = 0;
			while (_loc_1 < sections.length)
			{
				_loc_1++;
			}
			//BPM = calculateTempo(0);
			
			calculateStarSections();
		}
		
		/**
		 * Experimental not currently used.
		 */
		private function pruneBeats(param1:Vector.<Vector.<Number>>, param2:Array, param3:int = 0, param4:int = 1000):void
		{
			var _loc_6:int = 0;
			var _loc_5:* = param2[(param2.length - 1)];
			if (musicParser.totalSamples - _loc_5 < param4)
			{
				_loc_6 = _loc_5;
				while (_loc_6 < musicParser.totalSamples)
				{
					
					param1[_loc_6][param3] = 0;
					_loc_6++;
				}
			}
		}
		
		/**
		 * Experimental not currently used.
		 */
		private function calculateTempo(param1:int) : Number
		{
			var _loc_9:Number = NaN;
			var _loc_10:int = 0;
			var _loc_2:Array = new Array();
			var _loc_3:Number = 44100 / musicParser.sampleSize;
			var _loc_4:Number = _loc_3 * 10;
			var _loc_5:int = 0;
			var _loc_6:int = 0;
			var _loc_7:int = 0;
			while (_loc_7 < musicParser.totalSamples)
			{
				
				_loc_9 = 0;
				_loc_10 = 0;
				while (_loc_10 < _loc_4)
				{
					
					if (_loc_7 + _loc_10 > (musicParser.totalSamples - 1))
					{
						break;
					}
					if (beats[_loc_7 + _loc_10][param1] > 0)
					{
						_loc_6++;
						_loc_9 = _loc_9 + (_loc_7 + _loc_10 - _loc_5);
						_loc_5 = _loc_7 + _loc_10;
					}
					_loc_10++;
				}
				_loc_9 = _loc_9 / _loc_6;
				_loc_9 = _loc_9;
				_loc_2.push(_loc_9);
				_loc_7 = _loc_7 + _loc_4;
				_loc_7 = _loc_7 + 1;
			}
			var _loc_8:* = pruneBPM(_loc_2);
			return pruneBPM(_loc_2);
		}
		
		/**
		 * Experimental not currently used.
		 */
		private function pruneBPM(param1:Array) : int
		{
			var _loc_2:int = 0;
			var _loc_3:int = 0;
			var _loc_4:Number = 0;
			var _loc_5:int = 0;
			while (_loc_5 < param1.length)
			{
				
				if (param1[_loc_5] > 10)
				{
					_loc_4 = _loc_4 + param1[_loc_5];
					_loc_3++;
				}
				_loc_5++;
			}
			_loc_2 = _loc_4 / _loc_3;
			return _loc_2;
		}
		
		private function parseThresholdsForBeats(param1:Vector.<Vector.<Number>>, param2:int, param3:Vector.<Vector.<Number>>, param4:Vector.<Vector.<Number>>, param5:int) : int
		{
			var _loc_8:Number = NaN;
			var _loc_9:Number = NaN;
			var _loc_10:int = 0;
			var _loc_11:int = 0;
			var _loc_12:Number = NaN;
			var _loc_6:int = 0;
			var _loc_7:int = 0;
			while (_loc_7 < param4.length)
			{
				
				_loc_8 = 0;
				if (param3[_loc_7][param2] >= param4[_loc_7][param2] && param3[_loc_7][param2] > 900)
				{
					_loc_9 = param3[_loc_7][param2];
					_loc_10 = _loc_7;
					_loc_11 = 1;
					while (_loc_11 <= param5)
					{
						
						if (_loc_7 + _loc_11 > (param4.length - 1))
						{
							break;
						}
						_loc_12 = param3[_loc_7 + _loc_11][param2] > param4[_loc_7 + _loc_11][param2] ? (param3[_loc_7 + _loc_11][param2]) : (0);
						if (_loc_12 > _loc_9)
						{
							_loc_9 = _loc_12;
							_loc_10 = _loc_7 + _loc_11;
						}
						_loc_11++;
					}
					_loc_7 = _loc_7 + param5;
					param1[_loc_10][param2] = _loc_9;
					_loc_6++;
				}
				_loc_7++;
			}
			return _loc_6;
		}
		
		private function calculateSpectralFluxThresholds(param1:int, param2:Vector.<Vector.<Number>>) : void
		{
			var _loc_7:int = 0;
			var _loc_3:int = musicParser.totalSamples;
			var _loc_4:Number = 0;
			var _loc_5:Number = 1;
			var _loc_6:int = 0;
			while (_loc_6 < _loc_3)
			{
				
				_loc_4 = musicParser.spectralFluxWindows[_loc_6][param1];
				_loc_5 = 1;
				_loc_7 = 1;
				while (_loc_7 <= THRESHOLD_WINDOW_SIZE)
				{
					
					if (_loc_6 - _loc_7 > -1)
					{
						_loc_4 = _loc_4 + musicParser.spectralFluxWindows[_loc_6 - _loc_7][param1];
						_loc_5 = _loc_5 + 1;
					}
					_loc_7++;
				}
				_loc_7 = 1;
				while (_loc_7 <= THRESHOLD_WINDOW_SIZE)
				{
					
					if (_loc_6 + _loc_7 < musicParser.totalSamples)
					{
						_loc_4 = _loc_4 + musicParser.spectralFluxWindows[_loc_6 + _loc_7][param1];
						_loc_5 = _loc_5 + 1;
					}
					_loc_7++;
				}
				_loc_4 = _loc_4 / _loc_5;
				_loc_4 = _loc_4 * THRESHOLD_MULTIPLIER;
				param2[_loc_6][param1] = _loc_4;
				_loc_6++;
			}
		}
		
		private function calculateSections() : int
		{
			var _loc_6:int = 0;
			var _loc_7:int = 0;
			var _loc_1:Number = 0;
			var _loc_2:Number = 0;
			var _loc_3:Number = 0;
			var _loc_4:int = 0;
			var _loc_5:int = 0;
			while (_loc_5 < musicParser.totalSamples)
			{
				
				_loc_1 = 0;
				_loc_2 = 0;
				_loc_4 = 0;
				_loc_6 = 0;
				while (_loc_6 < SECTION_WINDOW_SIZE)
				{
					
					if (_loc_5 + _loc_6 > (musicParser.totalSamples - 1))
					{
						break;
					}
					_loc_1 = _loc_1 + musicParser.spectralFluxWindows[_loc_5 + _loc_6][SECTION_BAND];
					_loc_4++;
					_loc_6++;
				}
				_loc_2 = _loc_1 / _loc_4;
				if (_loc_2 > _loc_3 * SECTION_MULTIPLIER || _loc_2 < _loc_3 / SECTION_MULTIPLIER && _loc_2 > 20)
				{
					_loc_7 = _loc_5;
					sections.push(_loc_7);
					sectionsAverage.push(_loc_2);
					_loc_3 = _loc_2;
					if (debugMode)
					{
						;
					}
					_loc_2 = 0;
				}
				_loc_5 = _loc_5 + _loc_4;
				_loc_5 = _loc_5 + 1;
			}
			pruneSections(sections, sectionsAverage, 100);
			return sections.length;
		}
		
		/**
		 * For star sections
		 */
		private function calculateStarSections():void{
			var sectionAverages:Array = new Array();
			var sectionResult:Array = new Array();
			for(var i:int = 0; i < sections.length; i++){
				if(i+1 < sections.length){
					var sectionLength:int = sections[i+1] - sections[i];
					var sectionDifference:Number = 0;
					var sectionTotal:Number = 0;
					for(var s:int = 0; s < sectionLength-1; s++){
						sectionTotal += fluxThresholds[sections[i]+s][0];
						sectionDifference += fluxThresholds[sections[i]+(s+1)][0] - fluxThresholds[sections[i]+s][0];
					}
					var average:Object = new Object();
					average.sectionRef = i;
					average.sectionAverage = sectionTotal/sectionLength;
					sectionAverages.push(average);
					
					var result:Object = new Object();
					result.sectionRef = i;
					result.sectionAverage = sectionDifference;
					sectionResult.push(result);
				}
			}
			
			bubbleSort(sectionAverages);
			bubbleSort(sectionResult);
			
			var sectionScores:Array = new Array();
			
			for(i = 0; i < sectionAverages.length; i++){
				for(s = 0; s < sectionAverages.length; s++){
					if(sectionAverages[i].sectionRef == sectionResult[s].sectionRef && sectionAverages[i].sectionRef != 0){
						var sectionScore:Object = new Object();
						sectionScore.sectionRef = sectionAverages[i].sectionRef;
						sectionScore.score = i+s;
						sectionScores.push(sectionScore);
					}
				}
			}
			
			bubbleSortByScore(sectionScores);
			increaseScoreForDoubleStarSections(starSections);
			
			for(i = 0; i < Math.min(MAXIMUM_STAR_SECTIONS, sectionScores.length); i++){
				starSections.push(sectionScores[i].sectionRef);
			}
			
			trace("Completed Star rating sections");
		}
		
		/**
		 * For star sections
		 * Prevents there from being two star sections in a row
		 */
		private function increaseScoreForDoubleStarSections(starSections:Array):void{
			var currentStarsectionsMoved:int = 0;
			for(var i:int = 0; i < starSections.length; i++){
				for(var s:int = 1; s <= MAXIMUM_STAR_SECTIONS; s++){
					if(s < starSections.length){
						if(starSections[i].sectionRef+1 == starSections[i+s] || starSections[i].sectionRef-1 == starSections[i+s]){
							var section:Object = starSections.splice(i+s, 1);
							i--;
							break;
						}
					}
				}
			}
		}
		
		/**
		 * For star sections
		 */
		public function bubbleSortByScore(toSort:Array):Array
		{
			var changed:Boolean = false;
			
			while (!changed)
			{
				changed = true;
				
				for (var i:int = 0; i < toSort.length - 1; i++)
				{
					if (toSort[i].score > toSort[i + 1].score)
					{
						var tmp:Object = toSort[i];
						toSort[i] = toSort[i + 1];
						toSort[i + 1] = tmp;
						
						changed = false;
					}
				}
			}
			
			return toSort;
		}
		
		/**
		 * For star sections
		 */
		public function bubbleSort(toSort:Array):Array
		{
			var changed:Boolean = false;
			
			while (!changed)
			{
				changed = true;
				
				for (var i:int = 0; i < toSort.length - 1; i++)
				{
					if (toSort[i].sectionAverage < toSort[i + 1].sectionAverage)
					{
						var tmp:Object = toSort[i];
						toSort[i] = toSort[i + 1];
						toSort[i + 1] = tmp;
						
						changed = false;
					}
				}
			}
			
			return toSort;
		}
		
		
		private function pruneSections(param1:Array, param2:Array, param3:int = 100) : void
		{
			var _loc_4:int = 1;
			while (_loc_4 < param1.length)
			{
				
				if (param1[_loc_4] - param1[(_loc_4 - 1)] <= param3)
				{
					param1.splice((_loc_4 - 1), 1);
					param2.splice((_loc_4-1), 1);
					_loc_4 = _loc_4 - 1;
					if (debugMode)
					{
						;
					}
				}
				_loc_4++;
			}
		}
		
	}
}

