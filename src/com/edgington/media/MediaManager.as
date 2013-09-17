package com.edgington.media
{
	import com.edgington.NativeMediaManager.NativeMediaDirectory;
	import com.edgington.NativeMediaManager.NativeMediaManager;
	import com.edgington.NativeMediaManager.NativeMediaManagerEvent;
	import com.edgington.NativeMediaManager.NativeMediaVO;
	import com.edgington.model.events.AudioEvent;
	import com.edgington.util.debug.LOG;
	import com.greensock.TweenLite;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	
	import org.osflash.signals.Signal;

	public class MediaManager extends EventDispatcher
	{
		private static var _INSTANACE:MediaManager;
		private var mediaPicker:NativeMediaManager;
		public var trackData:NativeMediaVO;
		
		public var sound:Sound;
		
		private var processTime:Date;
		private var trackFileSize:Number;
		
		private var trackStatusSignal:Signal;
		
		public function MediaManager(e:SingletonEnforcer)
		{
			
		}
		
		public static function OpenMediaPicker():Signal{
			INSTANCE.trackStatusSignal = new Signal();
			INSTANCE.mediaPicker = new NativeMediaManager(NativeMediaDirectory.APPLICATION_CACHE_DIR);
			TweenLite.delayedCall(1, INSTANCE.displayMediaPicker);
			return INSTANCE.trackStatusSignal;
		}
		
		public function displayMediaPicker():void{
			mediaPicker.showMediaPicker();
			mediaPicker.addEventListener(NativeMediaManagerEvent.MEDIA_PICKER_PICKED, trackSelected);
			mediaPicker.addEventListener(NativeMediaManagerEvent.MEDIA_PICKER_EVENT_IMPORT_COMPLETE, importComplete);
			mediaPicker.addEventListener(NativeMediaManagerEvent.MEDIA_PICKER_EVENT_IMPORT_ERROR, importFailed);
			mediaPicker.addEventListener(NativeMediaManagerEvent.MEDIA_PICKER_EVENT_ITUNES_PROTECTED, importProtected);
			mediaPicker.addEventListener(NativeMediaManagerEvent.MEDIA_PICKER_CANCELLED, trackSelectionCanceled);
			
			mediaPicker.addEventListener(NativeMediaManagerEvent.MEDIA_PICKER_EVENT_CONVERTING_STARTED, handleConversionStarted);
			mediaPicker.addEventListener(NativeMediaManagerEvent.MEDIA_PICKER_EVENT_CONVERTING_PROGRESS, handleConversionProgress);
			mediaPicker.addEventListener(NativeMediaManagerEvent.MEDIA_PICKER_EVENT_CONVERTING_COMPLETE, handleConversionComplete);
			
		}
		
		private function trackSelected(e:NativeMediaManagerEvent):void{
			processTime = new Date();
			trackData = e.trackData;
			
			trackStatusSignal.dispatch(AudioEvent.TRACK_IMPORTING, 0);
			
			LOG.debug("Importing new track from iPod Library: " + e.trackData.trackTitle + " by " + e.trackData.artistName);
		}
		
		private function importFailed(e:NativeMediaManagerEvent):void{
			removeMediaPickerEvents();
			LOG.fatal("There was an import error");
			if(trackStatusSignal != null){
				trackStatusSignal.dispatch(AudioEvent.TRACK_ERROR_IMPORTING);
			}
		}
		
		private function importProtected(e:NativeMediaManagerEvent):void{
			removeMediaPickerEvents();
			LOG.error("The selected track is either protected or on ithe cloud");
			if(trackStatusSignal != null){
				trackStatusSignal.dispatch(AudioEvent.TRACK_ERROR_PROTECTED);
			}
		}
		
		private function handleConversionStarted(e:NativeMediaManagerEvent):void{
			trackStatusSignal.dispatch(AudioEvent.TRACK_NEEDS_CONVERSION);
		}
		private function handleConversionProgress(e:NativeMediaManagerEvent):void{
			trackStatusSignal.dispatch(AudioEvent.TRACK_CONVERSION_PROGRESS, e.progress);
		}
		private function handleConversionComplete(e:NativeMediaManagerEvent):void{
			trackStatusSignal.dispatch(AudioEvent.TRACK_CONVERSION_COMPLETE);
			importComplete(null);
		}
		
		
		private function trackSelectionCanceled(e:NativeMediaManagerEvent):void{
			if(trackStatusSignal != null){
				trackStatusSignal.dispatch(AudioEvent.TRACK_SELECTION_CANCELED);
			}
		}
		
		private function importComplete(e:NativeMediaManagerEvent):void{
			removeMediaPickerEvents();
			
			LOG.info(trackData.trackTitle + " has been imported, loading sound file...")
			
			sound = new Sound();
			sound.addEventListener(ProgressEvent.PROGRESS, soundLoadProgress);
			sound.addEventListener(Event.COMPLETE, soundHasLoaded);
			sound.load(new URLRequest(trackData.URL));
		}
		
		private function soundHasLoaded(e:Event):void{
			sound.removeEventListener(ProgressEvent.PROGRESS, soundLoadProgress);
			sound.removeEventListener(Event.COMPLETE, soundHasLoaded);
			LOG.info("Sound file size: " + Math.round(trackFileSize*100)/100 + "MB.");
			LOG.info("Sound Imported and Loaded in " + (new Date().time - processTime.time) + " milliseonds");
			
			trackStatusSignal.dispatch(AudioEvent.TRACK_LOADED, 0);
		}
		
		private function soundLoadProgress(e:ProgressEvent):void{
			LOG.info("Loading Sound File..."+Math.floor((e.bytesLoaded/e.bytesTotal)*100)+"%");
			trackStatusSignal.dispatch(AudioEvent.TRACK_IMPORTING, e.bytesLoaded/e.bytesTotal);
			trackFileSize = (e.bytesTotal/1024)/1024;
		}
		
		private function removeMediaPickerEvents():void{
			mediaPicker.removeEventListener(NativeMediaManagerEvent.MEDIA_PICKER_PICKED, trackSelected);
			mediaPicker.removeEventListener(NativeMediaManagerEvent.MEDIA_PICKER_EVENT_IMPORT_COMPLETE, importComplete);
			mediaPicker.removeEventListener(NativeMediaManagerEvent.MEDIA_PICKER_EVENT_IMPORT_ERROR, importFailed);
			mediaPicker.removeEventListener(NativeMediaManagerEvent.MEDIA_PICKER_EVENT_ITUNES_PROTECTED, importProtected);
			mediaPicker.removeEventListener(NativeMediaManagerEvent.MEDIA_PICKER_CANCELLED, trackSelectionCanceled);
			
			mediaPicker.removeEventListener(NativeMediaManagerEvent.MEDIA_PICKER_EVENT_CONVERTING_STARTED, handleConversionStarted);
			mediaPicker.removeEventListener(NativeMediaManagerEvent.MEDIA_PICKER_EVENT_CONVERTING_PROGRESS, handleConversionProgress);
			mediaPicker.removeEventListener(NativeMediaManagerEvent.MEDIA_PICKER_EVENT_CONVERTING_COMPLETE, handleConversionComplete);
		}
		
		public static function get INSTANCE():MediaManager{
			if(_INSTANACE == null){
				_INSTANACE = new MediaManager(new SingletonEnforcer);
			}
			return _INSTANACE;
		}
	}
}

class SingletonEnforcer{
	
}