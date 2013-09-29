package com.edgington.model.sound
{
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.ByteArray;

	
	public class SoundPitchShifter
	{
		private const BLOCK_SIZE: int = 3072;
		
		private var _mp3: Sound;
		private var _sound: Sound;
		
		private var _target: ByteArray;
		
		private var _position: Number;
		private var _rate: Number;
		private var repeat:SoundChannel;
		private var _volume:Number = 1;
		private var byteArray:ByteArray;
		
		// Pass in your looped Sound
		public function SoundPitchShifter( pitchedSound: Sound)
		{
			_target = new ByteArray();
			_mp3 =  pitchedSound;
			
			_position = 2257.0;
			_rate = 0.0;
			
			_sound = new Sound();
			_sound.addEventListener( SampleDataEvent.SAMPLE_DATA, sampleData );
			repeat = _sound.play();
		}
		
		public function get rate(): Number
		{
			return _rate;
		}
		
		// Also added a handy volume setter
		public function set volume( value: Number ): void
		{
			_volume = value;
			repeat.soundTransform = new SoundTransform(_volume);
		}
		
		// use this to set the pitch of your sound
		public function set rate( value: Number ): void
		{
			if( value < 0.0 ){
				value = 0;
			}
			
			_rate =  value;
		}
		
		private function sampleData( event: SampleDataEvent ): void
		{
			//-- REUSE INSTEAD OF RECREATION
			_target.position = 0;
			
			//-- SHORTCUT
			var data: ByteArray = event.data;
			
			var scaledBlockSize: Number = BLOCK_SIZE * _rate;
			var positionInt: int = _position;
			var alpha: Number = _position - positionInt;
			
			var positionTargetNum: Number = alpha;
			var positionTargetInt: int = -1;
			
			//-- COMPUTE NUMBER OF SAMPLES NEED TO PROCESS BLOCK (+2 FOR INTERPOLATION)
			var need: int = Math.ceil( scaledBlockSize ) + 2;
			
			//-- EXTRACT SAMPLES
			var read: int = _mp3.extract( _target, need, positionInt );
			
			var n: int = read == need ? BLOCK_SIZE : read / _rate;
			
			var l0: Number;
			var r0: Number;
			var l1: Number;
			var r1: Number;
			
			for( var i: int = 0 ; i < n ; ++i )
			{
				//-- AVOID READING EQUAL SAMPLES, IF RATE < 1.0
				if( int( positionTargetNum ) != positionTargetInt )
				{
					positionTargetInt = positionTargetNum;
					
					//-- SET TARGET READ POSITION
					_target.position = positionTargetInt << 3; 	 					
					//-- READ TWO STEREO SAMPLES FOR LINEAR INTERPOLATION 					
					l0 = _target.readFloat(); 					
					r0 = _target.readFloat(); 					
					l1 = _target.readFloat(); 					
					r1 = _target.readFloat(); 				
				} 				 				
				//-- WRITE INTERPOLATED AMPLITUDES INTO STREAM 				
				data.writeFloat( l0 + alpha * ( l1 - l0 ) ); 				
				data.writeFloat( r0 + alpha * ( r1 - r0 ) ); 				 				
				//-- INCREASE TARGET POSITION 				
				positionTargetNum += _rate; 				 				
				//-- INCREASE FRACTION AND CLAMP BETWEEN 0 AND 1 				
				alpha += _rate; 				
				while( alpha >= 1.0 ) --alpha;
			}
				
			//-- FILL REST OF STREAM WITH ZEROs
			if( i < BLOCK_SIZE )
			{
				while( i < BLOCK_SIZE ) { 					
					data.writeFloat( 0.0 ); 					
					data.writeFloat( 0.0 ); 					 					
					++i; 				
				} 			
			} 			
			//-- INCREASE SOUND POSITION 			
			_position += scaledBlockSize;                        
			// My little addition here: 			
			if (_position > _mp3.length * 44.1) {
				_position = 0;
				_target.position = 0;
			}
		}
		
		public function destroy():void{
			rate = 0;
			repeat.stop();
			repeat = null;
			_mp3 = null;
			_sound.removeEventListener( SampleDataEvent.SAMPLE_DATA, sampleData );
			_sound = null;
			_target.clear();
			_target = null;
		}
	}
}