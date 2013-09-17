package com.edgington.model.audio.analysis
{
    import flash.display.*;

    public class VisualiseSound extends MovieClip
    {
		private  var xWidth:Number;
		private var xPos:Number = 0;
		private var gap:Number = 2;
		private var scale:Number = 1;
		private  var gfx:MovieClip;
		private  var gfxThreshold:MovieClip;
		private var flipY:Boolean = false;
		private var colour:int = 0xfcee21;

        public function VisualiseSound(param1:Number, param2:Number, param3:uint = 0xfcee21, param4:Boolean = false)
        {
            this.gfx = new MovieClip();
            this.gfxThreshold = new MovieClip();
            this.colour = param3;
            this.xWidth = param1;
            this.scale = param2;
            addChild(this.gfx);
            addChild(this.gfxThreshold);
            this.gfxThreshold.graphics.moveTo(this.xPos, 0);
            this.flipY = param4;
            return;
        }// end function

        public function Update(param1:Number, param2:Number = 0):void
        {
            param1 = param1 < 0 ? (0) : (param1);
            param1 = param1 * this.scale;
            param1 = param1 > 900 ? (900) : (param1);
            if (this.xPos > this.xWidth)
            {
                this.gfx.graphics.clear();
                this.gfxThreshold.graphics.clear();
                this.xPos = 0;
                this.gfxThreshold.graphics.moveTo(this.xPos, 0);
            }
            var _loc_3:* = new Vector.<int>(2);
            var _loc_4:* = new Vector.<int>(2);
            _loc_3[0] = this.xPos;
            _loc_3[1] = 0;
            _loc_4[0] = this.xPos;
            _loc_4[1] = !this.flipY ? (param1 * -1) : (param1);
            this.drawLine(_loc_3, _loc_4);
			if(param2 != 0){
            	this.drawThreshold(param2 * this.scale * -1);
			}
            this.xPos = this.xPos + this.gap;
        }// end function

        private function drawLine(param1:Vector.<int>, param2:Vector.<int>):void
        {
            this.gfx.graphics.lineStyle(1, this.colour);
            this.gfx.graphics.beginFill(this.colour);
            this.gfx.graphics.moveTo(param1[0], param1[1]);
            this.gfx.graphics.lineTo(param2[0], param2[1]);
            this.gfx.graphics.endFill();
        }// end function

        private function drawThreshold(param1:Number):void
        {
            this.gfxThreshold.graphics.lineStyle(2, this.colour);
            this.gfxThreshold.graphics.beginFill(this.colour);
            this.gfxThreshold.graphics.lineTo(this.xPos, param1);
            this.gfxThreshold.graphics.moveTo(this.xPos, param1);
            this.gfxThreshold.graphics.endFill();
        }// end function

        public function changeColour(param1:int):void
        {
            this.colour = param1;
        }// end function

    }
}
