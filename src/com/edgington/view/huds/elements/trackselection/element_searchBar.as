package com.edgington.view.huds.elements.trackselection
{
	import com.edgington.constants.SoundConstants;
	import com.edgington.model.SoundManager;
	import com.edgington.util.localisation.gettext;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextFieldType;
	
	import org.osflash.signals.Signal;
	
	public class element_searchBar extends Sprite
	{
		private var search:ui_track_selection_search_bar;
		
		private var searchSignal:Signal;
		
		private var noText:String;
		
		public function element_searchBar(searchSignal:Signal)
		{
			super();
			
			this.searchSignal = searchSignal;
			this.noText = gettext("track_search_default_search_text");
			
			addListeners();
			
			setupVisuals();
			this.cacheAsBitmap = true;
		}
		
		private function addListeners():void{
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		private function setupVisuals():void{
			search = new ui_track_selection_search_bar();
			search.txt_search.text = noText;
			search.cancel.visible = false;
			search.txt_search.addEventListener(FocusEvent.FOCUS_IN, readyForText);
			search.txt_search.addEventListener(FocusEvent.FOCUS_OUT, checkFocusOut);
			search.txt_search.addEventListener(KeyboardEvent.KEY_DOWN,handleComplete);
			search.cancel.addEventListener(MouseEvent.MOUSE_UP, clearSearch);
			
			
			this.addChild(search);
		}
		
		private function clearSearch(e:MouseEvent):void{
			refreshSearch();
		}
		
		private function readyForText(e:FocusEvent):void{
			if(search.txt_search.text == noText){
				search.txt_search.text = "";
				search.cancel.visible = true;
				search.txt_search.alpha = 1;
			}
		}
		
		private function checkFocusOut(e:FocusEvent):void{
			checkForCharacters();
		}
		
		private function enabledSearchTextBox():void{
			search.txt_search.type = TextFieldType.INPUT;
			//search.txt_search.alpha = 0.3;
		}
		
		private function textInput(e:TextEvent):void{
			if(search.txt_search.text == noText){
				search.txt_search.alpha = 1;
				search.cancel.visible = true;
				search.txt_search.text = "";
			}
		}
		
		private function handleComplete(e:KeyboardEvent):void{
			if(e.charCode == 13){
				checkForCharacters();
				if(search.txt_search.text != noText){
					SoundManager.getInstance().loadAndPlaySFX(SoundConstants.SFX_OPTION_SELECT, "", 1);
					searchSignal.dispatch(search.txt_search.text);
				}
			}
		}
		
		private function textFieldChanged(e:Event):void{
			checkForCharacters();
		}
		
		private function checkForCharacters():void{
			if(search.txt_search.text == ""){
				//search.txt_search.alpha = 0.3;
				search.cancel.visible = false;
				search.txt_search.text = noText;
				searchSignal.dispatch("");
			}
		}
		
		public function refreshSearch():void{
			//search.txt_search.alpha = 0.3;
			searchSignal.dispatch("");
			search.cancel.visible = false;
			search.txt_search.text = noText;
		}
		
		private function destroy(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			search.txt_search.removeEventListener(FocusEvent.FOCUS_IN, readyForText);
			search.txt_search.removeEventListener(FocusEvent.FOCUS_OUT, checkFocusOut);
			search.txt_search.removeEventListener(KeyboardEvent.KEY_DOWN,handleComplete);
			search.cancel.removeEventListener(MouseEvent.MOUSE_UP, clearSearch);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			searchSignal.removeAll();
			searchSignal = null;
			search = null;
		}
	}
}