package com.edgington.util.localisation.iterators {

	/**
	 * Iterates through an array by starting with '0' and then incrementing the index 
	 * until the array length is reached.
	 * 
	 * @see	com.divisionfifteen.collections.iterators.IIterator
	 */
	public class ForwardArrayIterator implements IIterator {

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
		public function ForwardArrayIterator(aData : Array) {
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
			// Determine if the index is less than the length of the data array.
			return _index < _arrData.length;
		}
		
		
		/**
		 * Returns the element at the current index and then moves on to the next.
		 * 
		 * @return	The element at the current index.
		 */
		public function next() : Object {
			// Return the element at the current index and then increment the index.
			return _arrData[_index++];
		}
		
		
		/**
		 * Resets this iterator back to an index of '0'.
		 */
		public function rewind() : void {
			// Set the index to '0'.
			_index = 0;
		}
	}
}