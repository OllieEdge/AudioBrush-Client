package com.edgington.valueobjects.game
{

    public class Brush extends Object
    {
        public var down:Number = 0;
        public var strokeElasticity:Number = 1;
        public var yaw:Number;
        public var up:Number = 0;
        public var x:Number = 0;
        public var y:Number = 0;
        public var pressure:Number = 1;

        public function Brush()
        {
            x = 0;
            y = 0;
            pressure = 1;
            up = 0;
            down = 0;
            strokeElasticity = 1;
            yaw = stroke.derrapaje;
            return;
        }// end function

    }
}
