package com.edgington.util.localisation{
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	[Event(name="onComplete", type="com.divisionfifteen.events.XMLLoaderEvent")]

	[Event(name="onIOError", type="com.divisionfifteen.events.XMLLoaderEvent")]

	[Event(name="onSecurityError", type="com.divisionfifteen.events.XMLLoaderEvent")]
	
	[Event(name="onTimeout", type="com.divisionfifteen.events.XMLLoaderEvent")]

	public class XMLLoader extends EventDispatcher {
		
		private var _urlLoader : CooldownURLLoader;
		
		public function XMLLoader() {
			super( );
		}

		
		/**
		 * Loads the requested XML from the URL provided.
		 * 
		 * @param url	The url of the XML to load.
		 */
		public function load( url : String ) : void {
			
			_urlLoader = new CooldownURLLoader();
			_urlLoader.addEventListener( Event.COMPLETE, onLoadComplete );
			_urlLoader.addEventListener( IOErrorEvent.IO_ERROR, handleIOError );
			_urlLoader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, handleSecurityError );
			
			_urlLoader.load( new URLRequest( url ) );
		}
		
		private function removeEventListeners():void
		{
			_urlLoader.removeEventListener( Event.COMPLETE, onLoadComplete );
			_urlLoader.removeEventListener( IOErrorEvent.IO_ERROR, handleIOError );
			_urlLoader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, handleSecurityError );
			
		}
		
		/**
		 * Handles successfull loading of the XML data.
		 */
		private function onLoadComplete( e : Event ) : void {
			removeEventListeners();
			
			try {
				var xml : XML = new XML( _urlLoader.data );
			} catch( err:Error ){
				dispatchEvent( new XMLLoaderEvent( XMLLoaderEvent.IO_ERROR, null, url, err.getStackTrace() ) );
				return;
			}
			
			dispatchEvent( new XMLLoaderEvent( XMLLoaderEvent.COMPLETE, xml, url ) );
		}
		
		
		/**
		 * Handles an IO error.
		 * This will attempt to load the file again for MAX_ATTEMPTS no of times after which IOError event is dispatched.
		 */
		private function handleIOError( e : IOErrorEvent ) : void {
			dispatchEvent( new XMLLoaderEvent( XMLLoaderEvent.IO_ERROR, null, url, e.text ) );
		}

		
		/**
		 * Handles a security error.
		 */
		private function handleSecurityError( e : SecurityErrorEvent ) : void {
			dispatchEvent( new XMLLoaderEvent( XMLLoaderEvent.SECURITY_ERROR, null, url, e.text ) );
		}
		
		
		public function get url() : String {
			return _urlLoader.urlRequest.url;
		}
	}
}