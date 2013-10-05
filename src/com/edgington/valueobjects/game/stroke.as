package com.edgington.valueobjects.game
{
    import com.edgington.constants.CanvasConstants;
    import com.edgington.constants.Constants;
    import com.edgington.constants.DynamicConstants;
    import com.edgington.model.GameProxy;
    import com.edgington.types.DeviceTypes;
    import com.edgington.view.assets.AssetLoader;
    import com.edgington.view.game.Canvas;
    import com.edgington.view.game.draw.Sketcher;
    import com.edgington.view.game.draw.events.curvaEvent;
    import com.edgington.view.game.draw.interfaces.BrushManager;
    import com.edgington.view.game.draw.pinceles.pincelPrincipal2;
    
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.geom.Matrix;
    import flash.geom.Point;

    public class stroke extends EventDispatcher
    {
        private var yPrevious1:Number = 0;
        private var yPrevious2:Number = 0;
        private var ultimoY2Int:Number = 0;
        private var ultimoX2_A:Number = 0;
        private var xAnterior2_A:Number = 0;
        private var ultimoX1Int:Number = 0;
        public var ultimoX:Number = 0;
        public var ultimoY:Number = 0;
        public var tinta2:BitmapData;
        private var yAnterior2Int:Number = 0;
        private var xAnterior2Int_A:Number = 0;
        public var thickness:Number = 0;
        public var separacionReal:Number = 0;
        private var ultimoY1Int_A:Number = 0;
        public var enabled:Boolean = true;
        public var tinta1:BitmapData;
        private var ultimoX1_A:Number = 0;
        private var ultimoX1:Number = 0;
        private var ultimoX2:Number = 0;
        private var xAnterior:Number = 0;
        private var angulo1:Number = 1.5708;
        public var velocidadTotal:Number = 0;
        private var yAnterior:Number = 0;
        private var xAnterior1Int:Number = 0;
        private var xAnterior1_A:Number = 0;
        private var ultimoY1:Number = 0;
        private var ultimoY2:Number = 0;
        private var ultimoY2_A:Number = 0;
        private var yAnterior2Int_A:Number = 0;
        private var angulo2:Number = 4.71239;
        public var v1:Point;
        public var v2:Point;
        private var yAnterior2_A:Number = 0;
        private var ultimoX2Int:Number = 0;
        private var desviacion:Number = 0;
        private var ultimoX2Int_A:Number = 0;
        private var brushManager:BrushManager;
        private var xAnterior1Int_A:Number = 0;
        private var ultimoY1_A:Number = 0;
        private var ultimoY1Int:Number = 0;
        private var xAnterior2Int:Number = 0;
        public var transformTinta:Matrix;
        private var vx:Number = 0;
        private var vy:Number = 0;
        private var ultimoY2Int_A:Number = 0;
        private var yAnterior1Int:Number = 0;
        private var yAnterior1_A:Number = 0;
        private var yAnterior1Int_A:Number = 0;
        public var trayectoria:Number = 0;
        private var xAnterior1:Number = 0;
        private var xAnterior2:Number = 0;
        private var ultimoX1Int_A:Number = 0;
        private var derrape:Number = 0;
        public var separacion:Number = 0;
        private var primero:Boolean = true;
        public static const minDistanciaTrazo:Number = 0;
        public static var maxDistanciaTrazo:Number = 53;
        public static const derrapaje:Number = 1.2;
		
		private var _loc_3:Number = NaN;
		private var _loc_4:Number = NaN;
		private var _loc_5:Number = NaN;
		private var _loc_6:Number = NaN;
		private var _loc_7:Number = NaN;
		private var _loc_8:Number = NaN;
		private var _loc_9:Number = NaN;
		private var _loc_10:Number = NaN;
		private var _loc_11:Number = NaN;
		private var _loc_12:Number = NaN;
		private var _loc_13:Number = NaN;
		private var _loc_14:Number = NaN;
		private var _loc_15:Number = NaN;
		private var _loc_16:Number = NaN;
		private var _loc_17:Number = NaN;
		private var _loc_18:Number = NaN;
		private var _loc_19:Number = NaN;
		private var _loc_20:Number = NaN;
		private var _loc_21:Number = NaN;
		private var _loc_22:Number = NaN;
		private var _loc_23:Number = NaN;
		private var _loc_24:Number = NaN;
		private var _loc_25:Number = NaN;
		private var _loc_26:Number = NaN;
		private var _loc_27:Number = NaN;
		private var _loc_28:Number = NaN;
		private var _loc_29:Number = NaN;
		private var _loc_30:Number = NaN;
		private var _loc_31:Number = NaN;
		private var _loc_32:Number = NaN;
		private var _loc_33:Number = NaN;
		private var _loc_34:Number = NaN;
		private var _loc_35:* = undefined;
		private var _loc_36:* = undefined;
		private var _loc_37:Number = NaN;
		private var _loc_38:Number = NaN;
		private var _loc_39:Number = NaN;
		private var _loc_40:Number = NaN;
		private var _loc_41:Number = NaN;
		private var _loc_42:Number = NaN;
		private var _loc_43:Number = NaN;
		private var _loc_44:Number = NaN;
		private var _loc_45:Number = NaN;
		private var _loc_46:Number = NaN;
		private var _loc_47:Number = NaN;
		private var _loc_48:Number = NaN;
		private var _loc_49:Number = NaN;

        public function stroke(param1:Number, param2:Number, param3:BrushManager, param4:BitmapData = null, param5:BitmapData = null, param6:Matrix = null) : void
        {
			if(DynamicConstants.DEVICE_NAME == Constants.IPAD_4PLUS || DynamicConstants.DEVICE_NAME == Constants.ANDROID_XXL || DynamicConstants.DEVICE_NAME == Constants.ANDROID_XXLDPI){
				maxDistanciaTrazo = 106;
			}
			else{
				maxDistanciaTrazo = 53;
			}
            trayectoria = 0;
            velocidadTotal = 0;
            thickness = 0;
            enabled = true;
            derrape = 0;
            desviacion = 0;
            vx = 0;
            vy = 0;
            primero = true;
            separacion = 0;
            separacionReal = 0;
            v1 = new Point();
            v2 = new Point();
            ultimoX = 0;
            ultimoY = 0;
            xAnterior = 0;
            yAnterior = 0;
            xAnterior1 = 0;
            yPrevious1 = 0;
            ultimoX1 = 0;
            ultimoY1 = 0;
            xAnterior1Int = 0;
            yAnterior1Int = 0;
            ultimoX1Int = 0;
            ultimoY1Int = 0;
            xAnterior1_A = 0;
            yAnterior1_A = 0;
            ultimoX1_A = 0;
            ultimoY1_A = 0;
            ultimoX1Int_A = 0;
            ultimoY1Int_A = 0;
            xAnterior1Int_A = 0;
            yAnterior1Int_A = 0;
            xAnterior2 = 0;
            yPrevious2 = 0;
            ultimoX2 = 0;
            ultimoY2 = 0;
            xAnterior2Int = 0;
            yAnterior2Int = 0;
            ultimoX2Int = 0;
            ultimoY2Int = 0;
            xAnterior2_A = 0;
            yAnterior2_A = 0;
            ultimoX2_A = 0;
            ultimoY2_A = 0;
            ultimoX2Int_A = 0;
            ultimoY2Int_A = 0;
            xAnterior2Int_A = 0;
            yAnterior2Int_A = 0;
            angulo1 = Math.PI / 2;
            angulo2 = 3 * Math.PI / 2;
            this.brushManager = param3;
            this.transformTinta = param6 || new Matrix();
            this.tinta1 = param4 || AssetLoader.imageDictionary["gameBackground"];
            this.tinta2 = param5 || AssetLoader.imageDictionary["gameStarBackground"];
            this.moveTo(param1, param2);
            return;
        }// end function

        public function moveTo(param1:Number, param2:Number) : void
        {
            this.ultimoX = param1;
            this.ultimoY = param2;
            this.xAnterior = param1;
            this.yAnterior = param2;
            this.xAnterior1 = param1;
            this.yPrevious1 = param2;
            this.ultimoX1 = param1;
            this.ultimoY1 = param2;
            this.xAnterior1Int = param1;
            this.yAnterior1Int = param2;
            this.ultimoX1Int = param1;
            this.ultimoY1Int = param2;
            this.xAnterior1_A = param1;
            this.yAnterior1_A = param2;
            this.ultimoX1_A = param1;
            this.ultimoY1_A = param2;
            this.xAnterior1Int_A = param1;
            this.yAnterior1Int_A = param2;
            this.ultimoX1Int_A = param1;
            this.ultimoY1Int_A = param2;
            this.xAnterior2 = param1;
            this.yPrevious2 = param2;
            this.ultimoX2 = param1;
            this.ultimoY2 = param2;
            this.xAnterior2Int = param1;
            this.yAnterior2Int = param2;
            this.ultimoX2Int = param1;
            this.ultimoY2Int = param2;
            this.xAnterior2_A = param1;
            this.yAnterior2_A = param2;
            this.ultimoX2_A = param1;
            this.ultimoY2_A = param2;
            this.xAnterior2Int_A = param1;
            this.yAnterior2Int_A = param2;
            this.ultimoX2Int_A = param1;
            this.ultimoY2Int_A = param2;
        }

        public function tick() : void
        {
            this.transformTinta.translate(-Canvas.camarax, -Canvas.camaray);
            if (this.transformTinta.tx < -3000)
            {
                this.transformTinta.tx = this.transformTinta.tx + 3000;
            }
            if (this.transformTinta.ty < -3000)
            {
                this.transformTinta.ty = this.transformTinta.ty + 3000;
            }
            if (this.transformTinta.ty > 3000)
            {
                this.transformTinta.ty = this.transformTinta.ty - 3000;
            }
            if (this.separacionReal < this.separacion)
            {
                this.separacionReal = this.separacionReal + 3;
            }
            if (this.separacionReal > this.separacion)
            {
                this.separacionReal = this.separacionReal - 2;
            }
            this.ultimoX = this.ultimoX - Canvas.camarax;
            this.ultimoY = this.ultimoY - Canvas.camaray;
            this.xAnterior = this.xAnterior - Canvas.camarax;
            this.yAnterior = this.yAnterior - Canvas.camaray;
            this.xAnterior1 = this.xAnterior1 - Canvas.camarax;
            this.yPrevious1 = this.yPrevious1 - Canvas.camaray;
            this.ultimoX1 = this.ultimoX1 - Canvas.camarax;
            this.ultimoY1 = this.ultimoY1 - Canvas.camaray;
            this.xAnterior1Int = this.xAnterior1Int - Canvas.camarax;
            this.yAnterior1Int = this.yAnterior1Int - Canvas.camaray;
            this.ultimoX1Int = this.ultimoX1Int - Canvas.camarax;
            this.ultimoY1Int = this.ultimoY1Int - Canvas.camaray;
            this.xAnterior1_A = this.xAnterior1_A - Canvas.camarax;
            this.yAnterior1_A = this.yAnterior1_A - Canvas.camaray;
            this.ultimoX1_A = this.ultimoX1_A - Canvas.camarax;
            this.ultimoY1_A = this.ultimoY1_A - Canvas.camaray;
            this.xAnterior1Int_A = this.xAnterior1Int_A - Canvas.camarax;
            this.yAnterior1Int_A = this.yAnterior1Int_A - Canvas.camaray;
            this.ultimoX1Int_A = this.ultimoX1Int_A - Canvas.camarax;
            this.ultimoY1Int_A = this.ultimoY1Int_A - Canvas.camaray;
            this.xAnterior2 = this.xAnterior2 - Canvas.camarax;
            this.yPrevious2 = this.yPrevious2 - Canvas.camaray;
            this.ultimoX2 = this.ultimoX2 - Canvas.camarax;
            this.ultimoY2 = this.ultimoY2 - Canvas.camaray;
            this.xAnterior2Int = this.xAnterior2Int - Canvas.camarax;
            this.yAnterior2Int = this.yAnterior2Int - Canvas.camaray;
            this.ultimoX2Int = this.ultimoX2Int - Canvas.camarax;
            this.ultimoY2Int = this.ultimoY2Int - Canvas.camaray;
            this.xAnterior2_A = this.xAnterior2_A - Canvas.camarax;
            this.yAnterior2_A = this.yAnterior2_A - Canvas.camaray;
            this.ultimoX2_A = this.ultimoX2_A - Canvas.camarax;
            this.ultimoY2_A = this.ultimoY2_A - Canvas.camaray;
            this.xAnterior2Int_A = this.xAnterior2Int_A - Canvas.camarax;
            this.yAnterior2Int_A = this.yAnterior2Int_A - Canvas.camaray;
            this.ultimoX2Int_A = this.ultimoX2Int_A - Canvas.camarax;
            this.ultimoY2Int_A = this.ultimoY2Int_A - Canvas.camaray;
            return;
        }// end function

        public function dibujaEn(param1:Shape) : void
        {
            var brush:Brush = this.brushManager.actualBrush;
            if (!brush)
            {
                this.dispatchEvent(new Event(Event.COMPLETE));
                return;
            }
            _loc_3 = brush.x;
            _loc_4 = brush.y;
            if (_loc_3 < 20)
            {
                _loc_3 = 20;
            }
            if (_loc_4 < 20)
            {
                _loc_4 = 20;
            }
            if (_loc_3 > Sketcher.viewPort.width - 20)
            {
                _loc_3 = Sketcher.viewPort.width - 20;
            }
            if (_loc_4 > Sketcher.viewPort.height - 20)
            {
                _loc_4 = Sketcher.viewPort.height - 20;
            }
            _loc_5 = brush.pressure * Sketcher.realPressure;
            _loc_6 = this.xAnterior + this.vx;
            _loc_7 = this.yAnterior + this.vy;
            _loc_8 = _loc_3 - this.xAnterior;
            _loc_9 = _loc_4 - this.yAnterior;
            _loc_10 = Math.sqrt(_loc_8 * _loc_8 + _loc_9 * _loc_9);
            if (_loc_10 > stroke.maxDistanciaTrazo)
            {
                _loc_10 = stroke.maxDistanciaTrazo;
            }
            if (_loc_10 < stroke.minDistanciaTrazo)
            {
                _loc_10 = stroke.minDistanciaTrazo;
            }
            _loc_11 = Canvas.getAngle(this.xAnterior, this.yAnterior, _loc_3, _loc_4);
            _loc_12 = Canvas.getAngle(this.xAnterior, this.yAnterior, _loc_6, _loc_7);
            _loc_13 = _loc_11 - _loc_12;
            if (_loc_13 > Math.PI)
            {
                _loc_13 = _loc_13 - 2 * Math.PI;
            }
            if (_loc_13 < -Math.PI)
            {
                _loc_13 = _loc_13 + 2 * Math.PI;
            }
            if (Math.abs(_loc_13) > 0.3)
            {
                this.dispatchEvent(new curvaEvent("curva", _loc_12, Math.abs(_loc_13)));
            }
            this.desviacion = this.desviacion + (_loc_13 - this.desviacion) / brush.strokeElasticity;
            this.trayectoria = this.trayectoria + this.desviacion;
            _loc_3 = this.xAnterior + _loc_10 * Math.cos(this.trayectoria);
            _loc_4 = this.yAnterior + _loc_10 * Math.sin(this.trayectoria);
            _loc_14 = this.separacionReal * (0.95 + 0.1 * Math.random());
            _loc_15 = (brush.up + _loc_14) * _loc_5;
            _loc_16 = (brush.down + _loc_14) * _loc_5;
            _loc_17 = angulo1;
            _loc_18 = angulo2;
            _loc_19 = Math.cos(this.trayectoria + _loc_17);
            _loc_20 = Math.sin(this.trayectoria + _loc_17);
            _loc_21 = Math.cos(this.trayectoria + _loc_18);
            _loc_22 = Math.sin(this.trayectoria + _loc_18);
            _loc_23 = _loc_15 * _loc_19;
            _loc_24 = _loc_15 * _loc_20;
            _loc_25 = _loc_16 * _loc_21;
            _loc_26 = _loc_16 * _loc_22;
            _loc_27 = _loc_14 * _loc_19 * _loc_5;
            _loc_28 = _loc_14 * _loc_20 * _loc_5;
            _loc_29 = _loc_14 * _loc_21 * _loc_5;
            _loc_30 = _loc_14 * _loc_22 * _loc_5;
            _loc_31 = _loc_3 + _loc_23;
            _loc_32 = _loc_4 + _loc_24;
            _loc_33 = _loc_3 + _loc_25;
            _loc_34 = _loc_4 + _loc_26;
            _loc_35 = new Point(_loc_31 - this.xAnterior1, _loc_32 - this.yPrevious1);
            _loc_36 = new Point(_loc_33 - this.xAnterior2, _loc_34 - this.yPrevious2);
            _loc_37 = 1 + brush.yaw * _loc_5;
            this.v1.x = this.v1.x + (_loc_35.x - this.v1.x) / _loc_37;
            this.v1.y = this.v1.y + (_loc_35.y - this.v1.y) / _loc_37;
            this.v2.x = this.v2.x + (_loc_36.x - this.v2.x) / _loc_37;
            this.v2.y = this.v2.y + (_loc_36.y - this.v2.y) / _loc_37;
            _loc_31 = this.xAnterior1 + this.v1.x;
            _loc_32 = this.yPrevious1 + this.v1.y;
            _loc_33 = this.xAnterior2 + this.v2.x;
            _loc_34 = this.yPrevious2 + this.v2.y;
            _loc_38 = _loc_3 + _loc_27;
            _loc_39 = _loc_4 + _loc_28;
            _loc_40 = _loc_3 + _loc_29;
            _loc_41 = _loc_4 + _loc_30;
            this.vx = _loc_3 - this.xAnterior;
            this.vy = _loc_4 - this.yAnterior;
            _loc_42 = (this.xAnterior1Int + _loc_38) / 2;
            _loc_43 = (this.yAnterior1Int + _loc_39) / 2;
            _loc_44 = (this.xAnterior1 + _loc_31) / 2;
            _loc_45 = (this.yPrevious1 + _loc_32) / 2;
            _loc_46 = (this.xAnterior2Int + _loc_40) / 2;
            _loc_47 = (this.yAnterior2Int + _loc_41) / 2;
            _loc_48 = (this.xAnterior2 + _loc_33) / 2;
            _loc_49 = (this.yPrevious2 + _loc_34) / 2;
            if (!this.primero && _loc_5 > 0.01)
            {
				if(GameProxy.INSTANCE.starPowerActive){
					param1.graphics.beginFill(CanvasConstants[Sketcher.currentThemeID.toUpperCase()+"_COLOR_STAR_POWER_SECONDARY"][0], 1);//(this.tinta1, this.transformTinta, this.tinta1 == dibujante.imageInk1, this.tinta1 != dibujante.imageInk1);
				}
				else{
//					if( brushManager is pincelPrincipal2){
//						param1.graphics.beginFill(CanvasConstants[Sketcher.currentThemeID.toUpperCase()+"_COLORS_SECONDARY"][Canvas.currentColourIndex], 1);//this.tinta2, this.transformTinta, this.tinta2 == dibujante.imageInk2, this.tinta2 != dibujante.imageInk2);
//					}
//					else{
						param1.graphics.beginFill(CanvasConstants[Sketcher.currentThemeID.toUpperCase()+"_COLORS"][Canvas.currentColourIndex], 1);//this.tinta2, this.transformTinta, this.tinta2 == dibujante.imageInk2, this.tinta2 != dibujante.imageInk2);
//					}
                	//param1.graphics.beginFill(CanvasConstants[Sketcher.currentThemeID.toUpperCase()+"_COLORS"][Canvas.currentColourIndex], 1);//(this.tinta1, this.transformTinta, this.tinta1 == dibujante.imageInk1, this.tinta1 != dibujante.imageInk1);
				}
                param1.graphics.moveTo(this.ultimoX1_A, this.ultimoY1_A);
                param1.graphics.curveTo(this.xAnterior1_A, this.yAnterior1_A, this.ultimoX1, this.ultimoY1);
                param1.graphics.curveTo(this.xAnterior1, this.yPrevious1, _loc_44, _loc_45);
                param1.graphics.lineTo(_loc_42, _loc_43);
                param1.graphics.curveTo(this.xAnterior1Int, this.yAnterior1Int, this.ultimoX1Int, this.ultimoY1Int);
                param1.graphics.curveTo(this.xAnterior1Int_A, this.yAnterior1Int_A, this.ultimoX1Int_A, this.ultimoY1Int_A);
                param1.graphics.lineTo(this.ultimoX1_A, this.ultimoY1_A);
                param1.graphics.endFill();
				if(GameProxy.INSTANCE.starPowerActive){
					param1.graphics.beginFill(CanvasConstants[Sketcher.currentThemeID.toUpperCase()+"_COLOR_STAR_POWER_SECONDARY"][0], 1);//this.tinta2, this.transformTinta, this.tinta2 == dibujante.imageInk2, this.tinta2 != dibujante.imageInk2);
				}
				else{
//					if( brushManager is pincelPrincipal2){
						param1.graphics.beginFill(CanvasConstants[Sketcher.currentThemeID.toUpperCase()+"_COLORS_SECONDARY"][Canvas.currentColourIndex], 1);//this.tinta2, this.transformTinta, this.tinta2 == dibujante.imageInk2, this.tinta2 != dibujante.imageInk2);
//					}
//					else{
//						param1.graphics.beginFill(CanvasConstants[Sketcher.currentThemeID.toUpperCase()+"_COLORS"][Canvas.currentColourIndex], 1);//this.tinta2, this.transformTinta, this.tinta2 == dibujante.imageInk2, this.tinta2 != dibujante.imageInk2);
//					}
				}
                param1.graphics.moveTo(this.ultimoX2_A, this.ultimoY2_A);
                param1.graphics.curveTo(this.xAnterior2_A, this.yAnterior2_A, this.ultimoX2, this.ultimoY2);
                param1.graphics.curveTo(this.xAnterior2, this.yPrevious2, _loc_48, _loc_49);
                param1.graphics.lineTo(_loc_46, _loc_47);
                param1.graphics.curveTo(this.xAnterior2Int, this.yAnterior2Int, this.ultimoX2Int, this.ultimoY2Int);
                param1.graphics.curveTo(this.xAnterior2Int_A, this.yAnterior2Int_A, this.ultimoX2Int_A, this.ultimoY2Int_A);
                param1.graphics.lineTo(this.ultimoX2_A, this.ultimoY2_A);
                param1.graphics.endFill();
            }
            this.primero = false;
            this.xAnterior1_A = this.xAnterior1;
            this.yAnterior1_A = this.yPrevious1;
            this.xAnterior1Int_A = this.xAnterior1Int;
            this.yAnterior1Int_A = this.yAnterior1Int;
            this.ultimoX1_A = this.ultimoX1;
            this.ultimoY1_A = this.ultimoY1;
            this.ultimoX1Int_A = this.ultimoX1Int;
            this.ultimoY1Int_A = this.ultimoY1Int;
            this.xAnterior1 = _loc_31;
            this.yPrevious1 = _loc_32;
            this.xAnterior1Int = _loc_38;
            this.yAnterior1Int = _loc_39;
            this.ultimoX1 = _loc_44;
            this.ultimoY1 = _loc_45;
            this.ultimoX1Int = _loc_42;
            this.ultimoY1Int = _loc_43;
            this.xAnterior2_A = this.xAnterior2;
            this.yAnterior2_A = this.yPrevious2;
            this.xAnterior2Int_A = this.xAnterior2Int;
            this.yAnterior2Int_A = this.yAnterior2Int;
            this.ultimoX2_A = this.ultimoX2;
            this.ultimoY2_A = this.ultimoY2;
            this.ultimoX2Int_A = this.ultimoX2Int;
            this.ultimoY2Int_A = this.ultimoY2Int;
            this.xAnterior2 = _loc_33;
            this.yPrevious2 = _loc_34;
            this.xAnterior2Int = _loc_40;
            this.yAnterior2Int = _loc_41;
            this.ultimoX2 = _loc_48;
            this.ultimoY2 = _loc_49;
            this.ultimoX2Int = _loc_46;
            this.ultimoY2Int = _loc_47;
            this.thickness = Math.sqrt((_loc_31 - _loc_33) * (_loc_31 - _loc_33) + (_loc_32 - _loc_34) * (_loc_32 - _loc_34));
            this.xAnterior = _loc_3;
            this.yAnterior = _loc_4;
            this.ultimoX = (_loc_44 + _loc_48) / 2;
            this.ultimoY = (_loc_45 + _loc_49) / 2;
            this.velocidadTotal = Math.sqrt(this.vx * this.vx + this.vy * this.vy);
            return;
        }// end function

		
		public function destroy():void{
			brushManager = null;
			tinta1 = null;
			tinta2 = null;
		}
    }
}
