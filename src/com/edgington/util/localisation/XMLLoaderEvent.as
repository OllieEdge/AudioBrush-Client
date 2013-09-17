package com.edgington.util.localisation{
	import flash.events.Event;						

	public class XMLLoaderEvent extends Event {
		
		public static const COMPLETE : String = "onComplete";
		public static const IO_ERROR : String = "onIOError";
		public static const SECURITY_ERROR : String = "onSecurityError";
		public static const TIMEOUT : String = "onTimeout";
		
		public var xml : XML;
		public var url : String;
		public var errorMessage : String;
		
		public function XMLLoaderEvent(type:String, xml:XML=null, url:String=null, errorMessage:String=null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.xml = xml;
			this.url = url;
			this.errorMessage = errorMessage;
		}
		
		
		public override function clone() : Event {
			return new XMLLoaderEvent( type, xml, url, errorMessage, bubbles, cancelable );
		}
		
		
		public override function toString() : String {
			return formatToString("XMLLoaderEvent", "type", "xml", "url", "errorMessage", "bubbles", "cancelable", "eventPhase" );
		}
	}
	
}