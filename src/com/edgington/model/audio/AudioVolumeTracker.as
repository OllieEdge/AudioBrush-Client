package com.edgington.model.audio
{
	import com.edgington.valueobjects.SoundChannelPeaksVO;

	public class AudioVolumeTracker
	{
		
		private var peaks:SoundChannelPeaksVO
		
		public function AudioVolumeTracker()
		{
		}
		
		public function trackVolume() : Number
		{
			peaks = AudioModel.getInstance().getSoundChannelPeaks()
			return (peaks.left + peaks.right) *.5
		}
		
		public static function trackVolume():Number{
			var peaks:SoundChannelPeaksVO = AudioModel.getInstance().getSoundChannelPeaks()
			return (peaks.left + peaks.right) *.5
		}
	}
}