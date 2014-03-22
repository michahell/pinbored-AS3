package nl.powergeek.utils
{
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class ArrayUtils
	{
		public function ArrayUtils()
		{
		}
		
		public static function getClass(obj:Object):Class {
			return Class(getDefinitionByName(getQualifiedClassName(obj)));
		}
		
		public static function splitTo(a1:Array, parts:uint):Array {
			
			if (parts > 1) {
				
				var aCount:Number = a1.length / parts;
				var limit:int = int(aCount);
				var res:Array = new Array();
				var index:uint = 0;
				
				// copy the source array
				var copy:Array = a1.slice();
				
				// if aCount <= 1
				if (aCount <= 1) 
				{
					
					// put every element in new array
					for (var i:uint = 0; i<copy.length; i++) 
					{
						
						// make new array and resulting array
						var newarray:Array = new Array();
						newarray.push(copy[i]);
						res.push(newarray);
					}
				} else {
					for (var k:uint = 0; k<parts; k++) 
					{
						var childArray:Array = new Array();
						
						if (copy.length > 0) 
						{ 
							// if a1 is not empty 
							for (var j:uint = 0; j<limit; j++) 
							{
								childArray.push(copy.splice(0, 1));
//								newarray2.push(copy[index]);
								index++;
							}
							res.push(childArray);
						}
					}
					
					// put rest of the elements inside last array
					while (copy.length > 0) 
					{
						res[res.length-1].push(copy.splice(0, 1));
					}
				}
				
				// return resulting Array of Array[s]
				return res; 
			} else {
				return a1;
			}
		}
		
		public static function splitToTypeSafe(source:Array, resultsPerPage:uint):Array {
			
			// 50 items and 10 items per page means 5 child arrays.
			var fullPages:uint = Math.floor(source.length / resultsPerPage);
			trace('parts: ', source.length + ' / ' + resultsPerPage + ' = ' + fullPages);
			
			// 48 items would mean 4 child arrays and the last one containing 8 instead of 10 items.
			var restPage:uint = uint(source.length % resultsPerPage);
			trace('rest: ', source.length + ' % ' + resultsPerPage + ' = ' + restPage);
			
			// copy source
			var sourceCopy:Array = source.slice();
			
			// create result array
			var result:Array = [];
			
			
			// state vars
			var childArrayNum:Number = 0;
			var taken:Number = 0;
			
			// while there are items in the source copy
			while(sourceCopy.length > 0) {
				
				// get item from source copy
				var item:* = sourceCopy.splice(0, 1);
				
				if(taken < resultsPerPage) {
					result[childArrayNum].push(item);
					taken++;
				} else {
					taken = 0;
					childArrayNum++;
				}
				
			}
			
			
			
			
			
			
			
			
//			// add the full pages
//			for(var k:uint = 0; k < fullPages; k++) {
//				
//				// create child array
//				var childArray:Array = [];
//				
//				// for <resultsPerPage> number of items, move items from source copy over to the child array
//				for(var n:uint = 0; n < resultsPerPage; n++) {
//					
//					// get item from source copy
//					var item:* = sourceCopy.splice(0, 1);
//					
//					// put it into the child array
//					childArray.push(item);
//				}
//				
//				// store the child array in the result array
//				result.push(childArray);
//			}
//			
//			// add the rest page
//			var restArray:Array = [];
			
			
			// finally, return the created result array
			return source;
		
		}
		
	}
}