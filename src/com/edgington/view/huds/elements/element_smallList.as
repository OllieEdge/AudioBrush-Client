package com.edgington.view.huds.elements
{
	import com.doitflash.consts.Easing;
	import com.doitflash.consts.Orientation;
	import com.doitflash.consts.ScrollConst;
	import com.doitflash.events.ScrollEvent;
	import com.doitflash.utils.scroll.TouchScroll;
	import com.edgington.constants.Constants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.SoundConstants;
	import com.edgington.model.SoundManager;
	import com.edgington.util.TextFieldManager;
	import com.edgington.view.huds.vo.SmallListItemVO;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import org.osflash.signals.Signal;
	
	public class element_smallList extends Sprite
	{
		
		private var background:Shape;
		
		private var mask:Sprite;
		private var itemContainer:Sprite;
		
		private var items:Vector.<Object>;
		
		private var margin:int = 4;
		
		private var _height:int;
		private var _width:int;
		
		private var maximumItemsToShow:int;
		private var itemHeight:int;
		
		public var itemList:Vector.<SmallListItemVO>;
		
		private var colors:Array;
		
		private var itemHandlerSignal:Signal;
		
		private var _scroller:TouchScroll;
		private var isScrolling:Boolean;
		
		private var deviceItemHeight:Number = 0;
		
		private var visibleStartIndex:int = 0;
		private var maximumVisibleRows:int = 4;
		
		public function element_smallList(itemStrings:Vector.<SmallListItemVO>, maximumItemsToShow:int, itemHeight:int, _width:int, itemHandlerSignal:Signal)
		{
			super();
			
			this.itemList = itemStrings;
			this.maximumItemsToShow = maximumItemsToShow;
			this.itemHeight = itemHeight;
			this._width = _width;
			this._height = (maximumItemsToShow * itemHeight);
			this.itemHandlerSignal = itemHandlerSignal;
			
			sortItemList();
			
			addListeners();
			
			setupVisuals();
		}
		
		private function addListeners():void{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			colors = new Array(0xCCCCCC, Constants.NORMAL_WHITE_COLOUR);
			margin = margin * DynamicConstants.BUTTON_SCALE;
		}
		
		private function setupVisuals():void{
			background = new Shape();
			background.graphics.beginFill(Constants.DARK_FONT_COLOR);
			background.graphics.drawRect(0, 0, _width+(margin*2), _height+(margin*2));
			background.graphics.endFill();
			this.addChild(background);
			
			mask = new Sprite();
			mask.graphics.beginFill(Constants.DARK_FONT_COLOR);
			mask.graphics.drawRect(0, 0, _width, _height);
			mask.graphics.endFill();
			mask.x = margin;
			mask.y = margin;
			//this.addChild(mask);
			
			generateItems();
		}
		
		private function generateItems():void{
			if(itemContainer == null){
				itemContainer = new Sprite();
			}
			items = new Vector.<Object>;
			
			deviceItemHeight = itemHeight
			
			maximumVisibleRows = Math.ceil(_height/deviceItemHeight)+1;
			
			for(var i:int = 0; i < itemList.length; i++){
				var bm:Bitmap;
				var bmd:BitmapData;
				var clip:Sprite = new Sprite();
				
				var listing:ui_listItem = new ui_listItem();
				listing.height = itemHeight;
				listing.width = _width;
				clip.addChild(listing);
				
				var tickBox:ui_tickBox = new ui_tickBox();
				tickBox.width = tickBox.height = itemHeight-(4*DynamicConstants.BUTTON_SCALE);
				tickBox.blob.visible = itemList[i].ticked;
				tickBox.x = tickBox.y = (2*DynamicConstants.BUTTON_SCALE)
			
				var ct:ColorTransform = new ColorTransform();
				ct.color = colors[0];
				if(i%2 == 0){
					ct.color = colors[1];
				}
				listing.transform.colorTransform = ct;
				
				var txtLabel:TextField = TextFieldManager.createTextField(itemList[i].label, FONT_audiobrush_content_bold, Constants.DARK_FONT_COLOR, itemHeight*.65, false, TextFieldAutoSize.LEFT);
				txtLabel.x = itemHeight + margin;
				txtLabel.height = 50;//might need to change this
				
				clip.addChild(txtLabel);
				clip.addChild(tickBox);
				
				bmd = new BitmapData(clip.width, clip.height, false);
				bmd.drawWithQuality(clip, null, null, null, null, null, StageQuality.BEST);
				bm = new Bitmap(bmd);
				bm.cacheAsBitmap = true;
				bm.y = itemHeight*items.length;
				
				clip = new Sprite();
				clip.addChild(bm);
				
				clip.addEventListener(MouseEvent.MOUSE_UP, itemSelected, false, 0, true);
				
				var obj:Object = new Object();
				obj.clip = clip;
				obj.item = itemList[i];
				
				items.push(obj);
				itemContainer.addChild(clip);
			}
			
			setScroller();
		}
		
		public function removeItem(item:SmallListItemVO):void{
			
				for(var i:int = 0; i < itemList.length; i++){
					if(itemList[i].id == item.id){
						itemList.splice(i, 1);
						while(itemContainer.numChildren > 0){
							itemContainer.removeChildAt(0);
						}
						items = null;
						
						generateItems();
						//itemContainer.mask = mask;
						break;
					}
				}
		}
		
		public function addItem(item:SmallListItemVO):void{
				itemList.push(item);
				sortItemList();
	
				while(itemContainer.numChildren > 0){
					itemContainer.removeChildAt(0);
				}
				items = null;
				
				generateItems();
				//itemContainer.mask = mask;

		}
		
		private function itemSelected(e:MouseEvent):void{
			if(!_scroller._isHoldAreaDone){
				SoundManager.getInstance().loadAndPlaySFX(SoundConstants.SFX_OPTION_SELECT, "", 1);
				var currentItem:Object;
				for(var i:int = 0; i < items.length; i++){
					if(e.currentTarget == items[i].clip){
						itemHandlerSignal.dispatch(items[i].item);
						break;
					}
				}
			}
		}
		
		/**
		 * Sort the itemList vector so that it's in alphabetical order.
		 */
		private function sortItemList():void{
			function orderLastName(a, b):int 
			{ 
				var name1:String = a.label;
				var name2:String = b.label;
				if (name1 < name2) 
				{ 
					return -1; 
				} 
				else if (name1 > name2) 
				{ 
					return 1; 
				} 
				else 
				{ 
					return 0; 
				} 
			} 
			itemList.sort(orderLastName); 
		}
		
		private function checkVisibility(e:ScrollEvent):void{
			
			var visualPosition:int = Math.floor(((itemContainer.height-(_scroller.maskHeight*(_scroller.yPerc*0.01))) * (_scroller.yPerc*0.01)) / deviceItemHeight);
			visualPosition--;
			visualPosition = Math.max(visualPosition, 0);
			visualPosition = Math.min(visualPosition, items.length - maximumVisibleRows);
			if(visualPosition != visibleStartIndex){
				for(var i:int = 0; i < maximumVisibleRows; i++){
					items[i+visibleStartIndex].clip.visible = false;
				}
				visibleStartIndex = visualPosition;
				for(i = 0; i < maximumVisibleRows; i++){
					items[i+visibleStartIndex].clip.visible = true;
				}
			}
		}
		
		private function setScroller():void
		{
			if (!_scroller) 
			{
				_scroller =  new TouchScroll();
			}
			
			_scroller.addEventListener(ScrollEvent.MOUSE_MOVE, checkVisibility);
			_scroller.addEventListener(ScrollEvent.TOUCH_TWEEN_UPDATE, checkVisibility);
			
			//------------------------------------------------------------------------------ set Scroller
			_scroller.maskContent = itemContainer;
			_scroller.maskWidth = _width;
			_scroller.maskHeight = _height;
			_scroller.enableVirtualBg = true;
			_scroller.mouseWheelSpeed = 5;
			
			_scroller.orientation = Orientation.VERTICAL; // accepted values: Orientation.AUTO, Orientation.VERTICAL, Orientation.HORIZONTAL
			_scroller.easeType = Easing.Strong_easeOut;
			_scroller.scrollSpace = 0;
			_scroller.aniInterval = .5;
			_scroller.blurEffect = false;
			_scroller.lessBlurSpeed = 3;
			//_scroller.yPerc = 0; // min value is 0, max value is 100
			//_scroller.xPerc = 0; // min value is 0, max value is 100
			_scroller.mouseWheelSpeed = 2;
			_scroller.isMouseScroll = false;
			_scroller.isTouchScroll = true;
			_scroller.bitmapMode = ScrollConst.WEAK;
				; // use it for smoother scrolling, special when working on mobile devices, accepted values: "normal", "weak", "strong"
			_scroller.isStickTouch = false;
			_scroller.holdArea = 10;
			
			_scroller.x = margin;
			_scroller.y = margin;
			
			this.addChild(_scroller);
			
			for(var i:int = maximumVisibleRows; i < items.length; i++){
				items[i].clip.visible = false;
			}
		}
		
		
		protected function destroy(event:Event):void
		{
			_scroller.removeEventListener(ScrollEvent.MOUSE_MOVE, checkVisibility);
			_scroller.removeEventListener(ScrollEvent.TOUCH_TWEEN_UPDATE, checkVisibility);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			itemList = null;
			background = null;
			itemContainer = null;
			_scroller = null;
			itemHandlerSignal.removeAll();
			itemHandlerSignal = null;
			items = null;
		}
		
		override public function get height():Number{
			return _height+(4*DynamicConstants.BUTTON_SCALE);
		}
	}
}