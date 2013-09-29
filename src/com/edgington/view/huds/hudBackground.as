package com.edgington.view.huds
{
	import com.edgington.constants.Constants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.control.Control;
	import com.edgington.util.debug.LOG;
	import com.edgington.view.assets.AssetLoader;
	import com.edgington.view.model.ScreenManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class hudBackground extends Sprite
	{
		private var BITMAP_SIZE:int = 256;
		
		private var bitmaps:Vector.<Bitmap>;
		private var bitmapDatas:Vector.<BitmapData>;
		
		private var rowsToCreate:int = 0;
		private var columnsToCreate:int = 0;
		
		private var isMoving:Boolean = false;
		
		private var lastPositionX:int;
		private var lastPositionY:int;
		
		private var onScreenState:Sprite;
		
		
		public function hudBackground()
		{
			super();
			
			LOG.create(this);
			
			if(ScreenManager.getDevice() == Constants.IPHONE_3GS){
				BITMAP_SIZE = 128;
			}
			
			bitmapDatas = new Vector.<BitmapData>();
			bitmaps = new Vector.<Bitmap>;
			
			addListeners();
			
			setupBitmapGrid();
		}
		
		public function newHudActive(onScreenState:Sprite):void{
			this.onScreenState = onScreenState;
			lastPositionX = onScreenState.x;
			lastPositionY = onScreenState.y;
			isMoving = true;
		}
		
		private function addListeners():void{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			Control.getUpdateSignal().add(tick);
		}
		
		private function setupBitmapGrid():void{
			rowsToCreate = Math.ceil(DynamicConstants.SCREEN_HEIGHT / BITMAP_SIZE) + 1;
			columnsToCreate = Math.ceil(DynamicConstants.SCREEN_WIDTH / BITMAP_SIZE) + 1;
			
			for(var r:int = 0; r < rowsToCreate; r++){
				for(var c:int = 0; c < columnsToCreate; c++){
					var bitmapData:BitmapData = new BitmapData(BITMAP_SIZE, BITMAP_SIZE, false, 0x00);
					bitmapData.copyPixels(AssetLoader.imageDictionary["theme_normal_gameBackground"], bitmapData.rect, new Point(0, 0));
					bitmapDatas.push(bitmapData);
					var bitmap:Bitmap = new Bitmap(bitmapData, "never", false);
					bitmap.x = BITMAP_SIZE*c;
					bitmap.y = BITMAP_SIZE*r;
					bitmaps.push(bitmap);
					bitmap.cacheAsBitmap = true;
					this.addChild(bitmap);
				}
			}
		}
		
		private function tick():void{
			if(isMoving){
				for(var i:int = 0; i < bitmaps.length; i++){
					bitmaps[i].x += Math.round((onScreenState.x-lastPositionX)*1.2);
					bitmaps[i].y += Math.round((onScreenState.y-lastPositionY)*1.2);
				}
				if(onScreenState.x == lastPositionX && onScreenState.y == lastPositionY){
					isMoving = false;
				}
				else{
					lastPositionX = onScreenState.x;
					lastPositionY = onScreenState.y;
				}
				
				if(bitmaps[bitmaps.length-1].y < DynamicConstants.SCREEN_HEIGHT-BITMAP_SIZE){
					MoveFirstRowToEnd();
				}
				
				if(bitmaps[0].y > 0){
					MoveLastRowToFirst();
				}
				
				if(bitmaps[columnsToCreate-1].x < DynamicConstants.SCREEN_WIDTH-BITMAP_SIZE){
					MoveFirstColumnToEnd();
				}
				
				if(bitmaps[0].x > 0){
					MoveEndColumnToFirst();
				}
				
			}
		}
		
		private function MoveEndColumnToFirst():void{
			var bm:Vector.<Bitmap> = new Vector.<Bitmap>;
			var bmd:Vector.<BitmapData> = new Vector.<BitmapData>;
			for(var i:int = 0; i < rowsToCreate; i++){
				bm.push(bitmaps[((i*(columnsToCreate-1))+(columnsToCreate-1))]);
				bmd.push(bitmapDatas[((i*(columnsToCreate-1))+(columnsToCreate-1))]);
				bm[bm.length-1].x = bitmaps[((i*columnsToCreate)-i)].x - BITMAP_SIZE;
				bitmapDatas.splice(((i*(columnsToCreate-1))+(columnsToCreate-1)), 1);
				bitmaps.splice(((i*(columnsToCreate-1))+(columnsToCreate-1)), 1);
			}
			for(i = 0 ; i < rowsToCreate; i++){
				bitmaps.splice(i*columnsToCreate, 0, bm[i]);
				bitmapDatas.splice(i*columnsToCreate, 0, bmd[i]);
			}
			bm = null;
			bmd = null;
		}
		
		private function MoveFirstColumnToEnd():void{
			var bm:Vector.<Bitmap> = new Vector.<Bitmap>;
			var bmd:Vector.<BitmapData> = new Vector.<BitmapData>;
			for(var i:int = 0; i < rowsToCreate; i++){
				bm.push(bitmaps[(i*columnsToCreate)-i]);
				bmd.push(bitmapDatas[(i*columnsToCreate)-i]);
				bm[bm.length-1].x = bitmaps[((i*columnsToCreate)-i)+(columnsToCreate-1)].x + BITMAP_SIZE;
				bitmapDatas.splice((i*columnsToCreate)-i, 1);
				bitmaps.splice((i*columnsToCreate)-i, 1);
			}
			for(i = 0 ; i < rowsToCreate; i++){
				bitmaps.splice(((i+1)*columnsToCreate)-1, 0, bm[i]);
				bitmapDatas.splice(((i+1)*columnsToCreate)-1, 0, bmd[i]);
			}
			bm = null;
			bmd = null;
		}
		
		private function MoveFirstRowToEnd():void{
			var bm:Vector.<Bitmap> = new Vector.<Bitmap>;
			var bmd:Vector.<BitmapData> = new Vector.<BitmapData>;
			for(var i:int = 0; i < columnsToCreate; i++){
				bm.push(bitmaps[0]);
				bmd.push(bitmapDatas[0]);
				bm[bm.length-1].y = bitmaps[bitmaps.length-1].y + BITMAP_SIZE;
				bitmapDatas.shift();
				bitmaps.shift();
			}
			for(i = 0 ; i < columnsToCreate; i++){
				bitmaps.push(bm[i]);
				bitmapDatas.push(bmd[i]);
			}
			bm = null;
			bmd = null;
		}
		
		private function MoveLastRowToFirst():void{
			var bm:Vector.<Bitmap> = new Vector.<Bitmap>;
			var bmd:Vector.<BitmapData> = new Vector.<BitmapData>;
			for(var i:int = 0; i < columnsToCreate; i++){
				bm.push(bitmaps[(bitmaps.length-(columnsToCreate-i))]);
				bmd.push(bitmapDatas[(bitmaps.length-(columnsToCreate-i))]);
				bm[bm.length-1].y = bitmaps[0].y - BITMAP_SIZE;
				bitmapDatas.splice(bitmaps.length-(columnsToCreate-i), 1);
				bitmaps.splice((bitmaps.length-(columnsToCreate-i)), 1);
			}
			for(i = (columnsToCreate-1); i > -1; i--){
				bitmaps.unshift(bm[i]);
				bitmapDatas.unshift(bmd[i]);
			}
		}
		
		private function destroy(e:Event):void{
			LOG.destroy(this);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			Control.getUpdateSignal().remove(tick);
			
			for(var i:int = 0; i < bitmapDatas.length; i++){
				bitmaps[i] = null;
				bitmapDatas[i].dispose();
				bitmapDatas[i] = null;
			}
			bitmapDatas = null;
			bitmaps = null;
			onScreenState = null;
		}
	}
}