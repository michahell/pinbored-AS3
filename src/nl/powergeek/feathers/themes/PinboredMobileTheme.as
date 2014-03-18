package nl.powergeek.feathers.themes
{
	import feathers.controls.TextInput;
	import feathers.controls.text.TextFieldTextEditor;
	import feathers.core.FeathersControl;
	import feathers.core.ITextEditor;
	import feathers.themes.MetalWorksMobileTheme;
	
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	
	public class PinboredMobileTheme extends MetalWorksMobileTheme
	{
		public static var
			ALTERNATE_NAME_SEARCH_TEXT_BACKGROUNDLESS_INPUT:String = 'feathers-search-text-backgroundless-input',
			ALTERNATE_NAME_NAVIGATION_BUTTON:String = 'feathers-navigation-button-bar';

		
		public function PinboredMobileTheme(container:DisplayObjectContainer=null, scaleToDPI:Boolean=true)
		{
			super(container, scaleToDPI);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			// set new initializers here
//			this.setInitializerForClass( TextInput, backgroundlessTextInputInitializer, ALTERNATE_NAME_SEARCH_TEXT_BACKGROUNDLESS_INPUT );
		}
		
		private function backgroundlessTextInputInitializer(textInput:TextInput):void
		{
			textInput.backgroundDisabledSkin = new Quad(10, 10, 0xFF00FF);
			textInput.backgroundEnabledSkin = new Quad(10, 10, 0xFF00FF);
			textInput.backgroundFocusedSkin = new Quad(10, 10, 0xFF00FF);
			
			textInput.textEditorFactory = function():ITextEditor {
				return new TextFieldTextEditor();
			}
			
		}
	}
}