package com.edgington.control
{
	import com.edgington.util.debug.LOG;
	import com.edgington.valueobjects.MouseSignalsVO;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.osflash.signals.Signal;

	public class Control
	{
		
		protected static var INSTANCE:Control;
		
		private var MouseDownSignal:Signal;
		private var MouseUpSignal:Signal;
		private var MouseMoveSignal:Signal;
		private var MouseOutSignal:Signal;
		
		private var UpdateSignal:Signal;
		
		private var mainStage:Sprite
		
		public function Control(e:SingletonEnforcer)
		{
			LOG.create(this);
		}
		
		/**
		 * Initialises all the required signals and listeners
		 */
		public function init(stage:Sprite):void{
			mainStage = stage;
			
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
		}
		
		/**
		 * Adds all the mouse listeners required to the main stage.
		 */
		protected function addMouseListeners():void{
			mainStage.parent.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseEvents);
			mainStage.parent.addEventListener(MouseEvent.MOUSE_UP, handleMouseEvents);
			mainStage.parent.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseEvents);
			mainStage.parent.addEventListener(MouseEvent.MOUSE_OUT, handleMouseEvents);
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
		 * Returns all the signals so that they can be used where-ever needed.
		 */
		public static function getMouseSignals():MouseSignalsVO{
			var mouseSignals:MouseSignalsVO = new MouseSignalsVO();
			mouseSignals.DOWN_Signal = INSTANCE.MouseDownSignal;
			mouseSignals.MOVE_Signal = INSTANCE.MouseMoveSignal;
			mouseSignals.OUT_Signal = INSTANCE.MouseOutSignal;
			mouseSignals.UP_Signal = INSTANCE.MouseUpSignal;
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