package com.edgington.model.audio.FFT
{

	public class FFT
	{
		public static const FORWARD:Boolean = false;
		public static const INVERSE:Boolean = true;
		
		private var m_logN:uint = 0;            // log2 of FFT size
		private var m_N:uint = 0;               // FFT size
		private var m_invN:Number;              // Inverse of FFT length
		
		private var m_X:Vector.<FFTElement>;  // Vector of linked list elements
		private var copyVector:Vector.<FFTElement>;  // Vector of linked list elements
		
		
		private var t:uint = 0;
		private var i:uint = 0;
		
		/**
		 *
		 */
		public function FFT()
		{
		}
		
		/**
		 * Initialize class to perform FFT of specified size.
		 *
		 * @param   logN    Log2 of FFT length. e.g. for 512 pt FFT, logN = 9.
		 */
		public function init(
			logN:uint ):void
		{
			m_logN = logN
			m_N = 1 << m_logN;
			m_invN = 1.0/m_N;
			
			if(copyVector == null){
				copyVector = new Vector.<FFTElement>(m_N);
				for ( t = 0; t < m_N; t++ ){
					copyVector[t] = new FFTElement;
				}
			}
			
			// Allocate elements for linked list of complex numbers.
			m_X = copyVector.concat();
			
			
			//			m_X = new Vector.<FFTElement>(m_N);
			//			for ( t = 0; t < m_N; t++ )
			//				m_X[t] = new FFTElement;
			
			// Set up "next" pointers.
			for ( t = 0; t < m_N-1; t++ )
				m_X[t].next = m_X[t+1];
			
			// Specify target for bit reversal re-ordering.
			for ( t = 0; t < m_N; t++ )
				m_X[t].revTgt = BitReverse(t,logN);
		}
		
		/**
		 * Performs in-place complex FFT.
		 *
		 * @param   xRe     Real part of input/output
		 * @param   xIm     Imaginary part of input/output
		 * @param   inverse If true (INVERSE), do an inverse FFT
		 */
		
		
		private var numFlies:uint = 0; // Number of butterflies per sub-FFT
		private var span:uint = 0;     // Width of the butterfly
		private var spacing:uint = 0;         // Distance between start of sub-FFTs
		private var wIndexStep:uint = 0;        // Increment for twiddle table index
		
		private var x:FFTElement;
		private var k:uint = 0;
		private var scale:Number = 0;
		
		private var stage:uint = 0;
		private var start:uint = 0;
		private var flyCount:uint = 0;
		
		private var wAngleInc:Number = 0;
		private var wMulRe:Number = 0;
		private var wMulIm:Number = 0;
		
		private var xTop:FFTElement;
		private var xBot:FFTElement;
		
		private var wRe:Number = 1.0;
		private var wIm:Number = 0.0;
		
		private var xTopRe:Number = 0;
		private var xTopIm:Number = 0;
		private var xBotRe:Number = 0;
		private var xBotIm:Number = 0;
		
		private var target:uint = 0;
		
		public function run(
			xRe:Vector.<Number>,
			xIm:Vector.<Number>,
			inverse:Boolean = false ):void
		{
			numFlies = m_N >> 1; // Number of butterflies per sub-FFT
			span = m_N >> 1;     // Width of the butterfly
			spacing = m_N;         // Distance between start of sub-FFTs
			wIndexStep = 1;        // Increment for twiddle table index
			
			// Copy data into linked complex number objects
			// If it's an IFFT, we divide by N while we're at it
			x = m_X[0];
			k = 0;
			scale = inverse ? m_invN : 1.0;
			while (x)
			{
				x.re = scale*xRe[k];
				x.im = scale*xIm[k];
				x = x.next;
				k++;
			}
			
			// For each stage of the FFT
			for (stage = 0; stage < m_logN; ++stage )
			{
				// Compute a multiplier factor for the "twiddle factors".
				// The twiddle factors are complex unit vectors spaced at
				// regular angular intervals. The angle by which the twiddle
				// factor advances depends on the FFT stage. In many FFT
				// implementations the twiddle factors are cached, but because
				// vector lookup is relatively slow in ActionScript, it's just
				// as fast to compute them on the fly.
				wAngleInc = wIndexStep * 2.0*Math.PI/m_N;
				if ( inverse == false ) // Corrected 3 Aug 2011. Had this condition backwards before, so FFT was IFFT, and vice-versa!
					wAngleInc *= -1;
				wMulRe = Math.cos(wAngleInc);
				wMulIm = Math.sin(wAngleInc);
				
				for ( start = 0; start < m_N; start += spacing )
				{
					xTop = m_X[start];
					xBot = m_X[start+span];
					
					wRe = 1.0;
					wIm = 0.0;
					
					// For each butterfly in this stage
					for ( flyCount = 0; flyCount < numFlies; ++flyCount )
					{
						// Get the top & bottom values
						xTopRe = xTop.re;
						xTopIm = xTop.im;
						xBotRe = xBot.re;
						xBotIm = xBot.im;
						
						// Top branch of butterfly has addition
						xTop.re = xTopRe + xBotRe;
						xTop.im = xTopIm + xBotIm;
						
						// Bottom branch of butterly has subtraction,
						// followed by multiplication by twiddle factor
						xBotRe = xTopRe - xBotRe;
						xBotIm = xTopIm - xBotIm;
						xBot.re = xBotRe*wRe - xBotIm*wIm;
						xBot.im = xBotRe*wIm + xBotIm*wRe;
						
						// Advance butterfly to next top & bottom positions
						xTop = xTop.next;
						xBot = xBot.next;
						
						// Update the twiddle factor, via complex multiply
						// by unit vector with the appropriate angle
						// (wRe + j wIm) = (wRe + j wIm) x (wMulRe + j wMulIm)
						var tRe:Number = wRe;
						wRe = wRe*wMulRe - wIm*wMulIm;
						wIm = tRe*wMulIm + wIm*wMulRe;
					}
				}
				
				numFlies >>= 1;   // Divide by 2 by right shift
				span >>= 1;
				spacing >>= 1;
				wIndexStep <<= 1;     // Multiply by 2 by left shift
			}
			
			// The algorithm leaves the result in a scrambled order.
			// Unscramble while copying values from the complex
			// linked list elements back to the input/output vectors.
			x = m_X[0];
			while (x)
			{
				target = x.revTgt;
				xRe[target] = x.re;
				xIm[target] = x.im;
				x = x.next;
			}
		}
		
		/**
		 * Do bit reversal of specified number of places of an int
		 * For example, 1101 bit-reversed is 1011
		 *
		 * @param   x       Number to be bit-reverse.
		 * @param   numBits Number of bits in the number.
		 */
		private var y:uint = 0;
		
		private function BitReverse(
			x:uint,
			numBits:uint):uint
		{
			y = 0;
			for ( i = 0; i < numBits; i++)
			{
				y <<= 1;
				y |= x & 0x0001;
				x >>= 1;
			}
			return y;
		}
	}
}
