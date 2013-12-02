package com.edgington.view.huds.elements
{
	import com.edgington.types.FontFaceType;
	import com.edgington.util.localisation.getfont;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.osflash.signals.Signal;
	
	public class element_tickBoxWithText extends Sprite
	{
		
		private var tickBox:ui_tickBoxWithText;
		
		private var handler:Signal;
		private var label:String;
		public var TICKED:Boolean;
		
		public function element_tickBoxWithText(label:String, handler:Signal, selectedDefault:Boolean = true)
		{
			super();
			
			this.handler = handler;
			this.label = label;
			this.TICKED = selectedDefault;
			
			addListeners();
			
			setupVisuals();
			
			this.mouseChildren = false;
			this.mouseEnabled = true;
		}
		
		private function addListeners():void{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			this.addEventListener(MouseEvent.MOUSE_UP, handleMouseEvent);
		}
		
		private function setupVisuals():void{
			tickBox = new ui_tickBoxWithText();
			getfont(tickBox.txt_label, FontFaceType.REGULAR);
			tickBox.txt_label.text = label;
			tickBox.blob.visible = TICKED;
			
			this.addChild(tickBox);
		}
		
		private function handleMouseEvent(e:MouseEvent):void{
			tickBox.blob.visible = TICKED = !TICKED;
			handler.dispatch();
		}
		
		private function destroy(e:Event):void{
			this.removeEventListener(MouseEvent.MOUSE_UP, handleMouseEvent);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			handler.removeAll();
			handler = null;
			tickBox = null;
		}
	}
}