package nl.powergeek.pinbored.model
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
			bookmarksList:Array = [],
			
			// result paging state
			currentResultPage:Number = -1,
			numResultPages:Number = -1;
			
		public static const
			
			PINBOARD_BASE_API_URL:String = 'https://api.pinboard.in/v1/',
			BOOKMARKS_PER_PAGE:uint = 25,
		
			DISCLAIMER_TEXT:String = '' +
				'Dislaimer: use at your own risk. ' +
				'I am in no way responsible for any ' +
				'loss of data. This application can change in between versions, ' +
				'please do not rely on this application as your main bookmark manager.',
				
			OPENSOURCE_TEXT:String = '' +
				'Free and open source.\n' +
				'Made with love by',
				
			LINK_TEXT:String = '' +	
			'<a href=\"http://www.powergeek.nl/\">http://www.powergeek.nl</a>';
		
		public function AppModel() { }
		
	}
}