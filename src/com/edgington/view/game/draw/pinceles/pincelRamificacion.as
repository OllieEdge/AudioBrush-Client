package com.edgington.view.game.draw.pinceles
{

    public class pincelRamificacion extends Object implements BrushManager
    {
        private var frenazoPresion:Number;
        private var curvatura:Number = 0;
        private var presion:Number = 1;
        private var angulo:Number;
        private var pistasTrazo:Array;
        private var xPincel:Number;
        private var velocidad:Number;
        private var grosor:Number;
        private var offsetArmonico:Number;
        private var yPincel:Number;
        private var frenazoVelocidad:Number;
        private static const irregularidadVariable:Number = 0;
        private static const velocidadBasica:Number = 45;
        public static const elasticidadTrazo:Number = 1.1;
        private static const velocidadVariable:Number = 35;
        private static const grosorArmonico:Number = 0;
        private static const grosorVariable:Number = 4;
        public static const frenazoVelocidadBasico:Number = 0.3;
        public static const frenazoVelocidadVariable:Number = 0.2;
        private static const grosorBasico:Number = 2;
        private static const frenazoPresionVariable:Number = 0;
        private static const irregularidadBasica:Number = 1;
        private static const frenazoPresionBasico:Number = 1;

        public function pincelRamificacion(param1:Number, param2:Number, param3:stroke, param4:Number, param5:Number) : void
        {
            var _loc_6:Array = null;
            var _loc_7:int = 0;
            curvatura = 0;
            offsetArmonico = 100 * Math.random();
            presion = 1;
            this.xPincel = param1;
            this.yPincel = param2;
            if (param4)
            {
                this.angulo = param4;
            }
            this.grosor = pincelRamificacion.grosorBasico + pincelRamificacion.grosorVariable * param5;
            this.velocidad = this.grosor + pincelRamificacion.velocidadBasica + pincelRamificacion.velocidadVariable * param5;
            this.frenazoVelocidad = pincelRamificacion.frenazoVelocidadBasico + pincelRamificacion.frenazoVelocidadVariable * Math.random();
            this.frenazoPresion = pincelRamificacion.frenazoPresionBasico + pincelRamificacion.frenazoPresionVariable * Math.random();
            this.pistasTrazo = new Array();
            _loc_6 = Canvas.setup.sincronizacion.ramificaciones.toString().split(",");
            _loc_7 = 0;
            while (_loc_7 < _loc_6.length)
            {
                
                this.pistasTrazo.push(int(_loc_6[_loc_7]));
                _loc_7++;
            }
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
            this.presion = this.presion * this.frenazoPresion;
            this.velocidad = this.velocidad * this.frenazoVelocidad;
            if (this.velocidad < 1)
            {
                return null;
            }
            _loc_1 = new Brush();
            this.xPincel = this.xPincel + (this.velocidad * Math.cos(this.angulo) - Canvas.camarax);
            this.yPincel = this.yPincel + (this.velocidad * Math.sin(this.angulo) - Canvas.camaray);
            _loc_1.x = this.xPincel;
            _loc_1.y = this.yPincel;
            _loc_1.derrape = 0;
            _loc_1.presion = this.presion;
            _loc_2 = this.grosor;
            _loc_3 = _loc_2;
            _loc_4 = _loc_2;
            _loc_5 = Canvas.interpreter.trackVolume(this.pistasTrazo);
            _loc_6 = pincelRamificacion.irregularidadBasica + _loc_5 * pincelRamificacion.irregularidadVariable;
            _loc_3 = _loc_3 * (1 - _loc_6 + _loc_6 * Math.random());
            _loc_4 = _loc_4 * (1 - _loc_6 + _loc_6 * Math.random());
            _loc_1.arriba = _loc_3;
            _loc_1.abajo = _loc_4;
            _loc_1.elasticidadTrazo = pincelRamificacion.elasticidadTrazo;
            return _loc_1;
        }// end function

    }
}
