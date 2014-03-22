package nl.powergeek.feathers.components
{
	import feathers.controls.Button;
	import feathers.controls.LayoutGroup;
	import feathers.layout.HorizontalLayout;
	
	import nl.powergeek.feathers.themes.PinboredDesktopTheme;
	
	public class Pager extends LayoutGroup
	{
//		private var
			
		
		public function Pager()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			var pagingControlLayout:HorizontalLayout = new HorizontalLayout();
			pagingControlLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_TOP;
			pagingControlLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
			pagingControlLayout.gap = 0;
			this.layout = pagingControlLayout;
		}
		
		public function activate(resultPages:Number):void
		{
			// create n number of buttons for n result pages
			for (var i:uint = 1; i < resultPages + 1; i++) {
				var button:Button = new Button();
				button.label = i.toString();
				button.nameList.add(PinboredDesktopTheme.BUTTON_PAGER_SMALL_DEFAULT);
				// TODO add listener to each button and let it dispatch events with the NUMBER
				// as extra data?
				addChild(button);
			}
			
			// invalidate for redraw / resize
			invalidate(INVALIDATION_FLAG_LAYOUT);
			invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if(isEnabled) {
				HorizontalLayout(this.layout).padding = 2;
				HorizontalLayout(this.layout).paddingLeft = HorizontalLayout(this.layout).paddingLeft = 3;
			}
		}
	}
}