package com.edgington.view.huds.elements
{
	import com.edgington.constants.DynamicConstants;
	import com.edgington.types.FontFaceType;
	import com.edgington.util.localisation.getfont;
	import com.edgington.util.localisation.gettext;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.text.TextFieldType;
	
	import org.osflash.signals.Signal;
	
	public class element_searchIpad extends Sprite
	{
		
		private var search:ui_ipad_searchbox;
		
		private var noText:String;
		
		private var searchSignal:Signal;
		
		public function element_searchIpad(searchSignal:Signal)
		{
			super();
			
			this.searchSignal  = searchSignal;
			
			search = new ui_ipad_searchbox();
			
			getfont(search.txt_search, FontFaceType.BOLD);
			
			noText = gettext("highscores_search_template");
			search.txt_search.text = noText;
			search.txt_search.addEventListener(FocusEvent.FOCUS_IN, readyForText);
			search.txt_search.addEventListener(FocusEvent.FOCUS_OUT, checkFocusOut);
			search.txt_search.addEventListener(KeyboardEvent.KEY_DOWN,handleComplete);
			search.scaleX = search.scaleY = DynamicConstants.BUTTON_SCALE*0.75;
			this.addChild(search);
			
			enabledSearchTextBox();
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		private function readyForText(e:FocusEvent):void{
			if(search.txt_search.text == noText){
				search.txt_search.text = "";
				search.txt_search.alpha = 1;
			}
		}
		
		private function checkFocusOut(e:FocusEvent):void{
			checkForCharacters();
		}
		
		private function enabledSearchTextBox():void{
			search.txt_search.type = TextFieldType.INPUT;
			search.txt_search.alpha = 0.3;
		}
		
		private function textInput(e:TextEvent):void{
			if(search.txt_search.text == noText){
				search.txt_search.alpha = 1;
				search.txt_search.text = "";
			}
		}
		
		private function handleComplete(e:KeyboardEvent):void{
			if(e.charCode == 13){
				checkForCharacters();
				if(search.txt_search.text != noText){
					searchSignal.dispatch(search.txt_search.text);
				}
			}
		}
		
		private function textFieldChanged(e:Event):void{
			checkForCharacters();
		}
		
		private function checkForCharacters():void{
			if(search.txt_search.text == ""){
				search.txt_search.alpha = 0.3;
				search.txt_search.text = noText;
			}
		}
		
		public function refreshSearch():void{
			search.txt_search.alpha = 0.3;
			search.txt_search.text = noText;
		}
		
		private function destroy(e:Event):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			searchSignal.removeAll();
		}
	}
}

