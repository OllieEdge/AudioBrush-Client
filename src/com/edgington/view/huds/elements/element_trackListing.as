package com.edgington.view.huds.elements
{
	import com.edgington.constants.Constants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.control.Control;
	import com.edgington.model.calculators.PopulatiryCalculator;
	import com.edgington.net.TrackData;
	import com.edgington.types.DeviceTypes;
	import com.edgington.util.TextFieldManager;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.gettext;
	import com.edgington.valueobjects.MouseSignalsVO;
	import com.edgington.valueobjects.net.ServerTrackVO;
	import com.edgington.view.huds.vo.TrackListingVO;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import org.osflash.signals.Signal;

	public class element_trackListing extends Sprite
	{
		private var items:Vector.<ServerTrackVO>;;
		
		private var _width:int = 0;
		private var _height:int = 0;
		
		private var trackListings:Vector.<TrackListingVO>;
		private var listingsContainer:Sprite;
		
		private var loading:ui_loading;
		
		private var maskContainer:Sprite;
		
		private var startScrollTracking:Boolean = false;
		private var isScrolling:Boolean = false;
		private var startYPoint:int = 0;
		
		private var mouseEvents:MouseSignalsVO;
		
		private var selectSignal:Signal;
		
		private var listingItemHeight:int = 75;
		
		public function element_trackListing(height:int, width:int, selectSignal:Signal)
		{
			super();
			
			this.selectSignal = selectSignal;
			
			_width = width;
			_height = height;
			
			maskContainer = new Sprite();
			maskContainer.graphics.beginFill(0);
			maskContainer.graphics.drawRect(0, 0, _width, _height);
			maskContainer.graphics.endFill();
			this.addChild(maskContainer);
			
			listingsContainer = new Sprite();
			this.addChild(listingsContainer);
			
			loading = new ui_loading();
			loading.x = _width*.5;
			loading.y = _height*.5;
			this.addChild(loading);
			listingsContainer.mask = maskContainer;
			
			mouseEvents = Control.getMouseSignals();
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		public function addLoading():void{
			if(trackListings != null){
				for(var t:int = 0; t < trackListings.length; t++){
					trackListings[t].clip.removeEventListener(MouseEvent.MOUSE_DOWN, trackDown);
					trackListings[t].clip.removeEventListener(MouseEvent.MOUSE_UP, trackSelected);
					listingsContainer.removeChild(trackListings[t].clip);
				}
			}
			trackListings = null;
			this.addChild(loading);
		}
		
		public function addTrackListing(items:Vector.<ServerTrackVO>):void{
			mouseEvents.DOWN_Signal.add(trackScrolling);
			this.items = items.concat();
			if(trackListings != null){
				for(var t:int = 0; t < trackListings.length; t++){
					trackListings[t].clip.removeEventListener(MouseEvent.MOUSE_DOWN, trackDown);
					trackListings[t].clip.removeEventListener(MouseEvent.MOUSE_UP, trackSelected);
					listingsContainer.removeChild(trackListings[t].clip);
				}
			}
			listingsContainer.y = 0;
			trackListings = new Vector.<TrackListingVO>;
			if(items.length > 0){
				for(var i:int = 0; i < items.length; i++){
					var trackListingVO:TrackListingVO = new TrackListingVO();
					trackListingVO.clip = new Sprite();
					
					trackListingVO.background = new Sprite();
					if(i%2 == 0){
						trackListingVO.background.graphics.beginFill(Constants.DARK_WHITE_COLOUR);
					}
					else{
						trackListingVO.background.graphics.beginFill(Constants.NORMAL_WHITE_COLOUR);
					}
					trackListingVO.background.graphics.drawRect(0, 0, _width - (DynamicConstants.BUTTON_SPACING*2), listingItemHeight*DynamicConstants.DEVICE_SCALE);
					trackListingVO.background.graphics.endFill();
					trackListingVO.background.name = "background";
					
					trackListingVO.clip.addChild(trackListingVO.background);
					
					trackListingVO.image = new ui_profile_artwork();
					trackListingVO.image.cacheAsBitmap = true;
					trackListingVO.image.width = 69*DynamicConstants.DEVICE_SCALE;
					trackListingVO.image.height = 69*DynamicConstants.DEVICE_SCALE;
					trackListingVO.image.x = 3*DynamicConstants.DEVICE_SCALE;
					trackListingVO.image.y = 3*DynamicConstants.DEVICE_SCALE;
					
					trackListingVO.clip.addChild(trackListingVO.image);
					
					trackListingVO.trackListingData = new TrackData(new <String>[items[i].trackname, items[i].artist], trackListingVO.image);
					
					trackListingVO.trackNameField = TextFieldManager.createTextField(items[i].trackname, FONT_audiobrush_content_bold, Constants.DARK_FONT_COLOR, 26*DynamicConstants.DEVICE_SCALE, false, TextFieldAutoSize.LEFT);
					trackListingVO.name = TextFieldManager.createTextField(gettext("highscores_track_item_listing_artist", {artist:items[i].artist}), FONT_audiobrush_content, Constants.DARK_FONT_COLOR, 18*DynamicConstants.DEVICE_SCALE, false, TextFieldAutoSize.LEFT);
					var plays:String 
					if(items[i].plays == 1){
						plays = gettext("highscores_track_play_count");
					}
					else{
						plays = gettext("highscores_track_play_counts", {playcount:items[i].plays});
					}
					
					if(DynamicConstants.DEVICE_TYPE == DeviceTypes.IPHONE){
						var trackPopDiffIphone:ui_track_pop_diff_iphone = new ui_track_pop_diff_iphone();
						trackPopDiffIphone.popularity.gotoAndStop(PopulatiryCalculator.calculatePopularity(items[i].plays, items[i].last_update));
						trackPopDiffIphone.difficulty.gotoAndStop(items[i].difficulty);
						trackPopDiffIphone.height = (listingItemHeight*DynamicConstants.DEVICE_SCALE) - (DynamicConstants.BUTTON_SPACING*2);
						trackPopDiffIphone.scaleX = trackPopDiffIphone.scaleY;
						trackPopDiffIphone.cacheAsBitmap = true;
						trackPopDiffIphone.x = (_width - DynamicConstants.BUTTON_SPACING*2) - DynamicConstants.BUTTON_SPACING;
						trackPopDiffIphone.y = trackListingVO.background.height *.5 - trackPopDiffIphone.height*.5;
						trackListingVO.clip.addChild(trackPopDiffIphone);
					}
					else{
						var trackPopDiff:ui_track_pop_diff = new ui_track_pop_diff();
						trackPopDiff.popularity.gotoAndStop(PopulatiryCalculator.calculatePopularity(items[i].plays, items[i].last_update));
						trackPopDiff.difficulty.gotoAndStop(items[i].difficulty);
						trackPopDiff.height = (listingItemHeight*DynamicConstants.DEVICE_SCALE) - (DynamicConstants.BUTTON_SPACING);
						trackPopDiff.scaleX = trackPopDiff.scaleY;
						trackPopDiff.cacheAsBitmap = true;
						trackPopDiff.x = (_width - DynamicConstants.BUTTON_SPACING*2) - DynamicConstants.BUTTON_SPACING;
						trackPopDiff.y += DynamicConstants.BUTTON_SPACING*.5;
						trackListingVO.clip.addChild(trackPopDiff);
					}
					
					trackListingVO.trackNameField.y = 3*DynamicConstants.DEVICE_SCALE;
					trackListingVO.trackNameField.x = trackListingVO.image.width + DynamicConstants.BUTTON_SPACING;
					
					trackListingVO.name.x = trackListingVO.image.width + DynamicConstants.BUTTON_SPACING;
					trackListingVO.name.y = 38*DynamicConstants.DEVICE_SCALE;
					
					trackListingVO.clip.addChild(trackListingVO.trackNameField);
					trackListingVO.clip.addChild(trackListingVO.name);
					
					trackListingVO.trackName = items[i].trackname;
					trackListingVO.artist = items[i].artist;
					
					trackListingVO.clip.cacheAsBitmap = true;
					trackListingVO.clip.y = i*(listingItemHeight*DynamicConstants.DEVICE_SCALE);
					trackListingVO.clip.addEventListener(MouseEvent.MOUSE_UP, trackSelected);
					trackListingVO.clip.addEventListener(MouseEvent.MOUSE_DOWN, trackDown);
					trackListings.push(trackListingVO);
				}
			}
			else{
				var trackListingVO2:TrackListingVO = new TrackListingVO();
				trackListings = new Vector.<TrackListingVO>;
				trackListingVO2.clip = new Sprite();
				var txtNoScores:TextField = TextFieldManager.createTextField(gettext("highscores_no_scores_available_global"), FONT_audiobrush_content_bold, Constants.DARK_FONT_COLOR, 14*DynamicConstants.DEVICE_SCALE, false, TextFieldAutoSize.CENTER);
				txtNoScores.height = 30;
				txtNoScores.x = _width*.5 - txtNoScores.width*.5;
				txtNoScores.y = _height*.5 - txtNoScores.height*.5;
				trackListingVO2.clip.addChild(txtNoScores);
				trackListingVO2.clip.cacheAsBitmap = true;
				trackListings.push(trackListingVO2);
			}
			addAdditionalElements();
			if(loading.parent != null){
				this.removeChild(loading);
			}
		}
		
		public function addErrorMessage(str:String):void{
			if(trackListings != null){
				for(var t:int = 0; t < trackListings.length; t++){
					trackListings[t].clip.removeEventListener(MouseEvent.MOUSE_DOWN, trackDown);
					trackListings[t].clip.removeEventListener(MouseEvent.MOUSE_UP, trackSelected);
					listingsContainer.removeChild(trackListings[t].clip);
				}
			}
			listingsContainer.y = 0;
			var trackListingVO:TrackListingVO = new TrackListingVO();
			trackListings = new Vector.<TrackListingVO>;
			trackListingVO.clip = new Sprite();
			var txtNoScores:TextField = TextFieldManager.createTextField(str, FONT_audiobrush_content_bold, Constants.DARK_FONT_COLOR, 14, false, TextFieldAutoSize.CENTER);
			txtNoScores.height = 30;
			txtNoScores.x = _width*.5 - txtNoScores.width*.5;
			txtNoScores.y = _height*.5 - txtNoScores.height*.5;
			trackListingVO.clip.addChild(txtNoScores);
			trackListingVO.clip.cacheAsBitmap = true;
			trackListings.push(trackListingVO);
			addAdditionalElements();
			this.removeChild(loading)
		}
		
		private function trackDown(e:MouseEvent):void{
			for(var i:int = 0; i < trackListings.length; i++){
				if(e.currentTarget == trackListings[i].clip){
					trackListings[i].background.graphics.clear();
					trackListings[i].background.graphics.beginFill(Constants.DARK_FONT_COLOR);
					trackListings[i].background.graphics.drawRect(0, 0, _width - (DynamicConstants.BUTTON_SPACING*2), listingItemHeight*DynamicConstants.DEVICE_SCALE);
					trackListings[i].background.graphics.endFill();
					LOG.info("Track Down: " + trackListings[i].trackName);
					break;
				}
			}
		}
		
		private function trackSelected(e:MouseEvent):void{
			if(!isScrolling){
				for(var i:int = 0; i < trackListings.length; i++){
					trackListings[i].clip.removeEventListener(MouseEvent.MOUSE_DOWN, trackDown);
					trackListings[i].clip.removeEventListener(MouseEvent.MOUSE_UP, trackSelected);
					if(e.currentTarget == trackListings[i].clip){
						trackListings[i].background.graphics.clear();
						if(i%2 == 0){
							trackListings[i].background.graphics.beginFill(Constants.DARK_WHITE_COLOUR);
						}
						else{
							trackListings[i].background.graphics.beginFill(Constants.NORMAL_WHITE_COLOUR);
						}
						trackListings[i].background.graphics.drawRect(0, 0, _width - (DynamicConstants.BUTTON_SPACING*2), listingItemHeight*DynamicConstants.DEVICE_SCALE);
						trackListings[i].background.graphics.endFill();
						selectSignal.dispatch(trackListings[i]);
					}
					listingsContainer.removeChild(trackListings[i].clip);
				}
				trackListings = null;
			}
		}
		
		private function addAdditionalElements():void{
			for(var i:int = 0 ; i < trackListings.length; i++){
				listingsContainer.addChild(trackListings[i].clip);
			}
		}
		
		private function trackScrolling(xPos:int, yPos:int):void{
			startScrollTracking = true;
			startYPoint = yPos;
			mouseEvents.DOWN_Signal.remove(trackScrolling);
			mouseEvents.MOVE_Signal.add(trackMovement);
			mouseEvents.UP_Signal.add(stopTracking);
		}
		
		private function stopTracking(xPos:int, yPos:int):void{
			if(startScrollTracking){
				startScrollTracking = false;
				mouseEvents.DOWN_Signal.add(trackScrolling);
				mouseEvents.MOVE_Signal.remove(trackMovement);
				mouseEvents.UP_Signal.remove(stopTracking);
			}
			else if(isScrolling){
				isScrolling = false;
				mouseEvents.DOWN_Signal.add(trackScrolling);
				mouseEvents.MOVE_Signal.remove(scrollList);
				mouseEvents.UP_Signal.remove(stopTracking);
			}
		}
		
		private function trackMovement(xPos:int, yPos:int):void{
			if(startYPoint+10 < yPos || startYPoint-10 > yPos){
				for(var i:int = 0; i < trackListings.length; i++){
					trackListings[i].background.graphics.clear();
					if(i%2 == 0){
						trackListings[i].background.graphics.beginFill(Constants.DARK_WHITE_COLOUR);
					}
					else{
						trackListings[i].background.graphics.beginFill(Constants.NORMAL_WHITE_COLOUR);
					}
					trackListings[i].background.graphics.drawRect(0, 0, _width - (DynamicConstants.BUTTON_SPACING*2), listingItemHeight*DynamicConstants.DEVICE_SCALE);
					trackListings[i].background.graphics.endFill();
				}
				startScrollTracking = false;
				isScrolling = true;
				mouseEvents.MOVE_Signal.remove(trackMovement);
				mouseEvents.MOVE_Signal.add(scrollList);
			}
		}
		
		private function scrollList(xPos:int, yPos:int):void{
			listingsContainer.y += yPos-startYPoint;
			startYPoint = yPos;
			if(listingsContainer.height + listingsContainer.y < _height){
				listingsContainer.y = -listingsContainer.height + _height;
			}
			if(listingsContainer.y > 0){
				listingsContainer.y = 0;
			}
		}
		
		private function destroy(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			mouseEvents.DOWN_Signal.removeAll();
			mouseEvents.UP_Signal.removeAll();
			mouseEvents.MOVE_Signal.removeAll();
			selectSignal = null;
			if(trackListings != null){
				for(var t:int = 0; t < trackListings.length; t++){
					trackListings[t].clip.removeEventListener(MouseEvent.MOUSE_DOWN, trackDown);
					trackListings[t].clip.removeEventListener(MouseEvent.MOUSE_UP, trackSelected);
					listingsContainer.removeChild(trackListings[t].clip);
				}
			}
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			trackListings = null;
			this.mask = null;
			loading = null;
			maskContainer = null;
		}
	}
}