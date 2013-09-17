package com.edgington.util.localisation.iterators {
		

	/**
	 * Iterates through an array by starting with the array length and then decrementing 
	 * the index until '0' is reached.
	 * 
	 * @see	com.divisionfifteen.collections.iterators.IIterator
	 */
	public class ReverseArrayIterator implements IIterator {
	
		/**
		 * Holds the array of data to be iterated through.
		 */
		private var _arrData : Array;

		/**
		 * Stores the current index for the iteration process.
		 */
		private var _index : uint;

		
		/**
		 * Constructor.
		 * 
		 * @param	aData	An array of data to be iterated through by this object.
		 */
		public function ReverseArrayIterator(aData : Array) {
			// Store the supplied data array.
			_arrData = aData;
			
			// Reset this iterator.
			rewind();
		}

		
		/**
		 * Returns a boolean value indicating whether or not the collection has another 
		 * element beyond the current index.
		 * 
		 * @return	A boolean value indicating whether or not the collection has another element beyond the current index.
		 */
		public function hasNext() : Boolean {
			// Determine whether the index is greater than '0' or not.
			return _index > 0;
		}

		/**
		 * Returns the element at the current index and then moves on to the next.
		 * 
		 * @return	The element at the current index.
		 */
		public function next() : Object {
			// Decrement the index and then return the element at that index.
			return _arrData[--_index];
		}

		/**
		 * Resets this iterator back to the last index of the array.
		 */
		public function rewind() : void {
			// Set the index to the length of the data array.
			_index = _arrData.length;
		}
	}
}