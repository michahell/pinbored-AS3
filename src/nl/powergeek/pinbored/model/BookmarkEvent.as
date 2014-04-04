package nl.powergeek.pinbored.model
{
	import starling.events.Event;
	
	public class BookmarkEvent extends Event
	{
		// custom events
		public static const
			BOOKMARK_EXPANDING:String = 'bookmark-expanding-event',
			BOOKMARK_EXPANDED:String = 'bookmark-expanded-event',
				
			BOOKMARK_FOLDING:String = 'bookmark-folding-event',
			BOOKMARK_FOLDED:String = 'bookmark-folded-event',
			
			BOOKMARK_EDITED:String = 'bookmark-edited-event',
			BOOKMARK_DELETED:String = 'bookmark-deleted-event',
			
			ITEM_RENDERER_COMMIT_DATA:String = 'bookmark-commit-data-event';
		
		public function BookmarkEvent(type:String, bubbles:Boolean=false, data:Object=null)
		{
			super(type, bubbles, data);
		}
	}
}