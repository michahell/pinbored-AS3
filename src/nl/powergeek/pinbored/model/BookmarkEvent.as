package nl.powergeek.pinbored.model
{
	import starling.events.Event;
	
	public class BookmarkEvent extends Event
	{
		// custom events
		public static const
			BOOKMARK_COLLAPSING:String = 'bookmark-collapsing-event',
			BOOKMARK_COLLAPSED:String = 'bookmark-collapsed-event',
				
			BOOKMARK_FOLDING:String = 'bookmark-folding-event',
			BOOKMARK_FOLDED:String = 'bookmark-folded-event',
			
			BOOKMARK_EDITED:String = 'bookmark-edited-event',
			BOOKMARK_DELETED:String = 'bookmark-deleted-event';
		
		public function BookmarkEvent(type:String, bubbles:Boolean=false, data:Object=null)
		{
			super(type, bubbles, data);
		}
	}
}