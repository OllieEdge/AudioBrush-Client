package com.edgington.model.audio.analysis
{
    import flash.events.*;

    public class MusicEvent extends Event
    {
        public var amplitude:Number = 0;
        public var frequencyBand:Number = 0;
        public var percentageParsed:Number = 0;
        public var percentageAnalysed:Number = 0;
        public var tempo:Number = 0;
        public static const ON_PARSER_PROGRESS:String = "onParserProgress";
        public static const ON_ANALYSER_PROGRESS:String = "onAnalyserProgress";
        public static const ON_BEAT:String = "onBeat";
        public static const ON_TEMPO_CHANGE:String = "onTempoChange";
        public static const ON_MOOD_TRANSISTION:String = "onMoodTransistion";

        public function MusicEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
        {
            super(param1, param2, param3);
            return;
        }// end function

    }
}
