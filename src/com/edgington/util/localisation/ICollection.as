package com.edgington.util.localisation{
	import com.edgington.util.localisation.iterators.IIterator;

	/**
	 * The 'ICollection' interface defines a common interface for all collection objects.
	 */
	public interface ICollection {
				
		/**
		 * Returns an iterator of the specified type.
		 * 
		 * @param	uIterator	The iterator type to use for iterating through the data being stored by this collection.
		 * @return	An iterator instance of the specified type.
		 * @see		com.divisionfifteen.collections.iterators.IteratorType
		 */
		function getIterator(uIterator:uint = 2):IIterator // 2 -> IteratorType.ARRAY_FORWARD
	}
}