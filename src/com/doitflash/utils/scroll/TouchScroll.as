package com.doitflash.utils.scroll
{
	
	
	
	import com.doitflash.consts.Orientation;
	import com.doitflash.consts.ScrollConst;
	import com.doitflash.events.ScrollEvent;
	import com.edgington.control.Control;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.plugins.ThrowPropsPlugin;
	import com.greensock.plugins.TweenPlugin;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	
	public class TouchScroll extends MouseScroll
	{
		
		
		TweenPlugin.activate([ThrowPropsPlugin]);
		
		
		private var _time1:uint, _time2:uint;
		private var _y1:Number, _y2:Number, _yOverlap:Number, _yOffset:Number;
		private var _x1:Number, _x2:Number, _xOverlap:Number, _xOffset:Number;
		
		private var _isMouseMoved:Boolean = false;
		private var _holdAreaPoints:Object;
		
		public var _isHoldAreaDone:Boolean = false;
		
		
		protected var _isTouchScroll:Boolean = true;
		protected var _isStickTouch:Boolean = false;
		protected var _holdArea:Number = 0;
		protected var _doMouseUpScroll:Boolean = true; // DO NOT MODIFY THIS VALUE
		
		
		
		public function TouchScroll():void
		{	
			
		}
		

		override protected function start(e:Event = null):void
		{
			super.start(e);
			
			// let's set the settings
			if (_isTouchScroll) setTouchSettings();
		}

		override protected function finish(e:Event = null):void
		{
			_maskHolder.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			_maskHolder.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			TweenLite.killTweensOf(_maskContentHolder); 
			TweenLite.killDelayedCallsTo(Control.disableMouseFunc);
			Control.disableMouse = false;
			_holdAreaPoints = null;
			
			super.finish(e);
		}
		
		
		private function setTouchSettings():void
		{
			_maskHolder.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
		}
		
		public function mouseDownHandler(e:MouseEvent = null):void
		{
			TweenLite.killTweensOf(_maskContentHolder); // kill tweens, because every time with mouse down we want to make a new move, so kill the last moves
			this.removeEventListener(Event.ENTER_FRAME, contentMover); // so if the item size changes at the same time, it won't be conflicted with our move
			
			// it doesn't matter what's the _orientation mode, we don't do anything epecial here, we just set the variables
			scrollVSetting();
			scrollHSetting();
			
			function scrollVSetting():void
			{
				_y1 = _y2 = _maskContentHolder.y;
				_yOffset = mouseY - _maskContentHolder.y;
				_yOverlap = Math.max(0, _maskContent.height - _maskHeight);
				_time1 = _time2 = getTimer();
			}
			
			function scrollHSetting():void
			{
				_x1 = _x2 = _maskContentHolder.x;
				_xOffset = mouseX - _maskContentHolder.x;
				_xOverlap = Math.max(0, _maskContent.width - _maskWidth);
				_time1 = _time2 = getTimer();
			}
			
			if (!_holdAreaPoints) _holdAreaPoints = { };
			_holdAreaPoints.x = mouseX;
			_holdAreaPoints.y = mouseY;
			_isHoldAreaDone = false; // so that mouseMoveHandler() would check the _holdArea
			Control.disableMouse = true;
			
			_maskHolder.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
			
			this.dispatchEvent(new ScrollEvent(ScrollEvent.MOUSE_DOWN));
		}
		
		private function mouseMoveHandler(e:MouseEvent):void
		{
			this.dispatchEvent(new ScrollEvent(ScrollEvent.MOUSE_MOVE));
			
			var diff:Number;
			
			// we set settings based on _orientation NOT on _hScroll or _vScroll, because even if the content dimentions are less than than the mask, we like the TouchScroll to work anyway
			if (_orientation == Orientation.VERTICAL) 
			{
				if (!_isHoldAreaDone)
				{
					diff = _holdAreaPoints.y - mouseY;
					diff = Math.sqrt(Math.pow(diff, 2)); // set to always get positive number
					if (diff < _holdArea) return; // if user is moving around and still didn't move so much to get out of the _holdArea boundaries, don't do the scroll animation
				}
				
				scrollVSetting();
			}
			else if (_orientation == Orientation.HORIZONTAL) 
			{
				if (!_isHoldAreaDone)
				{
					diff = _holdAreaPoints.x - mouseX;
					diff = Math.sqrt(Math.pow(diff, 2)); // set to always get positive number
					if (diff < _holdArea) return; // if user is moving around and still didn't move so much to get out of the _holdArea boundaries, don't do the scroll animation
				}
				
				scrollHSetting();
			}
			else // if it was AUTO
			{
				if (!_isHoldAreaDone)
				{
					// set diff 2 time according to x and y, so that if user moves in any direction, the diff amount will be added 
					diff = _holdAreaPoints.y - mouseY;
					diff += _holdAreaPoints.x - mouseX;
					diff = Math.sqrt(Math.pow(diff, 2)); // set to always get positive number
					if (diff < _holdArea) return; // if user is moving around and still didn't move so much to get out of the _holdArea boundaries, don't do the scroll animation
				}
				
				scrollVSetting();
				scrollHSetting();
			}
			
			function scrollVSetting():void
			{
				//if maskContent's position exceeds the bounds, make it drag only half as far with each mouse movement (like iPhone/iPad behavior)
				var y:Number = mouseY - _yOffset;
				if (y > 0) 
				{
					if (_isStickTouch) _maskContentHolder.y = 0;
					else _maskContentHolder.y = (y + 0) * 0.5;
				}
				else if (y < 0 - _yOverlap) 
				{
					if (_isStickTouch) _maskContentHolder.y = (- _yOverlap);
					else _maskContentHolder.y = (y + 0 - _yOverlap) * 0.5;
				}
				else 
				{
					_maskContentHolder.y = y;
				}
				
				//if the frame rate is too high, we won't be able to track the velocity as well, so only update the values 20 times per second
				var t:uint = getTimer();
				
				if (t - _time2 > 50)
				{
					_y2 = _y1;
					_time2 = _time1;
					_y1 = _maskContentHolder.y;
					_time1 = t;
				}
				
				setYPercAndSpeed(); // to analyze _yPerc and speed if blur effect was true
			}
			
			function scrollHSetting():void
			{
				//if maskContent's position exceeds the bounds, make it drag only half as far with each mouse movement (like iPhone/iPad behavior)
				var x:Number = mouseX - _xOffset;
				if (x > 0) 
				{
					if (_isStickTouch) _maskContentHolder.x = 0;
					else _maskContentHolder.x = (x + 0) * 0.5;
				}
				else if (x < 0 - _xOverlap) 
				{
					if (_isStickTouch) _maskContentHolder.x = (- _xOverlap);
					else _maskContentHolder.x = (x + 0 - _xOverlap) * 0.5;
				}
				else 
				{
					_maskContentHolder.x = x;
				}
				
				//if the frame rate is too high, we won't be able to track the velocity as well, so only update the values 20 times per second
				var t:uint = getTimer();
				if (t - _time2 > 50)
				{
					_x2 = _x1;
					_time2 = _time1;
					_x1 = _maskContentHolder.x;
					_time1 = t;
				}
				
				setXPercAndSpeed(); // to analyze _xPerc and speed if blur effect was true
			}
			
			
			// there's no need to add a little amount to _yLoc or _xLoc too, so that they can be set later in contentMover(),
			// because there's no contentMover() onEnterFrame at all... or there's no need to set them after the percent, because it has no use!
			// we just simply add a little amount to them once when the touch scroll is finished and we also have added contentMover() onEnterFrame too in onTweenComplete()
			
			if (_bitmapMode == ScrollConst.NORMAL) 
			{
				_mask.bitmapMode = true;
				
				if (this._updateMask == true) // if content size has been changed and we have set _updateMask to true in contentMover()
				{
					
					if (this._maskAutoForceUpdate)
					{
						_mask.update(null, true); // force update to create a brand new bitmap from the changed content
					}
					
					this._updateMask = false; // set it to false again
				}
			}
			
			_mask.update();
			e.updateAfterEvent();
			
			_isHoldAreaDone = true; // so that it won't check _holdArea next time that we move if we got back to its boundaries, because we don't like it to stop our scroll animation unless we release our touch and touch to move again
			_isMouseMoved = true;
		}
		
		public function mouseUpHandler(e:MouseEvent = null):void
		{
			this.dispatchEvent(new ScrollEvent(ScrollEvent.MOUSE_UP));
			
			_maskHolder.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			
			if (!_isMouseMoved) // user didn't move the scroll and only made a click, so add onEnterFrame function and don't do the scroll animation by breaking this function
			{
				Control.disableMouse = false;
				this.addEventListener(Event.ENTER_FRAME, contentMover, false, 0, true);
				return;
			}
			if(!_isHoldAreaDone){
				Control.disableMouse = false;
			}
			
			TweenLite.delayedCall(0.5, Control.disableMouseFunc, [false]);
			
			// user didn't just make a click on scroll and _isMouseMoved is true, so set the scroll animation settings
			if (!_doMouseUpScroll) return; // if it was false pause everything untill the user himself set it to true manually again
			// NOTE: he have set it to false maybe because he changed the stage.frameRate to 1 on mouse down and don't want the up animation to run on mouse up untill he changes the stage.frameRate again and then call this.doMouseUpScroll setter to do the mouse up scroll
			
			doMouseUpAni();
		}
		private function doMouseUpAni():void
		{
			var time:Number = (getTimer() - _time2) / 1000;
			var yVelocity:Number = (_maskContentHolder.y - _y2) / time;
			var xVelocity:Number = (_maskContentHolder.x - _x2) / time;
			
			// set animation tolerance amount accroding to _isStickTouch is true or false
			var tolerance:Object = { minDuration:(_isStickTouch) ? 0: .3, 
				overShoot:(_isStickTouch) ? 0: 1 };
			
			ThrowPropsPlugin.to(_maskContentHolder, {throwProps:{
				y:{velocity:yVelocity, max:_maskHolder.y, min:_maskHolder.y - _yOverlap, resistance:300},
				x:{velocity:xVelocity, max:_maskHolder.x, min:_maskHolder.x - _xOverlap, resistance:300}
			}, onUpdate:onTweenUpdate, onComplete:onTweenComplete, ease:_easeTypeFunc
			}, 10, tolerance.minDuration, tolerance.overShoot);
		}
		
		
		protected function onTweenUpdate():void
		{
			if (_orientation == Orientation.VERTICAL) setYPercAndSpeed();
			else if (_orientation == Orientation.HORIZONTAL) setXPercAndSpeed();
			else // if it was AUTO
			{
				setYPercAndSpeed();
				setXPercAndSpeed();
			}
			
			_mask.update();
			
			this.dispatchEvent(new ScrollEvent(ScrollEvent.TOUCH_TWEEN_UPDATE));
		}
		
		protected function onTweenComplete():void
		{
			if (_orientation == Orientation.VERTICAL)
			{
				setYPercAndSpeed();
				
				if (_vScroll) // because if the content is smaller than the mask scroll, we shouldn't add a little amount to _yLoc, because it won't be set to its real amount in contentMover() at this situation
				{
					_isYPercManual = true; // to set _yLoc according to _yPerc at contentMover() as we have the percent at mouseMoveHandler()
					_yLoc += .5;
				}
				
			}
			else if (_orientation == Orientation.HORIZONTAL)
			{
				setXPercAndSpeed();
				
				if (_hScroll) // because if the content is smaller than the mask scroll, we shouldn't add a little amount to _xLoc, because it won't be set to its real amount in contentMover() at this situation
				{
					_isXPercManual = true; // to set _xLoc according to _xPerc at contentMover() as we have the percent at mouseMoveHandler()
					_xLoc += .5;
				}
				
			}
			else // if it was AUTO
			{
				setYPercAndSpeed();
				
				if (_vScroll) // because if the content is smaller than the mask scroll, we shouldn't add a little amount to _yLoc, because it won't be set to its real amount in contentMover() at this situation
				{
					_isYPercManual = true;
					_yLoc += .5;
				}
				
				
				setXPercAndSpeed();
				
				if (_hScroll) // because if the content is smaller than the mask scroll, we shouldn't add a little amount to _xLoc, because it won't be set to its real amount in contentMover() at this situation
				{
					_isXPercManual = true;
					_xLoc += .5;
				}
			}
			Control.disableMouse = false;
			if (_bitmapMode == ScrollConst.NORMAL || _bitmapMode == ScrollConst.WEAK) _mask.bitmapMode = false;
			_isMouseMoved = false;
			this.addEventListener(Event.ENTER_FRAME, contentMover, false, 0, true);
			this.dispatchEvent(new ScrollEvent(ScrollEvent.TOUCH_TWEEN_COMPLETE));
		}
		
		private function setYPercAndSpeed():void
		{
			var diff:Number = _maskContent.height - _maskHeight; // the different amount between the 2 heights
			
			var currY: Number = Math.sqrt(Math.pow(_maskContentHolder.y, 2)); // set to always get positive number
			if (_maskContentHolder.y > 0) currY = 0; // if touch scroll was scratching at start ponint, set currY to 0 obviously
			else if ( (- _maskContentHolder.y) > diff) currY = diff; // if it was scratching at end ponint, set currY to diff obviously
			
			// if content is smaller than the mask, so we should not set the percent for no resean and change its default value obviously
			if (_vScroll) _yPerc = currY * 100 / diff; // Periodic Table-> diff / 100 = currY / ?
			
			
			var time:Number = (getTimer() - _time2) / 1000;
			var speed:Number = (_maskContentHolder.y - _y2) / time;
			speed = Math.sqrt(Math.pow(speed, 2)); // set to always get positive number
			_vSpeed = speed; // we have set _vSpeed ONLY for user, to get the scroll speed if needed
			speed = (speed / 10) / lessBlurSpeed; // to get less speed amount if we'd like to
			
			if (blurEffect && aniInterval != 0) TweenMax.to(_maskContentHolder, aniInterval, { blurFilter: { blurY:speed }, ease:_easeTypeFunc } );
		}
		
		private function setXPercAndSpeed():void
		{
			var diff:Number = _maskContent.width - _maskWidth; // the different amount between the 2 heights
			
			var currX: Number = Math.sqrt(Math.pow(_maskContentHolder.x, 2)); // set to always get positive number
			if (_maskContentHolder.x > 0) currX = 0; // if touch scroll was scratching at start ponint, set currY to 0 obviously
			else if ( (- _maskContentHolder.x) > diff) currX = diff; // if it was scratching at end ponint, set currY to diff obviously
			
			// if content is smaller than the mask, so we should not set the percent for no resean and change its default value obviously
			if (_hScroll) _xPerc = currX * 100 / diff; // Periodic Table-> diff / 100 = currY / ?
			
			
			var time:Number = (getTimer() - _time2) / 1000;
			var speed:Number = (_maskContentHolder.x - _x2) / time;
			speed = Math.sqrt(Math.pow(speed, 2)); // set to always get positive number
			_hSpeed = speed; // we have set _vSpeed ONLY for user, to get the scroll speed if needed
			speed = (speed / 10) / lessBlurSpeed; // to get less speed amount if we'd like to
			
			if (blurEffect && aniInterval != 0) TweenMax.to(_maskContentHolder, aniInterval, { blurFilter: { blurX:speed }, ease:_easeTypeFunc } );
		}
		
		
		
		
		override protected function onResize(e:*=null):void
		{
			super.onResize(e);
		}
		
		
		/**
		 * if <code>true</code>, we have touch scroll ability (touch scroll priority is higher than mouse scroll),
		 * if <code>false</code>, we don't have touch scroll ability.
		 */
		public function get isTouchScroll():Boolean
		{
			return _isTouchScroll;
		}
		
		public function set isTouchScroll(sc:Boolean):void
		{
			if(sc != _isTouchScroll)
			{
				_isTouchScroll = sc;
				
				_propSaver.isTouchScroll = _isTouchScroll; // pass the new value to the value of the object property
				
				if (stage) 
				{
					// mouseMove and mouseUp events which has been registered to _maskHolder will be removed automatically on mouseUp()
					if (!_isTouchScroll) _maskHolder.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
					else _maskHolder.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
				}
			}
		}
		
		/**
		 * if <code>true</code>, touch scroll is sticked if content position is at the start or end point of the mask,
		 * if <code>false</code>, touch scroll bounces when gets to the start or end point of the mask.
		 */
		public function get isStickTouch():Boolean
		{
			return _isStickTouch;
		}
		
		
		public function set isStickTouch(sc:Boolean):void
		{
			if(sc != _isStickTouch)
			{
				_isStickTouch = sc;
				
				_propSaver.isStickTouch = _isStickTouch; // pass the new value to the value of the object property
			}
		}
		
		/**
		 * indicates the hold area boundaries.
		 */
		public function get holdArea():Number
		{
			return _holdArea;
		}
		
		
		public function set holdArea(sc:Number):void
		{
			if(sc != _holdArea)
			{
				_holdArea = sc;
				
				_propSaver.holdArea = _holdArea; // pass the new value to the value of the object property
			}
		}
		
		
		
		
		
		public function get doMouseUpScroll():Boolean
		{
			return _doMouseUpScroll;
		}
		
		
		public function set doMouseUpScroll(a:Boolean):void
		{
			if(a != _doMouseUpScroll)
			{
				_doMouseUpScroll = a;
				
				_propSaver.doMouseUpScroll = _doMouseUpScroll; // pass the new value to the value of the object property
				
				if (stage && _doMouseUpScroll) // if user made _doMouseUpScroll true, now do the mouse up animation
				{
					doMouseUpAni();
				}
			}
		}
	}
}