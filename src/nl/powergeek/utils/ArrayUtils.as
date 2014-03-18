package nl.powergeek.utils
{
	public class ArrayUtils
	{
		public function ArrayUtils()
		{
		}
		
		public static function splitTo(a1:Array, parts:uint):Array 
		{
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
						var newarray2:Array = new Array();
						
						if (copy.length > 0) 
						{ 
							// if a1 is not empty 
							for (var j:uint = 0; j<limit; j++) 
							{
//								newarray2.push(a1.splice(0, 1));
//								trace('item: ' + a1[index].href);
								newarray2.push(copy[index]);
								index++;
							}
							res.push(newarray2);
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
	}
}