package com.edgington.util.localisation.iterators{
	
	/**
	 * The 'IIterator' interface defines a common interface for all iterator objects.
	 */
	public interface IIterator {
				
		/**
		 * Returns a boolean value indicating whether or not the collection has another 
		 * element beyond the current index.
		 * 
		 * @return	A boolean value indicating whether or not the collection has another element beyond the current index.
		 */
		function hasNext():Boolean;
		
		/**
		 * Returns the element at the current index and then moves on to the next.
		 * 
		 * @return	The element at the current index.
		 */
		function next():Object;
		
		
		/**
		 * Rewinds this iterator back to it's starting index.
		 */
		function rewind():void;
	}
}