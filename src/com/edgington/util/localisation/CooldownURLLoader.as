package com.edgington.util.localisation
{
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	/**
	 * An extension of the URLLoader Class which will attempt to make multiple calls to the endPoint should the
	 * previous call fail due to an IOErrorEvent.IO_ERROR or SecurityErrorEvent.SECURITY_ERROR with a cooldown period
	 * between each call.
	 * Also contains a timeout to deal with no response from the server.
	 * Usage is exactly the same as the URLLoader class as the Error Events will only be dispatched
	 * after the list of cooldown intervals have been exhausted.
	 */
	public class CooldownURLLoader extends URLLoader
	{

		
		private static const UNIQUE_RETRY_NAME : String = "iwi_retry";
		
		private var _request : URLRequest;
		
		//Intervals to cooldown between re-trys
		private var _cooldowns : Vector.<int> = Vector.<int>([ 750, 1250, 2000 ]);
		private var _cooldownTimer : Timer;
		private var _retries : uint;
		
		//Timeout for the request. NOTE: This is reset on each failure, so will only timeout if one of the requests never responds.
		private var _timeoutDuration : uint = 15000;
		private var _timeoutTimer : Timer;
		
		
		public function CooldownURLLoader(request : URLRequest = null)
		{
			super(request);
			_request = request;
		}

		override public function load(request : URLRequest) : void
		{
			addRequestEventListeners();
			_request = request;
			super.load(request);
			resetTimeout();
		}
		
		override public function close():void
		{
			cleanup();
			super.close();
		}

		public function set cooldowns(v : Vector.<int>) : void
		{
			if(!v)
			{
				throw new ArgumentError("Cooldowns cannot be null");
			}
			_cooldowns = v.concat();
		}

		public function set timeoutDuration(milliseconds : uint) : void
		{
			_timeoutDuration = milliseconds;
			timeoutTimer.delay = milliseconds;
			if(timeoutTimer.running)
			{
				resetTimeout();
			}
		}

		/**
		 * The loaders URLRequest.
		 */
		public function get urlRequest() : URLRequest
		{
			return _request;
		}

		/**
		 * Intercepts an ErrorEvent.
		 * If we have cooldowns left, stops event propegation and starts cooldown to retry.
		 */
		private function handleRequestError(e : ErrorEvent) : void
		{
			if(isRetryAvailable())
			{
				log("Failed, cooling down");
				// Stop the event from being propigated to listeners.
				e.stopImmediatePropagation();
				timeoutTimer.stop();

				//Cooldown and try again.
				cooldown(nextRetry());
			}
			else
			{
				//Let the event propegate
				log("The last retry failed");
				cleanup();
			}
		}

		/**
		 * Closes current request and retrys if we have cooldowns left.
		 * NOTE: We do not wait for the cooldown periond after a timeout.
		 */
		private function handleTimeout(e : TimerEvent) : void
		{
			log("Timeout");
			close();
			cleanup();
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "Request to " + urlRequest.url + " timed out."));
		}
		
		private function handleSecurityError(e : SecurityErrorEvent) : void
		{
			log("Security error");
			cleanup();
		}

		private function handleRequestComplete(e : Event) : void
		{
			log("Complete");
			cleanup();
		}

		private function handleProgress(e : ProgressEvent) : void
		{
			//log("progress");
			resetTimeout();
		}
		
		private function resetTimeout() : void
		{
			timeoutTimer.reset();
			timeoutTimer.start();
		}
		
		private function cleanup() : void
		{
			clearLoadTimers();
			removeRequestEventListeners();
		}
		
		private function isRetryAvailable() : Boolean
		{
			return _cooldowns.length > 0;
		}
		
		private function nextRetry() : int
		{
			return _cooldowns.shift();
		}
		
		private function retry() : void
		{
			load(makeRequestUnique(_request));
		}
				
		/**
		 * Cache busts the request if it has failed.
		 */
		private function makeRequestUnique(urlRequest : URLRequest) : URLRequest
		{
			const urlParam : String = UNIQUE_RETRY_NAME + "=";
			
			//If the querystring is set via URLVariables need to set the parameter here.
			if(urlRequest.method == URLRequestMethod.GET && (urlRequest.data is URLVariables) )
			{
				const variables : URLVariables = urlRequest.data as URLVariables;
				variables[UNIQUE_RETRY_NAME] = ++_retries;
			}
			//If it has already been added to the URL at some stage update it.
			else if(urlRequest.url.indexOf(urlParam) > -1)
			{
				urlRequest.url = StringTools.replace(urlRequest.url, urlParam+_retries, urlParam+(++_retries));
			}
			//Add it to the URL
			else
			{
				const delim : String = urlRequest.url.indexOf("?") == -1 ? "?" : "&";
				urlRequest.url = urlRequest.url + delim + urlParam + (++_retries);
			}
			return urlRequest;
		}

		private function cooldown(cooldown : int) : void
		{
			cooldownTimer.delay = cooldown;
			cooldownTimer.reset();
			cooldownTimer.start();
		}
		
		private function handleCooldownComplete(e : TimerEvent) : void
		{
			retry();
		}
		
		private function addRequestEventListeners() : void
		{
			addEventListener(Event.COMPLETE, handleRequestComplete, false, int.MAX_VALUE);
			addEventListener(IOErrorEvent.IO_ERROR, handleRequestError, false, int.MAX_VALUE);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityError, false, int.MAX_VALUE);
			addEventListener(ProgressEvent.PROGRESS, handleProgress, false, int.MAX_VALUE);
		}
		
		private function removeRequestEventListeners() : void
		{
			removeEventListener(Event.COMPLETE, handleRequestComplete);
			removeEventListener(IOErrorEvent.IO_ERROR, handleRequestError);
			removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityError);
			removeEventListener(ProgressEvent.PROGRESS, handleProgress);
		}
		
		private function clearLoadTimers() : void
		{
			//Wrapped in if statement as if we have never created a cooldownTimer, there is nothing to clean up. 
			if(_cooldownTimer)
			{
				cooldownTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, handleCooldownComplete);
				cooldownTimer.stop();
				_cooldownTimer = null;
			}
			//Timeout timer is created at startup so will always be present.
			timeoutTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, handleTimeout);
			timeoutTimer.stop();
			_timeoutTimer = null;
		}

		private function get timeoutTimer() : Timer
		{
			if(!_timeoutTimer)
			{
				_timeoutTimer = new Timer(_timeoutDuration, 1);
				_timeoutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleTimeout);
			}
			return _timeoutTimer;
		}
		
		private function get cooldownTimer() : Timer
		{
			if(!_cooldownTimer)
			{
				_cooldownTimer = new Timer(1000, 1);
				_cooldownTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleCooldownComplete);
			}
			return _cooldownTimer;
		}
		
		private function log(message : String) : void
		{
		}
	}
}
