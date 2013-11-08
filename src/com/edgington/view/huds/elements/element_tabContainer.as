package com.edgington.view.huds.elements
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.constants.SoundConstants;
	import com.edgington.model.SoundManager;
	import com.edgington.view.huds.events.TabContainerEvent;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Linear;
	
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	
	import org.osflash.signals.Signal;
	
	public class element_tabContainer extends Sprite
	{
		
		public var body:ui_tabConatiner;
		public var tabDescription:ui_list_description_box;
		
		private var tabsContainer:Sprite;
		private var tabs:Vector.<ui_tab>;
		
		private var runningTotalWidth:int = 0;
		
		private var activeTab:int = 0;
		
		private var tabTweens:Vector.<TweenMax>;
		
		private var tabSignal:Signal;
		private var tabLabel:Vector.<String>;
		
		private var tabDescriptions:Vector.<String>;
		
		public var listingX:int = 0;
		public var listingY:int = 0;
		public var listingHeight:int = 0;
		
		public function element_tabContainer(tabLabels:Vector.<String>, tabSignal:Signal, tabDescriptions:Vector.<String>, height:int = 0)
		{
			super();
			
			this.tabSignal = tabSignal;
			this.tabLabel = tabLabels;
			this.tabDescriptions = tabDescriptions;
			body = new ui_tabConatiner();
			tabsContainer = new Sprite();
			tabs = new Vector.<ui_tab>;
			for(var i:int = 0; i < tabLabels.length; i++){
				var tab:ui_tab = new ui_tab();
				tab.txt_label.text = tabLabels[i];
				tab.txt_label.width = tab.txt_label.textWidth + 18;
				tab.background.width = tab.txt_label.textWidth + 30;
				if(i != 0){
					tab.scaleX = tab.scaleY = DynamicConstants.BUTTON_MINI_SCALE;
					tab.y = tabs[0].y;
				}
				else{
					tab.scaleX = tab.scaleY = DynamicConstants.BUTTON_SCALE;
					TweenMax.to(tab.background, 0.01, {tint:0xF0F0F0});
					TweenMax.to(tab.txt_label, 0.01, {tint:0x333333});
					tab.y = tab.height;
				}
				tab.x = runningTotalWidth;
				runningTotalWidth += tab.width;
				tabsContainer.addChild(tab);
				tabs.push(tab);
				tab.addEventListener(MouseEvent.MOUSE_UP, tabClicked)
			}
			this.addChild(tabsContainer);
			body.y = tabsContainer.height;
			body.width = (DynamicConstants.SCREEN_WIDTH-(DynamicConstants.SCREEN_MARGIN*2));
			if(height == 0){
				body.height = (DynamicConstants.SCREEN_HEIGHT-(DynamicConstants.SCREEN_MARGIN*2)-DynamicConstants.BUTTON_SPACING-(tabsContainer.height*DynamicConstants.BUTTON_SCALE));
			}
			else{
				body.height = height;
			}
			this.addChild(body);
			if(tabDescriptions.length > 0){
				tabDescription = new ui_list_description_box();
				tabDescription.txt_description.text = tabDescriptions[0];
				tabDescription.txt_description.scaleX = tabDescription.txt_description.scaleY = DynamicConstants.DEVICE_SCALE;
				tabDescription.background.width = (DynamicConstants.SCREEN_WIDTH-(DynamicConstants.SCREEN_MARGIN*2)) - (DynamicConstants.BUTTON_SPACING*2);
				tabDescription.background.height *= DynamicConstants.DEVICE_SCALE;
				tabDescription.x = body.x + DynamicConstants.BUTTON_SPACING;
				tabDescription.y = body.y + DynamicConstants.BUTTON_SPACING;
				tabDescription.txt_description.autoSize = TextFieldAutoSize.LEFT;
				tabDescription.cacheAsBitmap = true;
				tabDescription.visible = (tabDescriptions[0] != "");
				this.addChild(tabDescription);
			}			
			listingX = body.x + DynamicConstants.BUTTON_SPACING;
			if(tabDescriptions.length > 0){
				listingY = tabDescription.y + tabDescription.height;
			}
			else{
				listingY = body.y + DynamicConstants.BUTTON_SPACING;
			}
			listingHeight = body.y + body.height - listingY;
			
			//this.scaleX = this.scaleY = DynamicConstants.MESSAGE_SCALE;
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		private function tabClicked(e:MouseEvent):void{
			if(e.currentTarget != tabs[activeTab]){
				SoundManager.getInstance().loadAndPlaySFX(SoundConstants.SFX_TAB_SELECT, "", 1);
				cleanTweens();
				for(var i:int = 0; i < tabs.length; i++){
					if(tabs[i] == e.currentTarget){
						activeTab = i;
						if(tabDescription){
							tabDescription.txt_description.text = tabDescriptions[i];
							tabDescription.visible = (tabDescriptions[i] != "");
						}
						tabDescription.txt_description.text = tabDescriptions[i];
						tabSignal.dispatch(TabContainerEvent.TAB_CHANGED, tabLabel[i]);
						tabTweens.push(TweenMax.to(tabs[i], 0.3, {scaleX:DynamicConstants.BUTTON_SCALE, scaleY:DynamicConstants.BUTTON_SCALE, ease:Back.easeOut, onUpdate:positionTab, onUpdateParams:[tabs[i]]}));
						tabTweens.push(TweenMax.to(tabs[i].background, 0.2, {tint:0xF0F0F0, ease:Linear.easeNone}));
						tabTweens.push(TweenMax.to(tabs[i].txt_label, 0.2, {tint:0x333333, ease:Linear.easeNone}));
					}
					else{
						tabTweens.push(TweenMax.to(tabs[i], 0.3, {scaleX:DynamicConstants.BUTTON_MINI_SCALE, scaleY:DynamicConstants.BUTTON_MINI_SCALE, ease:Back.easeOut, onUpdate:positionTab, onUpdateParams:[tabs[i]]}));
						tabTweens.push(TweenMax.to(tabs[i].background, 0.2, {tint:0x333333, ease:Linear.easeNone}));
						tabTweens.push(TweenMax.to(tabs[i].txt_label, 0.2, {tint:0xCCCCCC, ease:Linear.easeNone}));
					}
				}
			}
		}
		
		private function positionTab(tab:MovieClip):void{
			for(var i:int = 0; i < tabs.length; i++){
				if(tab == tabs[i] && i != 0){
					tab.x = tabs[i-1].x + tabs[i-1].width;
				}
			}
		}
		
		private function cleanTweens():void{
			if(tabTweens != null){
				for(var i:int = 0; i < tabTweens.length; i++){
					tabTweens[i].kill();
					tabTweens[i] = null;
				}
				tabTweens = null;
			}
			tabTweens = new Vector.<TweenMax>;
		}
		
		private function destroy(e:Event):void{
			tabSignal.removeAll();
			tabSignal = null;
			cleanTweens();
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			body = null;
			for(var i:int = 0; i < tabs.length; i++){
				tabs[i].removeEventListener(MouseEvent.MOUSE_UP, tabClicked)
				tabs[i] = null;
			}
			tabs = null;
		}
		
		public function overrideTabSelection(tabIndex:int):void{
			cleanTweens();
			for(var i:int = 0; i < tabs.length; i++){
				if(tabs[i] == tabs[tabIndex]){
					activeTab = i;
					if(tabDescription){
						tabDescription.txt_description.text = tabDescriptions[i];
						tabDescription.visible = (tabDescriptions[i] != "");
					}
					tabDescription.txt_description.text = tabDescriptions[i];
					tabSignal.dispatch(TabContainerEvent.TAB_CHANGED, tabLabel[i]);
					tabTweens.push(TweenMax.to(tabs[i], 0.3, {scaleX:DynamicConstants.BUTTON_SCALE, scaleY:DynamicConstants.BUTTON_SCALE, ease:Back.easeOut, onUpdate:positionTab, onUpdateParams:[tabs[i]]}));
					tabTweens.push(TweenMax.to(tabs[i].background, 0.2, {tint:0xF0F0F0, ease:Linear.easeNone}));
					tabTweens.push(TweenMax.to(tabs[i].txt_label, 0.2, {tint:0x333333, ease:Linear.easeNone}));
				}
				else{
					tabTweens.push(TweenMax.to(tabs[i], 0.3, {scaleX:DynamicConstants.BUTTON_MINI_SCALE, scaleY:DynamicConstants.BUTTON_MINI_SCALE, ease:Back.easeOut, onUpdate:positionTab, onUpdateParams:[tabs[i]]}));
					tabTweens.push(TweenMax.to(tabs[i].background, 0.2, {tint:0x333333, ease:Linear.easeNone}));
					tabTweens.push(TweenMax.to(tabs[i].txt_label, 0.2, {tint:0xCCCCCC, ease:Linear.easeNone}));
				}
			}
		}
		
		public function get getTabBodyYOrigin():int{
			if(tabDescription != null && tabDescription.visible){
				return tabDescription.y + tabDescription.height;
			}
			else{
				return body.y;
			}
			return 0;
		}
		
		public function get getTabBodyHeight():int{
			if(tabDescription != null && tabDescription.visible){
				return body.height - ((tabDescription.y-body.y) + tabDescription.height);
			}
			else{
				return body.height;
			}
			return 0;
		}
	}
}