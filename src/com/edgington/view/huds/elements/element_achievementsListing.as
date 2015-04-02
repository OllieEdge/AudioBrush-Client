package com.edgington.view.huds.elements
{
	import com.doitflash.consts.Easing;
	import com.doitflash.consts.Orientation;
	import com.doitflash.consts.ScrollConst;
	import com.doitflash.events.ScrollEvent;
	import com.doitflash.utils.scroll.TouchScroll;
	import com.edgington.constants.AchievementConstants;
	import com.edgington.constants.Constants;
	import com.edgington.constants.DynamicConstants;
	import com.edgington.control.Control;
	import com.edgington.net.AchievementData;
	import com.edgington.types.DeviceTypes;
	import com.edgington.types.FontFaceType;
	import com.edgington.util.localisation.getfont;
	import com.edgington.util.localisation.gettext;
	import com.edgington.view.huds.vo.AchievementVO;
	import com.greensock.TweenLite;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class element_achievementsListing extends Sprite
	{
		
		private var achievementsMainBackground:Sprite;
		private var achievementsTitle:ui_achievements_title;
		private var temporaryMask:Sprite;
		
		private var loadingIcon:ui_loading;
		
		private var achievements:Vector.<AchievementVO>;
		
		private var achievementsContainer:Sprite;
		
		private var _scroller:TouchScroll;
		
		private var totalCompletion:int = 0;
		
		private var origin:Point;
		
		private var deviceItemHeight:Number = 0;
		
		private var visibleStartIndex:int = 0;
		private var maximumVisibleRows:int = 4;
		
		private var achievementItems:Vector.<Sprite>;
		
		//this holds the visible height of this element ( the actuall height may be more depending on the amount of achievements listed.
		public var _height:int;
		
		public function element_achievementsListing()
		{
			super();
			
			AchievementConstants.populateAchievements();
			
			
			addListeners();
			
			setupVisuals();
		}
		
		private function addListeners():void{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			AchievementData.getInstance().achievementUpdateSignal.addOnce(displayAchievements);
			AchievementData.getInstance().getAchievements();
		}
		
		private function setupVisuals():void{
			
			achievementsTitle = new ui_achievements_title();
			
			achievementsTitle.scaleX = achievementsTitle.scaleY = DynamicConstants.MESSAGE_SCALE;
			achievementsTitle.cacheAsBitmap = true;
			achievementsTitle.x = (DynamicConstants.SCREEN_WIDTH*.5) - (achievementsTitle.width *.5);
			achievementsTitle.y = DynamicConstants.SCREEN_MARGIN;
			
			getfont(achievementsTitle.txt_title, FontFaceType.BOLD);
			getfont(achievementsTitle.txt_percentage_complete, FontFaceType.REGULAR);
			
			achievementsTitle.txt_title.text = gettext("achievements_screen_title");
			achievementsTitle.txt_percentage_complete.text = gettext("achievements_screen_complete_percentage", {percentage:totalCompletion});
			achievementsTitle.ui_progressbar.bar.scaleX = totalCompletion*.01;
			
			achievementsMainBackground = new Sprite();
			achievementsMainBackground.graphics.beginFill(Constants.NORMAL_WHITE_COLOUR, 1);
			if(DeviceTypes.IPHONE == DynamicConstants.DEVICE_TYPE){
				achievementsMainBackground.graphics.drawRect(0, 0, DynamicConstants.SCREEN_WIDTH-(DynamicConstants.SCREEN_MARGIN*2), DynamicConstants.SCREEN_HEIGHT - (DynamicConstants.SCREEN_MARGIN*3.5) - achievementsTitle.height);
			}
			else{
				achievementsMainBackground.graphics.drawRect(0, 0, DynamicConstants.SCREEN_WIDTH-(DynamicConstants.SCREEN_MARGIN*2), DynamicConstants.SCREEN_HEIGHT - (DynamicConstants.SCREEN_MARGIN*2.5) - achievementsTitle.height);
			}
			achievementsMainBackground.graphics.endFill();
			achievementsMainBackground.x = DynamicConstants.SCREEN_WIDTH*.5 - achievementsMainBackground.width*.5;
			achievementsMainBackground.y = achievementsTitle.y + achievementsTitle.height + DynamicConstants.BUTTON_SPACING;
			
			loadingIcon = new ui_loading();
			loadingIcon.x = achievementsMainBackground.x + achievementsMainBackground.width*5;
			loadingIcon.y = achievementsMainBackground.y + achievementsMainBackground.height*5;
			
			this.addChild(achievementsTitle);
			this.addChild(achievementsMainBackground);
			this.addChild(loadingIcon);
		
			_height = achievementsMainBackground.y+achievementsMainBackground.height - achievementsTitle.y;
		}
		
		private function displayAchievements():void{
			this.removeChild(loadingIcon);
			loadingIcon = null;
			
			achievements = AchievementData.getInstance().userAchievements.concat();
			var completed:int = 0;
			
			
			temporaryMask = new Sprite();
			temporaryMask.graphics.beginFill(Constants.NORMAL_WHITE_COLOUR);
			temporaryMask.graphics.drawRect(0, 0, achievementsMainBackground.width - (DynamicConstants.BUTTON_SPACING*2), achievementsMainBackground.height - (DynamicConstants.BUTTON_SPACING*2));
			temporaryMask.graphics.endFill();
			
			temporaryMask.x = achievementsMainBackground.x + (3*DynamicConstants.DEVICE_SCALE);
			temporaryMask.y = achievementsMainBackground.y + (3*DynamicConstants.DEVICE_SCALE);
			
			achievementsContainer = new Sprite();
			achievementItems = new Vector.<Sprite>;
			
			deviceItemHeight = 76*DynamicConstants.DEVICE_SCALE;
			
			maximumVisibleRows = Math.ceil(temporaryMask.height/deviceItemHeight)+1;
			
			for(var i:int = 0; i < achievements.length; i++){
				var itemBackground:Sprite = new Sprite();
				itemBackground.name = "achievement_"+i;
				if(i % 2 == 0){
					itemBackground.graphics.beginFill(Constants.NORMAL_WHITE_COLOUR);
				}
				else{
					itemBackground.graphics.beginFill(Constants.DARK_WHITE_COLOUR);
				}
				itemBackground.graphics.drawRect(0, 0, achievementsMainBackground.width - (DynamicConstants.BUTTON_SPACING*2), 76*DynamicConstants.DEVICE_SCALE);
				itemBackground.graphics.endFill();
				
				var achievement:ui_achievement_listing = new ui_achievement_listing();
				
				getfont(achievement.txt_title, FontFaceType.BOLD);
				getfont(achievement.txt_description, FontFaceType.REGULAR);
				getfont(achievement.progress.txt_percentage, FontFaceType.REGULAR);
				
				achievement.height = itemBackground.height - (6*DynamicConstants.DEVICE_SCALE);
				achievement.scaleX = achievement.scaleY;
				achievement.x = 3*DynamicConstants.DEVICE_SCALE;
				achievement.y = 3*DynamicConstants.DEVICE_SCALE;
				if(achievements[i].progress == 100){
					completed++;
				}
				achievement.progress.gotoAndStop((Math.floor(achievement.progress.totalFrames*(achievements[i].progress*.01)))+1);
				achievement.progress.txt_percentage.text = gettext("user_hud_level_percentage", {percentage:achievements[i].progress});
				achievement.txt_title.text = achievements[i].name;
				if(achievements[i].secret && achievements[i].progress != 100){
					achievement.txt_description.text = gettext("achievements_secret");
				}
				else{
					achievement.txt_description.text = achievements[i].description;	
				}
				
				
				
				if(achievements[i].credits > 0 || achievements[i].reward != ""){
					var achievementReward:MovieClip;
					if(achievements[i].credits > 0){
						achievementReward = new ui_achievement_reward_listing() as MovieClip;
						getfont(achievementReward.txt_reward_title, FontFaceType.BOLD);
						getfont(achievementReward.txt_rewardName, FontFaceType.REGULAR);
						ui_achievement_reward_listing(achievementReward).txt_reward_title.text = gettext("achievements_reward_title");
						ui_achievement_reward_listing(achievementReward).txt_rewardName.text = gettext("achievements_reward_credits", {credits:achievements[i].credits});
					}
					else{
						achievementReward = new ui_achievement_reward_listing_item as MovieClip;
						getfont(achievementReward.txt_reward_title, FontFaceType.BOLD);
						getfont(achievementReward.txt_rewardName, FontFaceType.REGULAR);
						ui_achievement_reward_listing_item(achievementReward).txt_reward_title.text = gettext("achievements_reward_title");
						ui_achievement_reward_listing_item(achievementReward).txt_rewardName.text = achievements[i].reward;
					}
					achievementReward.scaleX = achievementReward.scaleY = (achievement.scaleX + (0.3*DynamicConstants.DEVICE_SCALE));
					achievementReward.x = itemBackground.width - (3*DynamicConstants.DEVICE_SCALE);
					achievementReward.y = itemBackground.height - (3*DynamicConstants.DEVICE_SCALE);
					itemBackground.addChild(achievementReward);
				}
				itemBackground.y = (i*itemBackground.height);
				itemBackground.cacheAsBitmap = true;
				itemBackground.addChild(achievement);
				
				achievementItems.push(itemBackground);
				
				achievementsContainer.addChild(itemBackground);
			}
			achievementsContainer.x = achievementsMainBackground.x + DynamicConstants.BUTTON_SPACING+10;
			achievementsContainer.y = achievementsMainBackground.y + DynamicConstants.BUTTON_SPACING+10;
			achievementsContainer.mask = temporaryMask;
			
			origin = new Point(achievementsMainBackground.x + DynamicConstants.BUTTON_SPACING, achievementsMainBackground.y + DynamicConstants.BUTTON_SPACING);
			
			totalCompletion = Math.floor((completed/achievements.length)*100);
			
			achievementsTitle.txt_percentage_complete.text = gettext("achievements_screen_complete_percentage", {percentage:totalCompletion});
			achievementsTitle.ui_progressbar.bar.scaleX = totalCompletion*.01;
			
			this.addChild(achievementsContainer);
			this.addChild(temporaryMask);
			
			TweenLite.delayedCall(0.7, setScroller);
		}
		
		private function checkVisibility(e:ScrollEvent):void{
			
			var visualPosition:int = Math.floor(((achievementsContainer.height-(_scroller.maskHeight*(_scroller.yPerc*0.01))) * (_scroller.yPerc*0.01)) / deviceItemHeight);
			visualPosition--;
			visualPosition = Math.max(visualPosition, 0);
			visualPosition = Math.min(visualPosition, achievementItems.length - maximumVisibleRows);
			if(visualPosition != visibleStartIndex){
				for(var i:int = 0; i < maximumVisibleRows; i++){
					achievementItems[i+visibleStartIndex].visible = false;
				}
				visibleStartIndex = visualPosition;
				for(i = 0; i < maximumVisibleRows; i++){
					achievementItems[i+visibleStartIndex].visible = true;
				}
			}
		}
		
		private function setScroller():void
		{
			this.removeChild(temporaryMask);
			achievementsContainer.x = 0;
			achievementsContainer.y = 0;
			achievementsContainer.mask = null;
			if (!_scroller) 
			{
				_scroller =  new TouchScroll();
			}
			
			_scroller.addEventListener(ScrollEvent.MOUSE_MOVE, checkVisibility);
			_scroller.addEventListener(ScrollEvent.TOUCH_TWEEN_UPDATE, checkVisibility);
			
			//------------------------------------------------------------------------------ set Scroller
			_scroller.maskContent = achievementsContainer;
			_scroller.maskWidth = achievementsMainBackground.width - (DynamicConstants.BUTTON_SPACING*2);
			_scroller.maskHeight = achievementsMainBackground.height - (DynamicConstants.BUTTON_SPACING*2);
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
			
			_scroller.x = achievementsMainBackground.x + DynamicConstants.BUTTON_SPACING;
			_scroller.y = achievementsMainBackground.y + DynamicConstants.BUTTON_SPACING;
			
			origin = new Point(DynamicConstants.SCREEN_MARGIN*2, achievementsMainBackground.y);
			
			this.addChild(_scroller);
			
			for(var i:int = maximumVisibleRows; i < achievementItems.length; i++){
				achievementItems[i].visible = false;
			}
		}
		
		private function destroy(e:Event):void{
			if(_scroller != null){
				_scroller.removeEventListener(ScrollEvent.MOUSE_MOVE, checkVisibility);
				_scroller.removeEventListener(ScrollEvent.TOUCH_TWEEN_UPDATE, checkVisibility);
			}
			TweenLite.killDelayedCallsTo(setScroller);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			_scroller = null;
			achievementsMainBackground = null;
			achievementsTitle = null;
			temporaryMask = null;
			achievements = null;
			achievementsContainer = null;
			loadingIcon = null;
		}
	}
}