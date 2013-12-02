package com.edgington.view.huds.elements
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.model.SettingsProxy;
	import com.edgington.net.ProductsData;
	import com.edgington.types.FontFaceType;
	import com.edgington.util.debug.LOG;
	import com.edgington.util.localisation.getfont;
	import com.edgington.util.localisation.gettext;
	import com.edgington.valueobjects.ThemeVO;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;
	
	public class element_themeDisplay extends Sprite
	{
		
		private var theme:ui_theme_display;
		
		public var themeVO:ThemeVO;
		public var isCurrentTheme:Boolean = false;
		public var hasUnlockedTheme:Boolean = false;
		
		private var _width:int = 0;
		private var _height:int = 0;
		
		public var share:Boolean = true;
		
		public function element_themeDisplay(themeVO:ThemeVO)
		{
			super();
			
			this.themeVO = themeVO;
			isCurrentTheme = (SettingsProxy.getInstance().currentTheme == themeVO.themeID);
			hasUnlockedTheme = (ProductsData.getInstance().doesUserHaveProduct(themeVO.themeID) > 0);
			
			this.scaleX = this.scaleY = DynamicConstants.MESSAGE_SCALE;
			
			addListeners();
			
			setupVisuals();
		}
		
		private function addListeners():void{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		private function setupVisuals():void{
			theme = new ui_theme_display();
			
			getfont(theme.txt_title, FontFaceType.BOLD);
			getfont(theme.txt_description, FontFaceType.REGULAR);
			getfont(theme.share_to_timeline.txt_share, FontFaceType.REGULAR);
			getfont(theme.selected.txt_selected_label, FontFaceType.BOLD);
			
			_width = theme.width*scaleX;
			_height = theme.height*scaleY;
			theme.txt_title.text = gettext("themes_theme_title_suffix", {themename:themeVO.themeName});
			theme.selected.txt_selected_label.text = gettext("themes_theme_selected");
			theme.selected.visible = isCurrentTheme;
			if(hasUnlockedTheme){
				theme.share_to_timeline.visible = false;
				theme.txt_description.text = gettext("themes_unlock_description_unlocked");
			}
			else{
				theme.share_to_timeline.txt_share.text = gettext("summary_screen_share");
				theme.share_to_timeline.tick.addEventListener(MouseEvent.MOUSE_UP, handleTick);
				theme.share_to_timeline.blob.mouseEnabled = false;
				theme.share_to_timeline.blob.mouseChildren = false;
				theme.txt_description.text = gettext("themes_unlock_description_"+themeVO.themeID);
			}
			
			var thumbGuideline:ui_themeThumbGuideline = new ui_themeThumbGuideline();
			
			var themeThumbClass:Class = getDefinitionByName(themeVO.themeID + "_thumb") as Class;
			
			var themeThumb:MovieClip = new themeThumbClass() as MovieClip;
			thumbGuideline.width = theme.background.width - 8;
			themeThumb.scaleX = themeThumb.scaleY = thumbGuideline.scaleX
			themeThumb.x = theme.background.x + 4;
			themeThumb.y = theme.background.y + 4;
			themeThumb.cacheAsBitmap = true;
			theme.addChild(themeThumb);
			
			this.addChild(theme);
		}
		
		private function handleTick(e:MouseEvent):void{
			if(theme.share_to_timeline.blob.visible){
				theme.share_to_timeline.blob.visible = false;
				share = false;
			}
			else{
				theme.share_to_timeline.blob.visible = true;
				share = true;
			}
		}
		
		private function destroy(e:Event):void{
			if(theme.share_to_timeline.tick.hasEventListener(MouseEvent.MOUSE_UP)){
				LOG.debug("Removed Share Button Listeners");
				theme.share_to_timeline.tick.addEventListener(MouseEvent.MOUSE_UP, handleTick);
			}
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
		}
		
		public function purchased():void{
			theme.share_to_timeline.visible = false;
			this.hasUnlockedTheme = true;
			if(hasUnlockedTheme){
				theme.txt_description.text = gettext("themes_unlock_description_unlocked");
			}
			else{
				theme.txt_description.text = gettext("themes_unlock_description_"+themeVO.themeID);
			}
		}
		public function selected(isSelected:Boolean):void{
			this.isCurrentTheme = isSelected;
			theme.selected.visible = isCurrentTheme;
		}
		
		public function getWidth():Number{
			return _width;
		}
		public function getHeight():Number{
			return _height;
		}
	}
}