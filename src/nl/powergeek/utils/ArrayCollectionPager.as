package nl.powergeek.utils
{
	import feathers.data.ListCollection;
	

	public class ArrayCollectionPager
	{
		private var
			_arrayCollection:Array,
			_currentPage:Number = 0,
			_numPages:Number = -1;
			
		public function ArrayCollectionPager(sourceArray:Array = null, resultsPerPage:Number = 20)
		{
			trace('ArrayCollectionPager: source array size before split: ' + sourceArray.length);
			
			// split the given source array
			_arrayCollection = split(sourceArray, resultsPerPage);
			
			// update internal numPages indicator
			if(_arrayCollection && _arrayCollection.length > 0)
				// if there are pages
				if(_arrayCollection[0] is Array) {
					_numPages = _arrayCollection.length;
					for (var i:uint = 0; i < _numPages; i++) {
						trace('ArrayCollectionPager: result page size: ' + _arrayCollection[i].length);
					}
				} else {
					_numPages = 0;
				}
				
			trace('ArrayCollectionPager: numPages: ' + _numPages);
		}
		
		/**
		 * Splits [sourceArray] into [resultsPerPage] listcollections 
		 * @param sourceArray the source array to split into listcollections of same-size [resultsPerPage]
		 * @param resultsPerPage the amount of items that have to at least be in each listcollection after the splitting.
		 * @return a vector of listcollections.
		 */		
		public function split(sourceArray:Array, resultsPerPage:Number):Array {
			
			// if there is a source Array and it contains items
			var listCollectionArray:Array = null;
			
//			if(sourceArray && sourceArray.length > 0) {
//				// calculate how many parts we need
//				var parts:Number = Math.ceil(sourceArray.length / resultsPerPage);
//				trace('ArrayCollectionPager: split in part size: ' + parts, ' source array length: ', sourceArray.length, ' results per page: ', resultsPerPage);
//				
//				// split the source array into an arrayCollection of n parts
//				listCollectionArray = ArrayUtils.splitTo(sourceArray, parts);
//			}
			
			if(sourceArray && sourceArray.length > 0) {
				// split the source array into an arrayCollection of n parts
				listCollectionArray = ArrayUtils.splitToTypeSafe(sourceArray, resultsPerPage);
			}
			
			return listCollectionArray;
		}
		
		/**
		 * Returns the first 'page' of results, IF a listCollections vector exists and its length is longer than 0.
		 * * warning: updates currentPage internal variable, so if the first listcollection is requested and after that a next() call is made,
		 * the next listcollection 'page' is returned, logically.
		 * @return a listcollection 'page' 
		 */		
		public function first():Array {
			if(_arrayCollection && _arrayCollection.length > 0) {
				_currentPage = 0;
				// check if the first item of arrayCollection is an item, it could be the case that there simply are no result 'pages'
				if(_arrayCollection[0] is Array)
					return _arrayCollection[0];
				else
					return _arrayCollection;
			} else {
				throw new Error('ArrayCollectionPager: Error: there is no internal _listCollections Vector!');
			}
			return null;
		}
		
		/**
		 * Does the same as first() only returns the LAST ListCollection if a listCollections vector exists and its length is longer than 0.
		 * warning: updates currentPage internal variable, so if the last listcollection is requested and after that a previous() call is made,
		 * the last - 1 listcollection 'page' is returned, logically.
		 * @return a listcollection 'page'
		 */		
		public function last():Array {
			if(_arrayCollection && _arrayCollection.length > 0) {
				_currentPage = _arrayCollection.length - 1;
				return _arrayCollection[_arrayCollection.length - 1];
			} else {
				throw new Error('ArrayCollectionPager: Error: there is no internal _listCollections Vector!');
			}
			return null;
		}
		
		/**
		 * Gets the next listcollection from the pager if there is a next listcollection.
		 * does NOT continue with the other end of the listcollections vector so stops at the first listcollection 'page'.
		 * @return a listcollection 'page' or null if there is no next 'page'.
		 */		
		public function next():Array {
			if(_arrayCollection && _arrayCollection.length > 0) {
				if(_arrayCollection.length > _currentPage) {
					_currentPage++;		
					return _arrayCollection[_currentPage];
				} else {
					throw new Error('ArrayCollectionPager: Error: not possible to return next result page, current result page = ' + _currentPage + ' !');
				}
			} else {
				throw new Error('ArrayCollectionPager: Error: there is no internal _listCollections Vector!');
			}
			return null;
		}
		
		/**
		 * Gets the previous listcollection from the pager if there is a previous listcollection.
		 * does NOT continue with the other end of the listcollections vector so stops at the first listcollection 'page'.
		 * @return a listcollection 'page' or null if there is no previous 'page'.
		 */		
		public function previous():Array {
			if(_arrayCollection && _arrayCollection.length > 0) {
				if(_currentPage > 0) {
					_currentPage--;					
					return _arrayCollection[_currentPage];
				} else {
					throw new Error('ArrayCollectionPager: Error: not possible to return previous result page, current result page = ' + _currentPage + ' !');
				}
			} else {
				throw new Error('ArrayCollectionPager: Error: there is no internal _listCollections Vector!');
			}
			return null;
		}
		
		/**
		 * Returns the current result page number.
		 */		
		public function current():Number {
			return _currentPage + 1;
		}
		
		/**
		 * gets the number of result pages, if any. 
		 * @return a number... of result pages.
		 */
		public function get numPages():Number
		{
			return _numPages;
		}

		
	}
}