package nl.powergeek.utils
{
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	public class XorSignal extends Signal
	{
		public function XorSignal(...parameters)
		{
			super(parameters);
		}
		
		public function addSignal(signal:ISignal):void
		{
			signal.add(function():void {
				dispatch();
			});
		}
	}
}