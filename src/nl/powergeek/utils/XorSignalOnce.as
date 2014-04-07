package nl.powergeek.utils
{
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	public class XorSignalOnce extends Signal
	{
		private var 
			fired:Boolean = false;
		
		public function XorSignalOnce(...parameters)
		{
			super(parameters);
		}
		
		public function addSignal(signal:ISignal):void
		{
			signal.add(function():void {
				if(!fired) {
					fired = true;
					dispatch();
				}
			});
		}
	}
}