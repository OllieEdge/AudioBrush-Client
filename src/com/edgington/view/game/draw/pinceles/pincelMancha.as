package com.edgington.view.game.draw.pinceles
{

    public class pincelMancha extends Object implements BrushManager
    {
        private var frenazoPresion:Number;
        private var presion:Number = 1;
        private var curvatura:Number = 0;
        private var angulo:Number;
        private var xPincel:Number;
        private var velocidad:Number;
        private var grosor:Number;
        private var offsetArmonico:Number;
        private var yPincel:Number;
        private var frenazoVelocidad:Number;
        private static const velocidadBasica:Number = 0.5;
        public static const elasticidadTrazo:Number = 1.2;
        private static const velocidadVariable:Number = 1;
        private static const grosorVariable:Number = 5;
        public static const frenazoVelocidadBasico:Number = 0.85;
        public static const frenazoVelocidadVariable:Number = 0.02;
        private static const grosorBasico:Number = 8;
        private static const frenazoPresionVariable:Number = 0.05;
        private static const frenazoPresionBasico:Number = 0.8;
        private static const irregularidadArmonica:Number = 18;

        public function pincelMancha(param1:stroke, param2:Number = 0, param3:Number = 0) : void
        {
            curvatura = 0;
            offsetArmonico = 100 * Math.random();
            presion = 1;
            this.xPincel = param1.ultimoX;
            this.yPincel = param1.ultimoY;
            if (param3)
            {
                this.angulo = param3;
            }
            else
            {
                this.angulo = param1.trayectoria;
            }
            if (Math.random() < 0.5)
            {
                this.angulo = this.angulo + Math.PI / 8;
            }
            else
            {
                this.angulo = this.angulo - Math.PI / 8;
            }
            this.grosor = param2 || param1.thickness;
            this.velocidad = this.grosor + pincelMancha.velocidadBasica + pincelMancha.velocidadVariable * Math.random();
            this.frenazoVelocidad = pincelMancha.frenazoVelocidadBasico + pincelMancha.frenazoVelocidadVariable * Math.random();
            this.frenazoPresion = pincelMancha.frenazoPresionBasico + pincelMancha.frenazoPresionVariable * Math.random();
            if (Math.random())
            {
                this.curvatura = 0.5 + 0.2 * Math.random();
            }
            else
            {
                this.curvatura = -0.5 - 0.2 * Math.random();
            }
            return;
        }// end function

        public function get actualBrush() : Brush
        {
            var _loc_1:* = undefined;
            var _loc_2:Number = NaN;
            this.presion = this.presion * this.frenazoPresion;
            this.velocidad = this.velocidad * this.frenazoVelocidad;
            this.angulo = this.angulo + this.curvatura;
            if (Math.random() < 0.15)
            {
                this.curvatura = this.curvatura * -1;
            }
            if (this.presion < 0.1 && this.velocidad < 1)
            {
                return null;
            }
            _loc_1 = new Brush();
            this.xPincel = this.xPincel + (this.velocidad * 1.5 * Math.cos(this.angulo) - Canvas.camarax);
            this.yPincel = this.yPincel + (this.velocidad * Math.sin(this.angulo) - Canvas.camaray);
            _loc_1.x = this.xPincel;
            _loc_1.y = this.yPincel;
            _loc_1.presion = this.presion;
            _loc_2 = this.grosor + pincelMancha.irregularidadArmonica * Sketcher.applyHarmonics(3, this.offsetArmonico);
            _loc_1.arriba = _loc_2;
            _loc_1.abajo = _loc_2;
            _loc_1.elasticidadTrazo = pincelMancha.elasticidadTrazo;
            return _loc_1;
        }// end function

    }
}
