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
			peaks = AudioMainModel.getInstance().getSoundChannelPeaks()
			return (peaks.left + peaks.right) *.5
		}
	}
}