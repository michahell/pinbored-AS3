package nl.powergeek.utils
{
	
	public function arrayToString(array:Array):String
	{
		var string:String = '';
		
		array.forEach(function(item:*, index:uint, array:Array):void {
			
			for(var id:String in item) {
				var value:Object = item[id];
				string += '\t' + id + ' : ' + value + '\n';
			}
			
			string += '\n';
		});
		
		trace(string);
		
		return string;
	}
	
}