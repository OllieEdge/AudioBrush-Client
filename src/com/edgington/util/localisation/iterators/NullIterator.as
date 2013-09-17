package com.edgington.util.localisation.iterators {			

	/**
	 * In certain cases, such as a leaf object in a composite pattern, a null iterator 
	 * is needed to maintain elegant code. Instead of making special checks using if 
	 * statements, a null iterator will plug right into a loop and return 'false' when 
	 * 'HasNext' is checked.
	 * 
	 * @see	#hasNext
	 * @see	com.divisionfifteen.collections.iterators.IIterator
	 */
	public class NullIterator implements IIterator {

		/**
		 * Constructor.
		 */
		public function NullIterator() {
		}

		
		/**
		 * Returns a boolean value indicating whether or not the collection has another 
		 * element beyond the current index.
		 * 
		 * @return	A boolean value indicating whether or not the collection has another element beyond the current index.
		 */
		public function hasNext() : Boolean {
			// Return 'false' to instantly end any iteration.
			return false;
		}

		/**
		 * Returns the element at the current index and then moves on to the next.
		 * 
		 * @return	The element at the current index.
		 */
		public function next() : Object {
			// Return 'null' since no data is actually being iterated through.
			return null;
		}

		/**
		 * Resets this iterator back to it's starting index.
		 * <p>
		 * NOTE: This method is only present to meet the criteria of the 'IIterator' interface.
		 * 
		 * @see	com.divisionfifteen.collections.iterators.IIterator
		 */
		public function rewind() : void {
		}
	}
}