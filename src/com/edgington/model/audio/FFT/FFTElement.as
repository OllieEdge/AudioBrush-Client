package com.edgington.model.audio.FFT
{

    public class FFTElement
    {
        public var re:Number = 0;
        public var im:Number = 0;
        public var next:FFTElement = null;
        public var revTgt:uint;
    }
}
