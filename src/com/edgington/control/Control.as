package com.edgington.control
{
	import com.edgington.util.debug.LOG;
	import com.edgington.valueobjects.MouseSignalsVO;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	import org.osflash.signals.Signal;

	public class Control
	{
		
		protected static var INSTANCE:Control;
		
		private var MouseDownSignal:Signal;
		private var MouseUpSignal:Signal;
		private var MouseMoveSignal:Signal;
		private var MouseOutSignal:Signal;
		
		private var TouchDownSignal:Signal;
		private var TouchMoveSignal:Signal;
		private var TouchUpSignal:Signal;
		
		private var UpdateSignal:Signal;
		
		private var mainStage:Sprite
		
		private var touchCoordsArray:Vector.<TouchEventVO>;
		
		public static var disableMouse:Boolean = false;
		
		public static function disableMouseFunc(disable:Boolean):void{
			disableMouse = disable;
		}
		
		public function Control(e:SingletonEnforcer)
		{
			LOG.create(this);
		}
		
		/**
		 * Initialises all the required signals and listeners
		 */
		public function init(stage:Sprite):void{
			mainStage = stage;
			touchCoordsArray = new Vector.<TouchEventVO>;
			
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			initMouseSignals();
			initEventSignals();
			
			addMouseListeners();
			addEventListeners();
		}
		
		protected function initEventSignals():void
		{
			UpdateSignal = new Signal();
		}
		
		/**
		 * Adds the standard event listeners
		 */
		protected function addEventListeners():void
		{
			mainStage.addEventListener(Event.ENTER_FRAME, enterFrameListener);
		}
		
		/**
		 * Has it's own listeners to minimise the amount of calculations we need to do.
		 */
		protected function enterFrameListener(e:Event):void{
			UpdateSignal.dispatch();
		}
		
		/**
		 * Initialises all the mouse signals
		 */
		protected function initMouseSignals():void{
			MouseDownSignal = new Signal();
			MouseMoveSignal = new Signal();
			MouseOutSignal = new Signal();
			MouseUpSignal = new Signal();
			
			TouchDownSignal = new Signal();
			TouchMoveSignal = new Signal();
			TouchUpSignal = new Signal();
		}
		
		/**
		 * Adds all the mouse listeners required to the main stage.
		 */
		protected function addMouseListeners():void{
			mainStage.parent.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseEvents);
			mainStage.parent.addEventListener(MouseEvent.MOUSE_UP, handleMouseEvents);
			mainStage.parent.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseEvents);
			mainStage.parent.addEventListener(MouseEvent.MOUSE_OUT, handleMouseEvents);
			
			mainStage.parent.addEventListener(TouchEvent.TOUCH_BEGIN, handleTouchEvents);
			mainStage.parent.addEventListener(TouchEvent.TOUCH_MOVE, handleTouchEvents);
			mainStage.parent.addEventListener(TouchEvent.TOUCH_END, handleTouchEvents);
		}
		
		/**
		 * Removes all the mouse listeners from the main stage.
		 */
		protected function removeMouseListeners():void{
			mainStage.parent.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseEvents);
			mainStage.parent.removeEventListener(MouseEvent.MOUSE_UP, handleMouseEvents);
			mainStage.parent.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseEvents);
			mainStage.parent.removeEventListener(MouseEvent.MOUSE_OUT, handleMouseEvents);
		}
		
		/**
		 * Each mouse event is handled, and each mouse handle will have a seperate signal
		 */
		protected function handleMouseEvents(event:MouseEvent):void
		{
			switch(event.type){
				case MouseEvent.MOUSE_DOWN:
					MouseDownSignal.dispatch(event.stageX, event.stageY);
					break;
				case MouseEvent.MOUSE_UP:
					MouseUpSignal.dispatch(event.stageX, event.stageY);
					break;
				case MouseEvent.MOUSE_MOVE:
					MouseMoveSignal.dispatch(event.stageX, event.stageY);
					break;
				case MouseEvent.MOUSE_OUT:
					MouseOutSignal.dispatch(event.stageX, event.stageY);
					break;
			}
		}
		
		/**
		 * This handles all the touch events
		 */
		private function handleTouchEvents(event:TouchEvent):void{
			switch(event.type){
				case TouchEvent.TOUCH_BEGIN:
					touchCoordsArray.push(new TouchEventVO(event.touchPointID, event.stageX, event.stageY));
					TouchDownSignal.dispatch(touchCoordsArray);
					break;
				case TouchEvent.TOUCH_MOVE:
					for(var i:int = 0; i < touchCoordsArray.length; i++){
						if(touchCoordsArray[i].touchID == event.touchPointID){
							touchCoordsArray[i].x = event.stageX;
							touchCoordsArray[i].y = event.stageY;
							break;
						}
					}
					TouchMoveSignal.dispatch(touchCoordsArray);
					break;
				case TouchEvent.TOUCH_END:
					//LOG.debug(event.touchPointID);
					for(var e:int = 0; e < touchCoordsArray.length; e++){
						if(touchCoordsArray[e].touchID == event.touchPointID){
							touchCoordsArray.splice(e, 1);
							break;
						}
					}
					TouchUpSignal.dispatch(touchCoordsArray);
					break;
			}
		}
		
		/**
		 * Returns all the signals so that they can be used where-ever needed.
		 */
		public static function getMouseSignals():MouseSignalsVO{
			var mouseSignals:MouseSignalsVO = new MouseSignalsVO();
			mouseSignals.DOWN_Signal = INSTANCE.MouseDownSignal;
			mouseSignals.MOVE_Signal = INSTANCE.MouseMoveSignal;
			mouseSignals.OUT_Signal = INSTANCE.MouseOutSignal;
			mouseSignals.UP_Signal = INSTANCE.MouseUpSignal;
			mouseSignals.DOWN_Touch_Signal = INSTANCE.TouchDownSignal;
			mouseSignals.UP_Touch_Signal = INSTANCE.TouchUpSignal;
			mouseSignals.MOVE_Touch_Signal = INSTANCE.TouchMoveSignal;
			return mouseSignals;
		}
		
		public static function getUpdateSignal():Signal{
			return INSTANCE.UpdateSignal;
		}
		
		public static function getInstance():Control{
			if(INSTANCE == null){
				INSTANCE = new Control(new SingletonEnforcer());
			}
			return INSTANCE;
		}
	}
}

class SingletonEnforcer{
	
}