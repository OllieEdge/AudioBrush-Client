package com.edgington.view.huds.interfaces
{
	import org.osflash.signals.Signal;

	public interface IAudioBrushButton
	{
		function get buttonSignal():Signal;
		function set buttonSignal(buttonSignal:Signal):void;
		
		function get buttonIsClean():Boolean;
		function set buttonIsClean(buttonIsClean:Boolean):void;
		
		function removeButton(delay:Number = 0):void;
	}
}