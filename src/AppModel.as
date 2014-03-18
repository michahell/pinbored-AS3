package
{
	import feathers.controls.ScreenNavigator;
	import feathers.data.ListCollection;
	
	import flash.events.Event;
	
	import nl.powergeek.utils.ArrayCollectionPager;
	
	import org.osflash.signals.Signal;
	
	import starling.core.Starling;

	public class AppModel
	{
		public static var
			resized:Signal = new Signal(Event);
		
		public static var
			starling:Starling = null,
			navigator:ScreenNavigator = null,
			// raw bookmarks
			rawBookmarkDataList:Array = [],
			rawBookmarkDataListFiltered:Array = [],
			// pager
			rawBookmarkListCollectionPager:ArrayCollectionPager,
			// final or current list
			bookmarksList:Array = [];
		
		public function AppModel() { }
		
	}
}