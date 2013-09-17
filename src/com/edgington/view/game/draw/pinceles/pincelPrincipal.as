package com.edgington.view.game.draw.pinceles
{
    import com.edgington.valueobjects.game.Brush;
    import com.edgington.view.game.Canvas;
    import com.edgington.view.game.draw.Sketcher;
    import com.edgington.view.game.draw.interfaces.BrushManager;
    
    import flash.utils.getTimer;

    public class pincelPrincipal extends Object implements BrushManager
    {
        private var inicio:Number;
        private var pistasTrazo:Array;
        private var actual:Brush;
        private var xAnt:Number;
        private var yAnt:Number;
        private var pressure:Number = 0.6;
        public static const variableStrokeElasticity:Number = 0;
        private static const minimumPressure:Number = 0.6;
        private static const basicIrregularity:Number = 0.1;
        private static const harmonicThickness:Number = 12;
        private static const variableThickness:Number = 35;
        public static const elasticidadTrazoMinima:Number = 1.3;
        private static const presionMaxima:Number = 1;
        private static const basicThickness:Number = 1;
        private static const variableIrregularity:Number = 0.4;

		private var brush:Brush;
		
        public function pincelPrincipal() : void
        {
            var _loc_1:Array = null;
            var _loc_2:int = 0;
            pressure = pincelPrincipal.minimumPressure;
            this.inicio = getTimer();
        }

        public function get actualBrush() : Brush
        {
            var trackVolume:Number = NaN;
            var _loc_3:Number = NaN;
            var _loc_4:Number = NaN;
            var _loc_5:Number = NaN;
            var _loc_7:Number = NaN;
            var _loc_9:Number = NaN;
            var _loc_10:Number = NaN;
            var _loc_11:Number = NaN;
			brush = new Brush();

            _loc_9 = Canvas.mouseX;
            _loc_10 = Canvas.mouseY;

            Canvas.referenciaX = Canvas.mouseX;
            Canvas.referenciaY = Canvas.mouseY;

            brush.x = _loc_9;
            this.xAnt = _loc_9;
            brush.y = _loc_10;
            this.yAnt = _loc_10;

            brush.pressure = this.pressure;
			
            trackVolume = Canvas.interpreter.trackVolume();
			
            _loc_3 = pincelPrincipal.basicThickness + trackVolume * pincelPrincipal.variableThickness;
            _loc_4 = pincelPrincipal.basicThickness + trackVolume * (pincelPrincipal.variableThickness + pincelPrincipal.harmonicThickness * Sketcher.applyHarmonics(2));
            _loc_5 = pincelPrincipal.basicThickness + trackVolume * (pincelPrincipal.variableThickness + pincelPrincipal.harmonicThickness * Sketcher.applyHarmonics(2, 250));
			
            _loc_7 = pincelPrincipal.basicIrregularity + trackVolume * pincelPrincipal.variableIrregularity;
			
            _loc_4 *= (1 - _loc_7 + _loc_7 * Math.random());
            _loc_5 *= (1 - _loc_7 + _loc_7 * Math.random());
			
            brush.up = _loc_4;
            brush.down = _loc_5;
            brush.strokeElasticity = pincelPrincipal.elasticidadTrazoMinima + trackVolume * pincelPrincipal.variableStrokeElasticity;
            return brush;
        }

    }
}
