package com.edgington.view.game.draw.pinceles
{
    import com.edgington.valueobjects.game.Brush;
    import com.edgington.valueobjects.game.stroke;
    import com.edgington.view.game.Canvas;
    import com.edgington.view.game.draw.Sketcher;
    import com.edgington.view.game.draw.interfaces.BrushManager;
    
    import flash.utils.getTimer;

    public class pincelSecundario extends Object implements BrushManager
    {
        private var inicio:Number;
        private var pistasTrazo:Array;
        private var actual:Brush;
        private var ref:stroke;
        private var vbase:Number;
        private var x:Number = 0;
        private var y:Number = 0;
        private static const velocidadBasica:Number = 0.1;
        private static const velocidadVariable:Number = 0.05;
        private static const grosorArmonico:Number = 0.2;
        private static const grosorVariable:Number = 0;
        public static const elasticidadTrazoMinima:Number = 1.1;
        private static const grosorBasico:Number = 0;
        private static const radioVariable:Number = 3;
        private static const radioBasico:Number = 0.5;
        public static const elasticidadTrazoVariable:Number = 0.3;
        private static const irregularidadBasica:Number = 0.6;
        private static const presionBasica:Number = 0;
        private static const irregularidadVariable:Number = 0;
        private static const presionVariable:Number = 1;

        public function pincelSecundario(param1:stroke) : void
        {
            var _loc_2:Array = null;
            var _loc_3:int = 0;
            x = 0;
            y = 0;
            this.inicio = getTimer() - 100000 * Math.random();
            this.ref = param1;
            this.vbase = 40 + 20 * Math.random();
        }

        public function get actualBrush() : Brush
        {
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
			var _loc_1:Brush = new Brush();
            _loc_2 = Canvas.interpreter.trackVolume();
            _loc_3 = this.ref.trayectoria + Math.PI / 4;
            _loc_4 = pincelSecundario.velocidadBasica + _loc_2 * pincelSecundario.velocidadVariable;
            this.inicio = this.inicio + _loc_4;
            _loc_5 = this.ref.thickness / 2 + pincelSecundario.radioBasico + _loc_2 * pincelSecundario.radioVariable;
            _loc_6 = this.ref.ultimoX + _loc_5 * Math.cos(this.inicio);
            _loc_7 = this.ref.ultimoY + _loc_5 * Math.sin(this.inicio);
            this.x = this.x + (_loc_6 - this.x) / 1;
            this.y = this.y + (_loc_7 - this.y) / 1;
            _loc_1.x = this.x;
            _loc_1.y = this.y;
            _loc_8 = pincelSecundario.grosorBasico + _loc_2 * pincelSecundario.grosorVariable;
            _loc_9 = Canvas.interpreter.trackVolume();
            _loc_1.pressure = pincelSecundario.presionBasica + _loc_2 * pincelSecundario.presionVariable;
            _loc_10 = pincelSecundario.irregularidadBasica + _loc_9 * pincelSecundario.irregularidadVariable;
            _loc_8 = _loc_8 + pincelSecundario.grosorArmonico * Sketcher.applyHarmonics(2) * _loc_10;
            _loc_1.up = _loc_8;
            _loc_1.down = _loc_8;
            _loc_11 = Canvas.interpreter.trackVolume();
            _loc_1.strokeElasticity = pincelSecundario.elasticidadTrazoMinima + _loc_11 * pincelSecundario.elasticidadTrazoVariable;
            return _loc_1;
        }// end function

    }
}
