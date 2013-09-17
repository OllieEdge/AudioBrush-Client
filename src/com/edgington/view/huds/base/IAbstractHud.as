package com.edgington.view.huds.base
{

	public interface IAbstractHud
	{
		function addListeners():void;
		function setupVisuals():void;
		
		function readyForRemoval():void;
	}
}