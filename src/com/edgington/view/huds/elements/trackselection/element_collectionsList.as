package com.edgington.view.huds.elements.trackselection
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
	import com.edgington.net.TrackData;
	import com.edgington.types.CollectionType;
	import com.edgington.util.TextFieldManager;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.vo.CollectionListingItemVO;
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
	import flash.text.TextFormat;
	
	import org.osflash.signals.Signal;
	
	public class element_collectionsList extends Sprite
	{
		
		private var background:Shape;
		
		private var mask:Sprite;
		private var itemContainer:Sprite;
		
		private var items:Vector.<Object>;
		
		private var margin:int = 4;
		
		private var _height:int;
		private var _width:int;
		
		private var maximumItemsToShow:int;
		public var itemHeight:int;
		
		public var itemList:Vector.<CollectionListingItemVO>;
		
		private var colors:Array;
		
		private var itemHandlerSignal:Signal;
		
		private var _scroller:TouchScroll;
		private var isScrolling:Boolean;
		
		private var maximumItemsToLoadInView:int = 20;
		
		private var currentCollectionType:String = CollectionType.ARTISTS;
		
		
		private var deviceItemHeight:Number = 0;
		
		private var visibleStartIndex:int = 0;
		private var maximumVisibleRows:int = 4;
		
		
		public function element_collectionsList(itemStrings:Vector.<CollectionListingItemVO>, maximumItemsToShow:int, itemHeight:int, _width:int, itemHandlerSignal:Signal, selectedCollectionType:String)
		{
			super();
			
			this.itemList = itemStrings;
			this.maximumItemsToShow = maximumItemsToShow;
			this.itemHeight = itemHeight;
			this._width = _width;
			this._height = (maximumItemsToShow * itemHeight);
			this.itemHandlerSignal = itemHandlerSignal;
			this.currentCollectionType = selectedCollectionType;
			
			sortItemList();
			
			addListeners();
			
			setupVisuals();
		}
		
		private function addListeners():void{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			colors = new Array(0xEFEFEF, 0xE6E6E6);
			margin = margin * DynamicConstants.BUTTON_SCALE;
		}
		
		private function setupVisuals():void{
			background = new Shape();
			background.graphics.beginFill(Constants.DARK_FONT_COLOR);
			background.graphics.drawRect(0, 0, _width+(margin*2), _height+(margin*2));
			background.graphics.endFill();
			//this.addChild(background);
			
			mask = new Sprite();
			mask.graphics.beginFill(Constants.DARK_FONT_COLOR);
			mask.graphics.drawRect(0, 0, _width, _height);
			mask.graphics.endFill();
			mask.x = margin;
			mask.y = margin;
			//this.addChild(mask);
			
			generateItems();
			//itemContainer.x = margin;
			//itemContainer.y = margin;
			//this.addChild(itemContainer);
			//itemContainer.mask = mask;
		}
		
		private function generateItems():void{
			if(itemContainer == null){
				itemContainer = new Sprite();
			}
			items = new Vector.<Object>;
			var bm:Bitmap;
			var bmd:BitmapData;
			var clip:Sprite;
			var listing:ui_listItem;
			var trackArtwork:ui_profile_artwork;
			var trackData:TrackData;
			
			deviceItemHeight = itemHeight;
			
			maximumVisibleRows = maximumItemsToShow+2;
			
			for(var i:int = 0; i < itemList.length; i++){
				clip = new Sprite();
				
				listing = new ui_listItem();
				listing.height = itemHeight;
				listing.width = _width;
				clip.addChild(listing);
				
				trackArtwork = new ui_profile_artwork();
				
				var ct:ColorTransform = new ColorTransform();
				ct.color = colors[0];
				if(i%2 == 0){
					ct.color = colors[1];
				}
				listing.transform.colorTransform = ct;
				
				var txtTitle:TextField
				switch(currentCollectionType){
					case CollectionType.ARTISTS:
						txtTitle = TextFieldManager.createTextField(itemList[i].artist, FONT_audiobrush_content_bold, Constants.DARK_FONT_COLOR, itemHeight*.35, false, TextFieldAutoSize.LEFT);
						trackData = new TrackData(new <String>[itemList[i].artist], trackArtwork);
						trackArtwork.height = trackArtwork.width = itemHeight - (margin*2);
						trackArtwork.x = trackArtwork.y = margin;
						break;
					case CollectionType.ALBUMS:
						txtTitle = TextFieldManager.createTextField(itemList[i].album, FONT_audiobrush_content_bold, Constants.DARK_FONT_COLOR, itemHeight*.35, false, TextFieldAutoSize.LEFT);
						trackData = new TrackData(new <String>[itemList[i].album], trackArtwork);
						trackArtwork.height = trackArtwork.width = itemHeight - (margin*2);
						trackArtwork.x = trackArtwork.y = margin;
						break;
					case CollectionType.PLAYLISTS:
						txtTitle = TextFieldManager.createTextField(itemList[i].playlist, FONT_audiobrush_content_bold, Constants.DARK_FONT_COLOR, itemHeight*.35, false, TextFieldAutoSize.LEFT);
						trackData = new TrackData(new <String>[itemList[i].artist], trackArtwork);
						trackArtwork.height = trackArtwork.width = itemHeight - (margin*2);
						trackArtwork.x = trackArtwork.y = margin;
						break;
					default:
						trackData = new TrackData(new <String>[itemList[i].artist], trackArtwork);
						trackArtwork.height = trackArtwork.width = itemHeight - (margin*2);
						trackArtwork.x = trackArtwork.y = margin;
						txtTitle = TextFieldManager.createTextField(itemList[i].artist, FONT_audiobrush_content_bold, Constants.DARK_FONT_COLOR, itemHeight*.35, false, TextFieldAutoSize.LEFT);
						break;
				}
				
				txtTitle.x = trackArtwork.x + trackArtwork.width + (DynamicConstants.DEVICE_SCALE * margin);
				txtTitle.height = 50;//might need to change this
				txtTitle.y = -(txtTitle.textHeight *.6) + (listing.height*.5);
				
				var str:String;
				if(itemList[i].numOfTracks > 1){
					str = gettext("track_selection_num_of_tracks", {num:itemList[i].numOfTracks});
				}
				else{
					str = gettext("track_selection_1_track");
				}
				
				var txtTrackCount:TextField = TextFieldManager.createTextField(str, FONT_audiobrush_content, Constants.DARK_FONT_COLOR, itemHeight*.35, false, TextFieldAutoSize.RIGHT);
				txtTrackCount.x = listing.width - txtTrackCount.textWidth -  (DynamicConstants.DEVICE_SCALE * (3*margin));
				txtTrackCount.y = -(txtTrackCount.textHeight *.6) + (listing.height*.5);
			
				clip.addChild(txtTitle);
				clip.addChild(txtTrackCount);
				
				bmd = new BitmapData(clip.width, clip.height, false);
				bmd.drawWithQuality(clip, null, null, null, null, null, StageQuality.BEST);
				bm = new Bitmap(bmd);
				bm.cacheAsBitmap = true;
				bm.y = itemHeight*items.length;
				trackArtwork.y = bm.y + margin;
				trackArtwork.cacheAsBitmap = true;
				
				clip = new Sprite();
				clip.addChild(bm);
				clip.addChild(trackArtwork);
				
				clip.addEventListener(MouseEvent.MOUSE_UP, itemSelected, false, 0, true);
				
				var obj:Object = new Object();
				obj.clip = clip;
				obj.item = itemList[i];
				obj.isSelected = false;
				obj.title = txtTitle;
				obj.trackCount = txtTrackCount;
				obj.artwork = trackArtwork;
				obj.background = listing;
				obj.isDarkColor = (i%2 == 0);
				obj.position = items.length;
				
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
				var currentItem:Object;
				SoundManager.getInstance().loadAndPlaySFX(SoundConstants.SFX_OPTION_SELECT, "", 1);
				for(var i:int = 0; i < items.length; i++){
					if(e.currentTarget == items[i].clip){
						items[i].isSelected = true;
						generateColourItem(items[i]);
						itemHandlerSignal.dispatch(items[i].item);
					}
					if(items[i].isSelected && items[i].clip != e.currentTarget){
						items[i].isSelected = false;
						unColourItem(items[i]);
					}
				}
			}
		}
		
		private function unColourItem(item:Object):void{
			var ct:ColorTransform = new ColorTransform();
			ct.color = colors[0];
			if(item.isDarkColor){
				ct.color = colors[1];
			}
			item.background.transform.colorTransform = ct;
			
			var tf:TextFormat = item.title.getTextFormat();
			tf.color = Constants.DARK_FONT_COLOR;
			
			item.title.setTextFormat(tf);
			
			tf = item.trackCount.getTextFormat();
			tf.color = Constants.DARK_FONT_COLOR;
			
			item.trackCount.setTextFormat(tf);
			
			while(item.clip.numChildren > 0){
				item.clip.removeChildAt(0);
			}
			
			item.clip.addChild(item.background);
			item.clip.addChild(item.title);
			item.clip.addChild(item.trackCount);
			
			var bm:Bitmap;
			var bmd:BitmapData;
			bmd = new BitmapData(item.clip.width, item.clip.height, false);
			bmd.drawWithQuality(item.clip, null, null, null, null, null, StageQuality.BEST);
			bm = new Bitmap(bmd);
			bm.cacheAsBitmap = true;
			bm.y = itemHeight*item.position;
			
			while(item.clip.numChildren > 0){
				item.clip.removeChildAt(0);
			}
			
			item.clip.addChild(bm);
			item.clip.addChild(item.artwork);
		}
		
		private function generateColourItem(item:Object):void{
			var ct:ColorTransform = new ColorTransform();
			ct.color = 0xB2DF00;
			item.background.transform.colorTransform = ct;
			
			var tf:TextFormat = item.title.getTextFormat();
			tf.color = 0xF2F2F2;
			
			item.title.setTextFormat(tf);
			
			tf = item.trackCount.getTextFormat();
			tf.color = 0xF2F2F2;
			
			item.trackCount.setTextFormat(tf);
			
			while(item.clip.numChildren > 0){
				item.clip.removeChildAt(0);
			}
			
			item.clip.addChild(item.background);
			item.clip.addChild(item.title);
			item.clip.addChild(item.trackCount);
			
			var bm:Bitmap;
			var bmd:BitmapData;
			bmd = new BitmapData(item.clip.width, item.clip.height, false);
			bmd.drawWithQuality(item.clip, null, null, null, null, null, StageQuality.BEST);
			bm = new Bitmap(bmd);
			bm.cacheAsBitmap = true;
			bm.y = itemHeight*item.position;
			
			while(item.clip.numChildren > 0){
				item.clip.removeChildAt(0);
			}
			
			item.clip.addChild(bm);
			item.clip.addChild(item.artwork);
		}
		
		/**
		 * Sort the itemList vector so that it's in alphabetical order.
		 */
		private function sortItemList():void{
			function orderLastName(a, b):int 
			{ 
				var name1:String;
				var name2:String;
				switch(currentCollectionType){
					case CollectionType.ARTISTS:
						name1 = a.artist;
						name2 = b.artist;
						break;
					case CollectionType.ALBUMS:
						name1 = a.album;
						name2 = b.album;
						break;
					case CollectionType.PLAYLISTS:
						name1 = a.playlist;
						name2 = b.playlist;
						break;
				}
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
			
			trace(_scroller.yPerc);
			
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
			
			_scroller.x = 0;
			_scroller.y = 0;
			
			for(var i:int = maximumVisibleRows; i < items.length; i++){
				items[i].clip.visible = false;
			}
			
			this.addChild(_scroller);
			
			
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
			itemHandlerSignal = null;
			items = null;
			
			mask = null;
			
			colors = null;
			
		}
		
		override public function get height():Number{
			return _height+(4*DynamicConstants.BUTTON_SCALE);
		}
	}
}
