package com.edgington.view.game.draw.pinceles
{
    import flash.events.*;
    import flash.utils.*;

    public class pincelClimax extends Object implements BrushManager
    {
        private var actual:Brush;
        private var ref:stroke;
        private var vbase:Number;
        private var presion:Number = 1;
        private var muriendo:Object = false;
        private var amplitud:Number;
        private var inicio:Number;
        private var pistasTrazo:Array;
        private var velocidad:Number;
        private var x:Number = 0;
        private var y:Number = 0;
        private var vida:Timer;
        private static const velocidadBasica:Number = 10;
        private static const velocidadVariable:Number = 10;
        private static const grosorArmonico:Number = 0.5;
        private static const grosorVariable:Number = 0;
        public static const elasticidadTrazoMinima:Number = 1.1;
        private static const grosorBasico:Number = 0;
        private static const radioVariable:Number = 10;
        private static const radioBasico:Number = 25;
        public static const elasticidadTrazoVariable:Number = 0;
        private static const irregularidadBasica:Number = 0.6;
        private static const presionBasica:Number = 0;
        private static const irregularidadVariable:Number = 0;
        private static const presionVariable:Number = 1;

        public function pincelClimax(param1:stroke, param2:int) : void
        {
            var _loc_3:Array = null;
            var _loc_4:int = 0;
            x = 0;
            y = 0;
            muriendo = false;
            presion = 1;
            this.inicio = getTimer() - 2000 * Math.random();
            this.ref = param1;
            this.vbase = 40 + 20 * Math.random();
            this.pistasTrazo = new Array();
            _loc_3 = Canvas.setup.sincronizacion.secundario.toString().split(",");
            _loc_4 = 0;
            while (_loc_4 < _loc_3.length)
            {
                
                this.pistasTrazo.push(int(_loc_3[_loc_4]));
                _loc_4++;
            }
            this.vida = new Timer(param2 * 1000, 1);
            this.vida.addEventListener(TimerEvent.TIMER_COMPLETE, this.muerte);
            this.vida.start();
            this.amplitud = pincelClimax.radioBasico + pincelClimax.radioVariable * Math.random();
            this.velocidad = pincelClimax.velocidadBasica + pincelClimax.velocidadVariable * Math.random();
            return;
        }// end function

        public function get actualBrush() : Brush
        {
            var _loc_1:* = undefined;
            var _loc_2:Number = NaN;
            var _loc_3:Number = NaN;
            var _loc_4:Number = NaN;
            var _loc_5:Number = NaN;
            var _loc_6:Number = NaN;
            var _loc_7:Number = NaN;
            var _loc_8:Number = NaN;
            var _loc_9:Number = NaN;
            var _loc_10:Number = NaN;
            var _loc_11:Number = NaN;
            var _loc_12:Number = NaN;
            _loc_1 = new Brush();
            if (this.muriendo)
            {
                this.presion = this.presion * 0.9;
            }
            if (this.presion < 0.1)
            {
                return null;
            }
            _loc_1.derrape = 0.1;
            _loc_2 = Canvas.interpreter.trackVolume(this.pistasTrazo);
            _loc_3 = this.ref.trayectoria + Math.PI / 4;
            _loc_4 = pincelClimax.velocidadBasica + _loc_2 * pincelClimax.velocidadVariable;
            this.inicio = this.inicio + _loc_4;
            _loc_5 = (getTimer() - this.inicio) / this.velocidad;
            _loc_6 = (getTimer() - this.inicio) / (this.velocidad + 20);
            _loc_7 = this.ref.ultimoX + this.amplitud / 3 * Math.cos(_loc_5);
            _loc_8 = this.ref.ultimoY + this.amplitud * Math.sin(_loc_6);
            this.x = this.x + (_loc_7 - this.x) / 2;
            this.y = this.y + (_loc_8 - this.y) / 2;
            _loc_1.x = this.x;
            _loc_1.y = this.y;
            _loc_9 = pincelClimax.grosorBasico + _loc_2 * pincelClimax.grosorVariable;
            _loc_10 = Canvas.interpreter.trackVolume(this.pistasTrazo);
            _loc_1.presion = this.presion;
            _loc_11 = pincelClimax.irregularidadBasica + _loc_10 * pincelClimax.irregularidadVariable;
            _loc_9 = _loc_9 + pincelClimax.grosorArmonico * Sketcher.applyHarmonics(4, 0, 2) * _loc_11;
            _loc_1.arriba = _loc_9;
            _loc_1.abajo = _loc_9;
            _loc_12 = Canvas.interpreter.trackVolume([0]);
            _loc_1.elasticidadTrazo = pincelClimax.elasticidadTrazoMinima + _loc_12 * pincelClimax.elasticidadTrazoVariable;
            return _loc_1;
        }// end function

        private function muerte(event:Event) : void
        {
            this.muriendo = true;
            trace("Muerte");
            return;
        }// end function

    }
}
