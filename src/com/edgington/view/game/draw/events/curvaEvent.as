package com.edgington.view.game.draw.events
{
    import flash.events.*;

    public class curvaEvent extends Event
    {
        public var fuerza:Number;
        public var trayectoria:Number;

        public function curvaEvent(param1:String, param2:Number, param3:Number) : void
        {
            super(param1);
            this.trayectoria = param2;
            this.fuerza = param3;
            return;
        }// end function

    }
}
