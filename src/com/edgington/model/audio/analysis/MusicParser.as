package com.edgington.model.audio.analysis
{
    import com.edgington.model.audio.FFT.FFT;
    
    import flash.events.EventDispatcher;
    import flash.media.Sound;
    import flash.utils.ByteArray;
    
    import __AS3__.vec.Vector;

    public class MusicParser extends EventDispatcher
    {
        private var debugMode:Boolean = false;
        public var sampleSize:int = 1024;
        private var logN:int = 10;
        private var highestAmplitude:Number = 0;
        public var music:Sound;
        private var rawBytes:Vector.<Number>;
        private var FFTBytes:Vector.<Number>;
        private var frequencyBand:Vector.<Number>;
        private var spectralFlux:Vector.<Number>;
        public var fftWindows:Vector.<Vector.<Number>>;
        public var frequencyBandWindows:Vector.<Vector.<Number>>;
        public var spectralFluxWindows:Vector.<Vector.<Number>>;
        private var percentCompleted:int = 0;
        public var octaveList:Array;
        public var totalSamples:int;
        private var parseSampleCount:int = 0;
        private var lastSeen:int = 0;
		
		private var FFTHolder:FFT  = new FFT();
		private var FFTConcatVector:Vector.<Number>;
		private var FFTOutputVector:Vector.<Number>;
		
		private var calculateBandsOctelist:Vector.<Number>;
		
		private  var byteArray:ByteArray = new ByteArray();
		
		
        public function MusicParser(param1:Sound)
        {
            this.music = new Sound();
            this.music = param1;
            this.totalSamples = Math.floor(param1.length * 44.1 / this.sampleSize);

            this.rawBytes = new Vector.<Number>(this.sampleSize, true);
            this.FFTBytes = new Vector.<Number>(this.sampleSize / 2, true);
            this.octaveList = new Array(1);
            this.octaveList[0] = [0, 3];
            this.octaveList[1] = [3, 7];
            //this.octaveList[2] = [50, 90];
            //this.octaveList[3] = [90, 512];
            //this.octaveList[4] = [300, 400];
            //this.octaveList[5] = [0, 512];
            this.frequencyBand = new Vector.<Number>(this.octaveList.length, true);
            this.spectralFlux = new Vector.<Number>(this.octaveList.length, true);
            this.fftWindows = new Vector.<Vector.<Number>>(this.totalSamples, true);
			for(var i:int = 0; i < fftWindows.length; i++){
				fftWindows[i] = new Vector.<Number>(sampleSize*.5);
			}
            this.frequencyBandWindows = new Vector.<Vector.<Number>>(this.totalSamples, true);
            this.spectralFluxWindows = new Vector.<Vector.<Number>>(this.totalSamples, true);
            return;
        }// end function

		/**
		 * Call this until it returns true to analyse whole track
		 */
        public function parseMusic() : Boolean
        {
            if (this.parseSampleCount >= this.totalSamples)
            {
                this.highestAmplitude = this.calculateHighestAmplitude(0);
				
                return true;
            }
			
			for(var i:int = 0; i < 20; i++){
                if (this.parseSampleCount + i >= this.totalSamples)
                {
                    break;
                }
                this.parse(this.parseSampleCount + i);
            }
			
            this.dispatchProgress(this.parseSampleCount / this.totalSamples);
            this.parseSampleCount = this.parseSampleCount + 20;
            return false;
        }// end function

        private function dispatchProgress(param1:Number) : void
        {
            var event:MusicEvent = new MusicEvent("onParserProgress");
            event.percentageParsed = param1;
            dispatchEvent(event);
            return;
        }// end function

        private function parse(sampleCount:int) : void
        {
            //var _loc_2:int = sampleCount << 10;// this.sampleSize;
			if(byteArray == null){
				byteArray = new ByteArray();
			}
            byteArray.position = 0;
            this.music.extract(byteArray, this.sampleSize, sampleCount << 10);
			byteArray.position = 0;
			for(var i:int = 0; i < byteArray.length >> 3; i++){
                this.rawBytes[i] = byteArray.readFloat();
            }
            this.runHannWindow();
            this.FFTBytes = this.runFFT();
            this.frequencyBand = this.calculateBands();
            this.spectralFlux = this.calculateBandsSpectralFlux(sampleCount);
            this.addToWindows(sampleCount, this.FFTBytes, this.frequencyBand, this.spectralFlux);
        }// end function

        private function runHannWindow():void
        {
			for(var i:int = 0; i < sampleSize; i++){
				rawBytes[i] = (0.5 * (1 - Math.cos(2 * Math.PI * i / sampleSize))) * rawBytes[i];
            }
        }// end function

		private var iterator1:int = 0;
		private var fftBytes:Vector.<Number>
		
        private function runFFT() : Vector.<Number>
        {
			if(fftBytes == null){
				fftBytes = new Vector.<Number>(rawBytes.length / 2);	
			}
			FFTConcatVector = rawBytes.concat();
			FFTOutputVector = new Vector.<Number>(rawBytes.length);
			FFTHolder.init(logN);
			FFTHolder.run(FFTConcatVector, FFTOutputVector, false);
            var rawBytesLength:int = rawBytes.length >> 1;
			for(iterator1 = 0; iterator1 < rawBytesLength; iterator1++){
				fftBytes[iterator1] = (FFTConcatVector[iterator1]*FFTConcatVector[iterator1] + FFTOutputVector[iterator1]*FFTOutputVector[iterator1] + (FFTConcatVector[511 - iterator1]*FFTConcatVector[511 - iterator1] + FFTOutputVector[511 - iterator1]*FFTOutputVector[511 - iterator1])) *.5;
			}
            return fftBytes;
        }// end function

        private function calculateBands() : Vector.<Number>
        {
			calculateBandsOctelist = new Vector.<Number>(octaveList.length);
			for(var i:int = 0; i < octaveList.length; i++){
				calculateBandsOctelist[i] = this.calculateBandAverage(FFTBytes, octaveList[i]);
			}
            return calculateBandsOctelist;
        }// end function

        private function calculateBandAverage(param1:Vector.<Number>, param2:Array) : Number
        {
            var _loc_3:Number = 0;
            var _loc_4:Array = param2;
            var _loc_5:int = param2[0];
            while (_loc_5 < _loc_4[1])
            {
                
                _loc_3 = _loc_3 + param1[_loc_5];
                _loc_5++;
            }
            _loc_3 = _loc_3 / (_loc_4[1] - _loc_4[0]);
            return _loc_3;
        }// end function

        private function calculateBandsSpectralFlux(sampleCount:int) : Vector.<Number>
        {
			calculateBandsOctelist = new Vector.<Number>(octaveList.length, true);
			for(var i:int = 0; i < octaveList.length; i++){
                if (sampleCount < 1)
                {
					calculateBandsOctelist[i] = 0;
                    break;
                }
				calculateBandsOctelist[i] = this.calculateSpectralFlux(fftWindows[(sampleCount - 1)], octaveList[i]);
            }
            return calculateBandsOctelist;
        }// end function

        private function calculateSpectralFlux(fftWindow:Vector.<Number>, octave:Array) : Number
        {
            var _loc_6:Number = NaN;
            var _loc_4:Number = 0;
            var _loc_5:int = octave[0];
            while (_loc_5 < octave[1])
            {
                _loc_6 = FFTBytes[_loc_5] - fftWindow[_loc_5];
                _loc_4 = _loc_4 + (_loc_6 < 0 ? (0) : (_loc_6));
                _loc_5++;
            }
            return _loc_4;
        }// end function

        private function addToWindows(param1:int, param2:Vector.<Number>, param3:Vector.<Number>, param4:Vector.<Number>) : void
        {
            this.fftWindows[param1] = param2.concat();
            this.frequencyBandWindows[param1] = param3;
            this.spectralFluxWindows[param1] = param4;
			param2 = null;
			param3 = null;
			param4 = null;
            return;
        }// end function

        private function calculateHighestAmplitude(param1:int) : Number
        {
            var _loc_2:Number = 0;
            var _loc_3:int = 0;
            while (_loc_3 < this.totalSamples)
            {
                
                _loc_2 = this.frequencyBandWindows[_loc_3][param1] > _loc_2 ? (this.frequencyBandWindows[_loc_3][param1]) : (_loc_2);
                _loc_3++;
            }
            return _loc_2;
        }// end function

        public function getNextWindow(param1:Number, param2:Boolean = true) : int
        {
            var _loc_6:int = 0;
            var _loc_3:int = Math.ceil(param1 * 44.1 / this.sampleSize);
            var _loc_4:int = _loc_3;
            if (_loc_3 > (this.totalSamples - 1))
            {
                return -1;
            }
            if (_loc_4 == this.lastSeen && param2)
            {
                return -1;
            }
            var _loc_5:* = _loc_4 - this.lastSeen;
            if (_loc_4 - this.lastSeen > 1)
            {
                _loc_4 = this.lastSeen + 1;
                _loc_6 = _loc_3 - _loc_4;
                if (_loc_6 > 5)
                {
                    _loc_4 = _loc_3;
                }
            }
            this.lastSeen = _loc_4;
            return _loc_4;
        }// end function

		public function destroy():void{
			
			rawBytes = new Vector.<Number>;
			FFTBytes = new Vector.<Number>;
			frequencyBand = new Vector.<Number>;
			spectralFlux = new Vector.<Number>;
			fftWindows = new Vector.<Vector.<Number>>;
			frequencyBandWindows = new Vector.<Vector.<Number>>;
			spectralFluxWindows = new Vector.<Vector.<Number>>;
			FFTHolder = new FFT();
			FFTConcatVector = new Vector.<Number>;
			FFTOutputVector = new Vector.<Number>;
			calculateBandsOctelist = new Vector.<Number>;
			music = null;
			
			rawBytes = null;
			FFTBytes = null;
			frequencyBand = null;
			spectralFlux = null
			fftWindows = null;
			frequencyBandWindows = null;
			spectralFluxWindows = null;
			FFTHolder = null;
			FFTConcatVector = null;
			FFTOutputVector = null;
			calculateBandsOctelist = null;
			music = null;
		}
		
    }
	
	
}
