package nl.powergeek.feathers.themes
{
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.Panel;
	import feathers.controls.TextInput;
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.controls.text.TextFieldTextEditor;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.core.FeathersControl;
	import feathers.core.ITextEditor;
	import feathers.core.ITextRenderer;
	import feathers.themes.MetalWorksMobileTheme;
	
	import flash.text.Font;
	import flash.text.TextFormat;
	
	import nl.powergeek.feathers.components.TagTextInput;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	
	public class PinboredMobileTheme extends MetalWorksMobileTheme
	{
		// embedded fonts
		[Embed(source="assets/fonts/pinbored/OpenSans-Light.ttf", fontName="OpenSansLight", mimeType="application/x-font", embedAsCFF="false", fontFamily="OpenSans")]
		private static const OpenSansLight:Class;
		public static var OpenSansLightFont:Font = new OpenSansLight();
		
		[Embed(source="assets/fonts/pinbored/OpenSans-Regular.ttf", fontName="OpenSansRegular", mimeType="application/x-font", embedAsCFF="false", fontFamily="OpenSans")]
		private static const OpenSansRegular:Class;
		public static var OpenSansRegularFont:Font = new OpenSansRegular();
		
		[Embed(source="assets/fonts/pinbored/OpenSans-Semibold.ttf", fontName="OpenSansSemiBold", mimeType="application/x-font", embedAsCFF="false", fontFamily="OpenSans")]
		private static const OpenSansSemiBold:Class;
		public static var OpenSansSemiBoldFont:Font = new OpenSansSemiBold();
		
		[Embed(source="assets/fonts/pinbored/OpenSans-Bold.ttf", fontName="OpenSansBold", mimeType="application/x-font", embedAsCFF="false", fontFamily="OpenSans")]
		private static const OpenSansBold:Class;
		public static var OpenSansBoldFont:Font = new OpenSansBold();
		
		// alternate skin names
		public static const
			TEXTINPUT_TRANSPARENT_BACKGROUND:String = 'feathers-textinput-transparent-background',
			LABEL_TAG_TEXTRENDERER:String = 'feathers-tag-textrenderer',
			PANEL_TRANSPARENT_BACKGROUND:String = 'feathers-panel-transparent-background',
			BUTTON_QUAD_CONTEXT_PRIMARY:String = 'feathers-quad-context-edit-button',
			BUTTON_QUAD_CONTEXT_DELETE:String = 'feathers-quad-context-delete-button',
			BUTTON_QUAD_CONTEXT_SUCCESS:String = 'feathers-quad-context-secondary-button',
			BUTTON_QUAD_CONTEXT_ALTERNATIVE:String = 'feathers-quad-context-ternary-button';
			
		// some static constants for 'internal' use
		public static const
			BUTTON_DEFAULT_ALPHA:Number = 1,
			CONTEXT_BUTTON_DEFAULT_ALPHA:Number = 1;
			
		// textformats
		public static const
			TEXTFORMAT_TAG:TextFormat = new TextFormat(OpenSansBoldFont.fontName, 14, 0xEEEEEE, true),
			TEXTFORMAT_TAG_TEXT_INPUT_PROMPT:TextFormat = new TextFormat(OpenSansBoldFont.fontName, 14, 0xAAAAAA, true);
		
		public function PinboredMobileTheme(container:DisplayObjectContainer=null, scaleToDPI:Boolean=true)
		{
			super(container, scaleToDPI);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			// set new initializers here
			this.setInitializerForClass(TextInput, backgroundlessTextInputInitializer, TEXTINPUT_TRANSPARENT_BACKGROUND);
			
			// custom quad buttons
			this.setInitializerForClass(Button, quadContextPrimaryButtonInitializer, BUTTON_QUAD_CONTEXT_PRIMARY);
			this.setInitializerForClass(Button, quadContextDeleteButtonInitializer, BUTTON_QUAD_CONTEXT_DELETE);
			this.setInitializerForClass(Button, quadContextSuccessButtonInitializer, BUTTON_QUAD_CONTEXT_SUCCESS);
			this.setInitializerForClass(Button, quadContextAlternativeButtonInitializer, BUTTON_QUAD_CONTEXT_ALTERNATIVE);
			
			this.setInitializerForClass(Panel, transparentPanelInitializer, PANEL_TRANSPARENT_BACKGROUND);
			this.setInitializerForClass(Label, tagLabelInitializer, LABEL_TAG_TEXTRENDERER);
		}
		
		private function tagLabelInitializer(label:Label):void
		{
			label.textRendererFactory = function():ITextRenderer {
				var tr:TextFieldTextRenderer = new TextFieldTextRenderer();
				tr.width = label.width;
				tr.textFormat = TEXTFORMAT_TAG;
				return tr;
			}
		}
		
		private function quadContextAlternativeButtonInitializer(button:Button):void
		{
			var defaultSkin:Quad = new Quad(10, 10, 0xC7C7C7);
//			defaultSkin.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.defaultSkin = defaultSkin;
			
			var downSkin:Quad = new Quad(10, 10, 0xADADAD);
//			downSkin.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.downSkin = downSkin;
			
			var hoverSkin:Quad = new Quad(10, 10, 0xE0E0E0);
//			hoverSkin.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.hoverSkin = hoverSkin;
			
			var disabledSkin:Quad = new Quad(10, 10, 0xFFFFFF);
//			disabledSkin.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.disabledSkin = disabledSkin;
			
			button.padding = 5;
			button.paddingLeft = button.paddingRight = 15;
			
			button.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.defaultLabelProperties.embedFonts = true;
			
			button.defaultLabelProperties.textFormat = this.darkUITextFormat;
			button.disabledLabelProperties.textFormat = this.darkUIDisabledTextFormat;
			button.selectedDisabledLabelProperties.textFormat = this.darkUIDisabledTextFormat;
			
			// use hand cursor over button
			button.useHandCursor = true;
		}
		
		private function quadContextSuccessButtonInitializer(button:Button):void
		{
			var defaultSkin:Quad = new Quad(10, 10, 0x5CB85C);
			defaultSkin.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.defaultSkin = defaultSkin;
			
			var downSkin:Quad = new Quad(10, 10, 0x5CB85C);
			downSkin.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.downSkin = downSkin;
			
			var hoverSkin:Quad = new Quad(10, 10, 0x5CB85C);
			hoverSkin.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.hoverSkin = hoverSkin;
			
			var disabledSkin:Quad = new Quad(10, 10, 0xCCF5CE);
			disabledSkin.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.disabledSkin = disabledSkin;
			
			button.padding = 5;
			button.paddingLeft = button.paddingRight = 15;
			
//			button.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.defaultLabelProperties.embedFonts = true;
			
			button.defaultLabelProperties.textFormat = this.lightUITextFormat;
			button.hoverLabelProperties.textFormat = this.lightUITextFormat;
			button.disabledLabelProperties.textFormat = this.lightUIDisabledTextFormat;
			button.selectedDisabledLabelProperties.textFormat = this.lightUIDisabledTextFormat;
			
			// use hand cursor over button
			button.useHandCursor = true;
		}
		
		private function quadContextDeleteButtonInitializer(button:Button):void
		{
			var defaultSkin:Quad = new Quad(10, 10, 0xCF4F4B);
//			defaultSkin.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.defaultSkin = defaultSkin;
			
			var downSkin:Quad = new Quad(10, 10, 0xCF312C);
//			downSkin.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.downSkin = downSkin;
			
			var hoverSkin:Quad = new Quad(10, 10, 0xCF312C);
//			hoverSkin.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.hoverSkin = hoverSkin;
			
			var disabledSkin:Quad = new Quad(10, 10, 0xFFFFFF);
//			disabledSkin.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.disabledSkin = disabledSkin;
			
			button.padding = 5;
			button.paddingLeft = button.paddingRight = 15;
			
			button.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.defaultLabelProperties.embedFonts = true;
			
			button.defaultLabelProperties.textFormat = this.lightUITextFormat;
			button.hoverLabelProperties.textFormat = this.lightUITextFormat;
			button.disabledLabelProperties.textFormat = this.lightUIDisabledTextFormat;
			button.selectedDisabledLabelProperties.textFormat = this.lightUIDisabledTextFormat;
			
			// use hand cursor over button
			button.useHandCursor = true;
		}
		
		private function quadContextPrimaryButtonInitializer(button:Button):void
		{
			var defaultSkin:Quad = new Quad(10, 10, 0x428BCA);
//			defaultSkin.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.defaultSkin = defaultSkin;
			
			var downSkin:Quad = new Quad(10, 10, 0x3276B1);
//			downSkin.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.downSkin = downSkin;
			
			var hoverSkin:Quad = new Quad(10, 10, 0x3276B1);
//			hoverSkin.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.hoverSkin = hoverSkin;
			
			var disabledSkin:Quad = new Quad(10, 10, 0x80B0DB);
//			disabledSkin.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.disabledSkin = disabledSkin;
			
			button.padding = 5;
			button.paddingLeft = button.paddingRight = 15;
			
			button.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.defaultLabelProperties.embedFonts = true;
			
			button.defaultLabelProperties.textFormat = this.lightUITextFormat;
			button.hoverLabelProperties.textFormat = this.lightUITextFormat;
			button.disabledLabelProperties.textFormat = this.lightUIDisabledTextFormat;
			button.selectedDisabledLabelProperties.textFormat = this.lightUIDisabledTextFormat;
			
			// use hand cursor over button
			button.useHandCursor = true;
		}
		
		private function transparentPanelInitializer(panel:Panel):void
		{
			var bg:Quad = new Quad(10, 10, 0x000000);
			bg.alpha = 0.3;
			panel.backgroundSkin = bg;
			panel.backgroundDisabledSkin = bg;
		}
		
		private function backgroundlessTextInputInitializer(textInput:TextInput):void
		{
			// define background
			var backgroundSkin:Quad = new Quad(10, 10, 0xFFFFFF);
			backgroundSkin.alpha = 0;
			
			// text input background
			textInput.backgroundDisabledSkin = backgroundSkin;
			textInput.backgroundEnabledSkin = backgroundSkin;
			textInput.backgroundFocusedSkin = backgroundSkin;
			textInput.backgroundSkin = backgroundSkin;
			
			textInput.textEditorFactory = function():ITextEditor {
				var tfte:TextFieldTextEditor = new TextFieldTextEditor();
				tfte.width = textInput.width;
				tfte.textFormat = TEXTFORMAT_TAG;
				return tfte;
			}
				
			textInput.promptFactory = function():ITextRenderer {
				var tr:TextFieldTextRenderer = new TextFieldTextRenderer();
				tr.width = textInput.width;
				tr.textFormat = TEXTFORMAT_TAG_TEXT_INPUT_PROMPT;
				return tr;
			}
			
		}
	}
}