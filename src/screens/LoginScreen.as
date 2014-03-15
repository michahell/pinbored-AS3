package screens
{
	import feathers.controls.Button;
	import feathers.controls.Callout;
	import feathers.controls.Header;
	import feathers.controls.Label;
	import feathers.controls.PanelScreen;
	import feathers.controls.Screen;
	import feathers.controls.ScrollContainer;
	
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	import starling.events.Event;
	
	public class LoginScreen extends PanelScreen
	{
		protected var 
			button:Button,
			_onListScreenRequest:Signal = new Signal( ListScreen );
		
		public function LoginScreen()
		{
			super()
		}
		
		override protected function initialize():void
		{
			//runs once when screen is first added to the stage.
			//a good place to add children and things.
			
			this.headerFactory = function():Header
			{
				var header:Header = new Header();
				header.title = "Login to pinbored";
				return header;
			}
				
			this.footerFactory = function():ScrollContainer
			{
				var container:ScrollContainer = new ScrollContainer();
				container.nameList.add( ScrollContainer.ALTERNATE_NAME_TOOLBAR );
				container.horizontalScrollPolicy = ScrollContainer.SCROLL_POLICY_OFF;
				container.verticalScrollPolicy = ScrollContainer.SCROLL_POLICY_OFF;
				return container;
			}
				
			
			
			this.button = new Button();
			this.button.label = "Click Me";
			this.addChild( button );
			this.button.addEventListener( Event.TRIGGERED, button_triggeredHandler );
			this.button.validate();
			
			this.button.x = (this.stage.stageWidth - this.button.width) / 2;
			this.button.y = (this.stage.stageHeight - this.button.height) / 2;
		}
		
		override protected function draw():void
		{
			//runs every time invalidate() is called
			//a good place for measurement and layout
		}
		
		protected function button_triggeredHandler( event:Event ):void
		{
			const label:Label = new Label();
			label.text = "Hi, I'm LoginScreen!";
			Callout.show( label, this.button );
			
//			this._onListScreenRequest.dispatch( this );
		}
		
		public function get onListScreenRequest():ISignal
		{
			return this._onListScreenRequest;
		}
		
	}
}