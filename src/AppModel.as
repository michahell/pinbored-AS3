package
{
	import feathers.controls.ScreenNavigator;
	
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	import starling.core.Starling;

	public class AppModel
	{
		public static var
			resized:Signal = new Signal(Event);
		
		public static var
			starling:Starling = null,
			navigator:ScreenNavigator = null;
		
		public function AppModel() { }
		
	}
}