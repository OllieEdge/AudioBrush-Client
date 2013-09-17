package  com.edgington.util.localisation{
	
	import com.edgington.util.localisation.iterators.ForwardArrayIterator;
	import com.edgington.util.localisation.iterators.IIterator;
	import com.edgington.util.localisation.iterators.IteratorType;
	import com.edgington.util.localisation.iterators.ReverseArrayIterator;
	
	import flash.utils.Dictionary;

	
	/**
	 * The 'HashMap' class stores data in key/value pairs.
	 * 
	 * @see	com.divisionfifteen.collections.ICollection
	 */
	public class HashMap implements ICollection {

		
		/**
		 * An dictionary for storing the collection of objects.
		 */
		protected var _map : Dictionary;

		/**
		 * An array for storing map keys in order.
		 */
		protected var _arrKeyOrder : Array;

		
		
		/**
		 * Constructor.
		 */
		public function HashMap(objMap : Object = null) {
			// Initialize this object.
			init( objMap );
		}

		
		
		
		/**
		 * Creates a new hash map that is a clone of this collection.
		 * 
		 * @return	A new hash map that is a clone of this collection.
		 */
		public function clone() : HashMap {
			// Create a new hash map.
			var objHashMap : HashMap = new HashMap( );
			
			// Get the length of the keys array.
			var nLength : int = _arrKeyOrder.length;
			
			// Loop through the keys array.
			for(var i : int = 0; i < nLength ; i++) {
				// Put each key/value pair into the new hash map.
				objHashMap.put( _arrKeyOrder[i], _map[ _arrKeyOrder[i] ] );
			}
			
			// Return the cloned hash map.
			return objHashMap;
		}

		
		
		
		/**
		 * Adds a new key and value pair to this collection.
		 * 
		 * @param	objKey		The key to use to retrieve the value.
		 * @param	objValue	The value to store.
		 */
		public function put(objKey : Object, objValue : Object) : void {
			// Remove the key, if it already exists.
			remove( objKey );
			
			// Add the key and value to the dictionary.
			_map[ objKey ] = objValue;
			//Add the key to the array of keys to track order.
			_arrKeyOrder.push( objKey );
		}

		
		
		
		/**
		 * Iterates through all accessible properties/elements of the specified 
		 * object and adds each one as a key/value pair to this collection.
		 * 
		 * @param	objMap	The object to extract key/value pairs from.
		 */
		public function putMap(objMap : Object) : void {
			// Loop through each key in the supplied map.
			for(var strKey:String in objMap) {
				// Put each key and value into this collection.
				put( strKey, objMap[strKey] );
			}
		}

		
		
		
		/**
		 * Gets the value that is paired with the specified key. If not such key 
		 * exists, 'null' is returned.
		 * 
		 * @param	objKey	They key to use to retrieve a value.
		 * @return	The value that was paired with the specified key.
		 */
		public function getValue(objKey : Object) : Object {
			
			// Check for a valid key index.
			if( _map[objKey] ) {
				// Return the value.
				return _map[objKey];
			}
			
			// Return 'null' indicating that the supplied key does not exist.
			return null;
		}

		
		
		
		/**
		 * Removes the specified key and it's corresponding value from this collection.
		 * 
		 * @param	objKey	The key to be removed.
		 */
		public function remove(objKey : Object) : void {
			// Search for the key and store it's index if it exists.
			
			if( _map[objKey] === undefined ){
				return;
			}
			
			var iKeyIndex : int = searchForKey( objKey );
			
			// Check for a valid key index.
			if(iKeyIndex != -1) {
				// Remove the key and value from their corresponding arrays.
				_arrKeyOrder.splice( iKeyIndex, 1 );
			}
			
			delete _map[objKey];
		
		}

		
		
		
		/**
		 * Checks to see if this collection contains the specified key.
		 * 
		 * @param	objKey	The key being searched for.
		 * @return	A boolean value of 'true' if the key exists, 'false' if it does not.
		 */
		public function containsKey(objKey : Object) : Boolean {
			// Return 'true' if the key exists, 'false' if it does not.
			if( _map[objKey] ) {
				return true;
			}
			return false;
		}

		
		
		
		/**
		 * Gets the length of this collection.
		 * 
		 * @return	The length of this collection.
		 */
		public function get length() : uint {
			// Return the keys array length.
			return _arrKeyOrder.length;
		}

		
		
		
		/**
		 * Returns an iterator of the specified type.
		 * 
		 * @param	uIterator	The iterator type to use for iterating through the data being stored by this collection. Default is '2' (IteratorType.ARRAY_FORWARD).
		 * @return	An iterator instance of the specified type.
		 * @see		com.divisionfifteen.collections.iterators.IteratorType
		 */
		public function getIterator(uIterator : uint = 2) : IIterator {
			// Return an iterator instance for iterating through values by default.
			return getValueIterator( uIterator );
		}

		
		
		
		/**
		 * Returns an iterator of the specified type for iterating through keys.
		 * 
		 * @param	uIterator	The iterator type to use for iterating through the keys being stored by this collection. Default is '2' (IteratorType.ARRAY_FORWARD).
		 * @return	An iterator instance of the specified type.
		 * @see		com.divisionfifteen.collections.iterators.IteratorType
		 */
		public function getKeyIterator(uIterator : uint = 2) : IIterator {
			// Check to see if the specified iterator is a forward array iterator.
			if(uIterator == IteratorType.ARRAY_FORWARD) {
				// Return a forward array iterator.
				return new ForwardArrayIterator( _arrKeyOrder.concat( ) );
			}
			// Check to see if the specified iterator is a reverse array iterator.
			else if(uIterator == IteratorType.ARRAY_REVERSE) {
				// Return a reverse array iterator.
				return new ReverseArrayIterator( _arrKeyOrder.concat( ) );
			} else {
				// Return a forward array iterator.
				return new ForwardArrayIterator( _arrKeyOrder.concat( ) );
			}
		}

		
		
		
		/**
		 * Returns an iterator of the specified type for iterating through values.
		 * 
		 * @param	uIterator	The iterator type to use for iterating through the values being stored by this collection. Default is '2' (IteratorType.ARRAY_FORWARD).
		 * @return	An iterator instance of the specified type.
		 * @see		com.divisionfifteen.collections.iterators.IteratorType
		 */
		public function getValueIterator(uIterator : uint = 2) : IIterator {
			
			//Create an array to pass to the iterator
			var arrValues : Array = new Array( );
			//Loop through the keys to add the values to the array in the correct order.
			for (var i : int = 0; i < _arrKeyOrder.length ; i++) {
				arrValues.push( _map[_arrKeyOrder[i] ] );
			}
			
			// Check to see if the specified iterator is a forward array iterator.
			if(uIterator == IteratorType.ARRAY_FORWARD) {
				// Return a forward array iterator.
				return new ForwardArrayIterator( arrValues );
			}
			// Check to see if the specified iterator is a reverse array iterator.
			else if(uIterator == IteratorType.ARRAY_REVERSE) {
				// Return a reverse array iterator.
				return new ReverseArrayIterator( arrValues );
			} else {
				// Return a forward array iterator.
				return new ForwardArrayIterator( arrValues );
			}
		}

		
		
		
		/**
		 * Performs any appropriate clean-up tasks for garbage collection such as 
		 * removing event listeners, setting object references to 'null', etc.
		 */
		public function destroy() : void {
			//Create new key and value arrays.
			_map = null;
			_arrKeyOrder = null;
		}

		
		
		
		/**
		 * Initializes this object.
		 */
		protected function init( objMap : Object ) : void {
			// Create new key and value arrays by clearing this object.
			_map = new Dictionary();
			_arrKeyOrder = [];
			
			// Check the map parameter to see if a map was supplied.
			if(objMap != null) {
				// Put the map into this collection.
				putMap( objMap );
			}
		}

		
		
		
		/**
		 * Searches through the keys array to see if the key is being stored by this object. 
		 * If the key is found, it's index in the keys array is returned. If the key is not 
		 * found, the null index value is returned.
		 * 
		 * @param	objKey	The key being searched for.
		 * @return	The index that the key is being stored at in the keys array.
		 */
		protected function searchForKey(objKey : Object) : int {
			// Get the length of the keys array.
			var nLength : int = _arrKeyOrder.length;
			
			// Loop through the keys array.
			for(var i : int = 0; i < nLength ; i++) {
				// Compare each key to the specified key.
				if(_arrKeyOrder[i] === objKey) {
					// Return the matching key's index.
					return i;
				}
			}
			
			// Return a null index value indicating that the 
			// key was not found.
			return -1;
		}
	}
}