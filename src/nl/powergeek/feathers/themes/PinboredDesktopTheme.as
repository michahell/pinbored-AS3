package nl.powergeek.feathers.themes
{
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.Panel;
	import feathers.controls.ScrollContainer;
	import feathers.controls.TextInput;
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.controls.text.TextFieldTextEditor;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.core.FeathersControl;
	import feathers.core.ITextEditor;
	import feathers.core.ITextRenderer;
	import feathers.core.PopUpManager;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.HorizontalLayout;
	import feathers.skins.SmartDisplayObjectStateValueSelector;
	import feathers.themes.MetalWorksMobileTheme;
	
	import feathersx.controls.text.HyperlinkTextFieldTextRenderer;
	
	import flash.text.Font;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import nl.powergeek.feathers.components.Pager;
	import nl.powergeek.feathers.components.RoundedStrokeButtonSkin;
	import nl.powergeek.feathers.components.FilterBar;
	import nl.powergeek.pinbored.model.BookmarkEvent;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.display.graphics.RoundedRectangle;
	import starling.display.materials.FlatColorMaterial;
	import starling.display.materials.IMaterial;
	import starling.display.materials.StandardMaterial;
	
	public class PinboredDesktopTheme extends MetalWorksMobileTheme
	{
		// embedded fonts
		[Embed(source="assets/fonts/pinbored/OpenSans-Light.ttf", fontName="OpenSansLight", mimeType="application/x-font", embedAsCFF="false")]
		private static const OpenSansLight:Class;
		public static var OpenSansLightFont:Font = new OpenSansLight();
		
		[Embed(source="assets/fonts/pinbored/OpenSans-Bold.ttf", fontName="OpenSansBold", fontWeight="bold", mimeType="application/x-font", embedAsCFF="false")]
		private static const OpenSansBold:Class;
		public static var OpenSansBoldFont:Font = new OpenSansBold();
		
		
		// backgrounds
		[Embed(source="assets/images/pinbored/backgrounds/background1.png")]
		public static const BACKGROUND1:Class;
		
		[Embed(source="assets/images/pinbored/backgrounds/background2.png")]
		public static const BACKGROUND2:Class;
		

		// logos
		[Embed(source="assets/images/pinbored/logo/pinbored-icon.png")]
		public static const ICON_TRANSPARENT:Class;
		
		[Embed(source="assets/images/pinbored/logo/pinbored-logo-transparent-text.png")]
		public static const LOGO_TRANSPARENT:Class;
		
		// user interface components or custom feather controls
		
		// tag scale 9 image
		[Embed(source="assets/images/pinbored/ui/scale3tag.png")]
		public static const SCALE_3_TAG_IMAGE:Class;
		
		
		// icons

		// checkmark
		[Embed(source="assets/images/pinbored/icons/icon_checkmark_active.png")]
		public static const ICON_CHECKMARK_ACTIVE:Class;
		
		[Embed(source="assets/images/pinbored/icons/icon_checkmark_white.png")]
		public static const ICON_CHECKMARK_WHITE:Class;
		
		// cross
		[Embed(source="assets/images/pinbored/icons/icon_cross_active.png")]
		public static const ICON_CROSS_ACTIVE:Class;
		
		[Embed(source="assets/images/pinbored/icons/icon_cross_white.png")]
		public static const ICON_CROSS_WHITE:Class;
		
		// heart
		[Embed(source="assets/images/pinbored/icons/icon_heart_active.png")]
		public static const ICON_HEART_ACTIVE:Class;
		
		[Embed(source="assets/images/pinbored/icons/icon_heart_white.png")]
		public static const ICON_HEART_WHITE:Class;
		
		// tags
		[Embed(source="assets/images/pinbored/icons/icon_tags_active.png")]
		public static const ICON_TAG_ACTIVE:Class;
		
		[Embed(source="assets/images/pinbored/icons/icon_tags_white.png")]
		public static const ICON_TAG_WHITE:Class;
		
		// loading
		[Embed(source="assets/images/pinbored/icons/icon-loading.png")]
		public static const ICON_LOADING:Class;
		
		// starling
		[Embed(source="assets/images/pinbored/icons/starling-logo.png")]
		public static const ICON_STARLING:Class;
		
		// feathers :>
		[Embed(source="assets/images/pinbored/icons/feathers-logo.png")]
		public static const ICON_FEATHERS:Class;
		
		
		// alternate skin names
		public static const
			TEXTINPUT_TRANSPARENT_BACKGROUND:String = 'pinbored-transparent-background-textinput',
			TEXTINPUT_SEARCH:String = 'pinbored-search-textinput',
			TEXTINPUT_TRANSLUCENT_BOX:String = 'pinbored-translucent-box-textinput',
			TEXTINPUT_INLINE_TRANSLUCENT:String = 'pinbored-inline-translucent-textinput',
			TEXTINPUT_INLINE_SEMI_TRANSLUCENT:String = 'pinbored-inline-semi-translucent-textinput',
			
			
			TEXTAREA_TRANSLUCENT_BOX:String = 'pinbored-translucent-box-textarea',
			
			LABEL_TAG_TEXTRENDERER:String = 'pinbored-tag-label',
			LABEL_DISCLAIMER:String = 'pinbored-disclaimer-label',
			LABEL_AUTHOR_LINK:String = 'pinbored-authorlink-label',
			LABEL_RIGHT_ALIGNED_TEXT:String = 'pinbored-right-aligned-label',
			LABEL_BOOKMARK_DESCRIPTION:String = 'pinbored-bookmark-description-label',
			LABEL_BOOKMARK_HREF:String = 'pinbored-bookmark-href-label',
			
			PANEL_TRANSPARENT_BACKGROUND:String = 'pinboredtransparent-background-panel',
			
			BUTTON_QUAD_CONTEXT_PRIMARY:String = 'pinbored-quad-context-edit-button',
			BUTTON_QUAD_CONTEXT_DELETE:String = 'pinbored-quad-context-delete-button',
			BUTTON_QUAD_CONTEXT_SUCCESS:String = 'pinbored-quad-context-secondary-button',
			BUTTON_QUAD_CONTEXT_ALTERNATIVE:String = 'pinbored-quad-context-ternary-button',
			BUTTON_PAGER_SMALL_DEFAULT:String = 'pinbored-pager-small-default-button',
			BUTTON_NUMBERED_PAGER_SMALL_DEFAULT:String = 'pinbored-pager-small-numbered-default-button',
			BUTTON_QUAD_HOTKEYABLE:String = 'pinbored-quad-hotkeyable-button',
			
			PAGER_HORIZONTAL_DEFAULT:String = 'pinbored-horizontal-default-pager';
			
		// some static constants for 'internal' use
		public static const
			BUTTON_DEFAULT_ALPHA:Number = 1,
			CONTEXT_BUTTON_DEFAULT_ALPHA:Number = 0.9,
			ANIMATION_TIME:Number = 0.5,
			LIST_ANIMATION_TIME:Number = 0.5;
			
		// textformats
		public static var
			TEXTFORMAT_TAG:TextFormat = new TextFormat(OpenSansBoldFont.fontName, 14, 0xFFFFFF, true),
			TEXTFORMAT_TAG_TEXT_INPUT_PROMPT:TextFormat = new TextFormat(OpenSansBoldFont.fontName, 14, 0xAAAAAA, true),
			
			TEXTFORMAT_DISCLAIMER:TextFormat = new TextFormat(OpenSansBoldFont.fontName, 10, 0xAAAAAA, false),
			TEXTFORMAT_LINK:TextFormat = new TextFormat(OpenSansBoldFont.fontName, 10, 0x0099FF, false, null, true),
			TEXTFORMAT_SCREEN_TITLE:TextFormat = new TextFormat(OpenSansLightFont.fontName, 20, 0xEEEEEE, false),
			
			TEXTFORMAT_BOOKMARK_DESCRIPTION:TextFormat = new TextFormat(OpenSansLightFont.fontName, 13, 0xEEEEEE, false),
			TEXTFORMAT_BOOKMARK_HREF:TextFormat = new TextFormat(OpenSansLightFont.fontName, 12, 0x55BBFF, false, null, true),
			
			TEXTFORMAT_PAGER:TextFormat = new TextFormat(OpenSansBoldFont.fontName, 10, 0xEEEEEE, true),
			TEXTFORMAT_PAGER_DISABLED:TextFormat = new TextFormat(OpenSansBoldFont.fontName, 10, 0x999999, true),
			TEXTFORMAT_PAGER_DISABLED_HIGHLIGHT:TextFormat = new TextFormat(OpenSansBoldFont.fontName, 10, 0xAABBFF, true),
		
			TEXTFORMAT_BUTTON_DEFAULT:TextFormat = new TextFormat(OpenSansBoldFont.fontName, 10, 0xEEEEEE, true),
			TEXTFORMAT_BUTTON_HOVER:TextFormat = new TextFormat(OpenSansBoldFont.fontName, 10, 0xEEEEEE, true),
			TEXTFORMAT_BUTTON_DISABLED:TextFormat = new TextFormat(OpenSansBoldFont.fontName, 10, 0xEEEEEE, true),
			
			TEXTFORMAT_BUTTON_ALTERNATIVE_DEFAULT:TextFormat = new TextFormat(OpenSansBoldFont.fontName, 10, 0x333333, true),
			TEXTFORMAT_BUTTON_ALTERNATIVE_HOVER:TextFormat = new TextFormat(OpenSansBoldFont.fontName, 10, 0x333333, true),
			TEXTFORMAT_BUTTON_ALTERNATIVE_DISABLED:TextFormat = new TextFormat(OpenSansBoldFont.fontName, 10, 0x333333, true);
			
		
		public function PinboredDesktopTheme(container:DisplayObjectContainer=null, scaleToDPI:Boolean=true)
		{
			super(container, scaleToDPI);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			// custom text input skins
			this.setInitializerForClass(TextInput, transparentTagTextInputInitializer, TEXTINPUT_TRANSPARENT_BACKGROUND);
			this.setInitializerForClass(TextInput, pinboredSearchTextInputInitializer, TEXTINPUT_SEARCH);
			this.setInitializerForClass(TextInput, pinboredTranslucentTextInputInitializer, TEXTINPUT_TRANSLUCENT_BOX);
			this.setInitializerForClass(TextInput, pinboredInlineTextInputInitializer, TEXTINPUT_INLINE_TRANSLUCENT);
			this.setInitializerForClass(TextInput, pinboredInlineSemiTextInputInitializer, TEXTINPUT_INLINE_SEMI_TRANSLUCENT);
			
			this.setInitializerForClass(TextInput, pinboredTranslucentTextAreaInitializer, TEXTAREA_TRANSLUCENT_BOX);
			
			// custom quad buttons
			this.setInitializerForClass(Button, quadContextPrimaryButtonInitializer, BUTTON_QUAD_CONTEXT_PRIMARY);
			this.setInitializerForClass(Button, quadContextDeleteButtonInitializer, BUTTON_QUAD_CONTEXT_DELETE);
			this.setInitializerForClass(Button, quadContextSuccessButtonInitializer, BUTTON_QUAD_CONTEXT_SUCCESS);
			this.setInitializerForClass(Button, quadContextAlternativeButtonInitializer, BUTTON_QUAD_CONTEXT_ALTERNATIVE);
			this.setInitializerForClass(Button, pagerDefaultButtonInitializer, BUTTON_PAGER_SMALL_DEFAULT);
			this.setInitializerForClass(Button, pagerDefaultNumberedButtonInitializer, BUTTON_NUMBERED_PAGER_SMALL_DEFAULT);
			
			this.setInitializerForClass(Button, quadContextHotkeyableButtonInitializer, BUTTON_QUAD_HOTKEYABLE);
			
			// transparent panel
			this.setInitializerForClass(Panel, transparentPanelInitializer, PANEL_TRANSPARENT_BACKGROUND);
			
			// some label styles
			this.setInitializerForClass(Label, tagLabelInitializer, LABEL_TAG_TEXTRENDERER);
			this.setInitializerForClass(Label, disclaimerLabelInitializer, LABEL_DISCLAIMER);
			this.setInitializerForClass(Label, authorLinkLabelInitializer, LABEL_AUTHOR_LINK);
			this.setInitializerForClass(Label, rightAlignedTextLabelInitializer, LABEL_RIGHT_ALIGNED_TEXT);
			this.setInitializerForClass(Label, bookmarkLabelInitializer, LABEL_BOOKMARK_DESCRIPTION);
			this.setInitializerForClass(Label, bookmarkHrefInitializer, LABEL_BOOKMARK_HREF);
			
		}
		
		private function quadContextHotkeyableButtonInitializer(button:Button):void
		{
			this.quadContextPrimaryButtonInitializer(button);
			
			var topOffset:Number = 0;
			
			if(button.height != 0) {
				topOffset = button.height / 4;
			} else {
				topOffset = button.paddingTop;
			}
			
			// create stripe
			var stripe:Shape = new Shape();
			stripe.graphics.lineStyle(1, uint(TEXTFORMAT_BUTTON_DEFAULT.color), 1);
			stripe.graphics.moveTo(0, 0);
			stripe.graphics.lineTo(Number(TEXTFORMAT_BUTTON_DEFAULT.size) - 3, 0);
			stripe.graphics.endFill();
			
			// set stripe under label
			stripe.x = button.paddingLeft + 2;
			stripe.y = topOffset + Number(TEXTFORMAT_BUTTON_DEFAULT.size) + 5;
			
			button.addChild(stripe);
		}
		
		override protected function scrollContainerToolbarInitializer(container:ScrollContainer):void {
			if(!container.layout)
			{
				container.layout = new AnchorLayout();
			}
			
			container.minWidth = 50;
			container.minHeight = 30;
			
			var bg:Quad = new Quad(10, 10, 0x000000);
			bg.alpha = 0.3;
			container.backgroundSkin = bg;
		}
		
		private function bookmarkLabelInitializer(label:Label):void
		{
			label.textRendererFactory = function():ITextRenderer {
				var tr:TextFieldTextRenderer = new TextFieldTextRenderer();
				tr.width = label.width;
				tr.textFormat = TEXTFORMAT_BOOKMARK_DESCRIPTION;
				return tr;
			}
		}
		
		private function bookmarkHrefInitializer(label:Label):void
		{
			label.textRendererFactory = function():ITextRenderer {
				var tr:HyperlinkTextFieldTextRenderer = new HyperlinkTextFieldTextRenderer();
				tr.isHTML = true;
				tr.useHandCursor = true;
				tr.width = label.width;
				tr.textFormat = TEXTFORMAT_BOOKMARK_HREF;
				return tr;
			}
		}
		
		private function rightAlignedTextLabelInitializer(label:Label):void
		{
			label.textRendererFactory = function():ITextRenderer {
				var tr:TextFieldTextRenderer = new TextFieldTextRenderer();
				TEXTFORMAT_DISCLAIMER.align = TextFormatAlign.RIGHT;
				tr.textFormat = TEXTFORMAT_DISCLAIMER;
				return tr;
			}
		}
		
		private function authorLinkLabelInitializer(label:Label):void
		{
			label.textRendererFactory = function():ITextRenderer {
				var tr:HyperlinkTextFieldTextRenderer = new HyperlinkTextFieldTextRenderer();
				tr.isHTML = true;
				tr.useHandCursor = true;
				TEXTFORMAT_LINK.align = TextFormatAlign.RIGHT;
				tr.textFormat = TEXTFORMAT_LINK;
				return tr;
			}
		}
		
		private function disclaimerLabelInitializer(label:Label):void
		{
			label.textRendererFactory = function():ITextRenderer {
				var tr:TextFieldTextRenderer = new TextFieldTextRenderer();
				tr.wordWrap = true;
				TEXTFORMAT_DISCLAIMER.align = TextFormatAlign.LEFT;
				tr.textFormat = TEXTFORMAT_DISCLAIMER;
				return tr;
			}
		}
		
		private function pinboredInlineSemiTextInputInitializer(textInput:TextInput):void
		{
			// draw quad
			var backgroundSkin:Quad = new Quad(10, 10, 0x000000);
			backgroundSkin.alpha = 0.2;
			
			// text input background
			textInput.backgroundSkin = backgroundSkin;
			
			textInput.padding = 5;
			
			textInput.textEditorProperties.fontFamily = TEXTFORMAT_TAG.font;
			textInput.textEditorProperties.fontSize = Number(TEXTFORMAT_TAG.size);
			textInput.textEditorProperties.color = uint(TEXTFORMAT_TAG.color);
			
			textInput.textEditorProperties.embedFonts = true;
			textInput.textEditorProperties.height = 30;
			
			textInput.promptProperties.embedFonts = true;
			textInput.promptProperties.textFormat = TEXTFORMAT_TAG_TEXT_INPUT_PROMPT;
			textInput.promptProperties.height = 30;
		}
		
		private function pinboredInlineTextInputInitializer(textInput:TextInput):void
		{
			// draw quad
			var backgroundSkin:Quad = new Quad(10, 10, 0x000000);
			backgroundSkin.alpha = 0;
			
			// text input background
			textInput.backgroundSkin = backgroundSkin;
			
			textInput.padding = 5;
			
			textInput.textEditorProperties.fontFamily = TEXTFORMAT_TAG.font;
			textInput.textEditorProperties.fontSize = Number(TEXTFORMAT_TAG.size);
			textInput.textEditorProperties.color = uint(TEXTFORMAT_TAG.color);
			
			textInput.textEditorProperties.embedFonts = true;
			textInput.textEditorProperties.height = 30;
			
			textInput.promptProperties.embedFonts = true;
			textInput.promptProperties.textFormat = TEXTFORMAT_TAG_TEXT_INPUT_PROMPT;
			textInput.promptProperties.height = 30;
		}
		
		private function pinboredTranslucentTextAreaInitializer(textInput:TextInput):void
		{
			// draw quad
			var backgroundSkin:Quad = new Quad(10, 10, 0x000000);
			backgroundSkin.alpha = 0.1;
			
			// text input background
			textInput.backgroundSkin = backgroundSkin;
			
			textInput.padding = 10;
			
			textInput.textEditorFactory = function():ITextEditor {
				var tfte:TextFieldTextEditor = new TextFieldTextEditor();
				tfte.width = textInput.width;
				tfte.height = textInput.height;
				tfte.embedFonts = true;
				tfte.wordWrap = true;
				tfte.textFormat = TEXTFORMAT_TAG;
				return tfte;
			}
			
			textInput.promptFactory = function():ITextRenderer {
				var tr:TextFieldTextRenderer = new TextFieldTextRenderer();
				tr.width = textInput.width;
				tr.height = textInput.height;
				tr.embedFonts = true;
				tr.wordWrap = true;
				tr.textFormat = TEXTFORMAT_TAG_TEXT_INPUT_PROMPT;
				return tr;
			}
		}
		
		private function pinboredTranslucentTextInputInitializer(input:TextInput):void
		{
			// draw quad
			var backgroundSkin:Quad = new Quad(10, 10, 0x000000);
			backgroundSkin.alpha = 0.2;
			
			// text input background
			input.backgroundSkin = backgroundSkin;
			
			input.padding = 10;
			
			input.textEditorFactory = function():ITextEditor {
				var tfte:TextFieldTextEditor = new TextFieldTextEditor();
				tfte.width = input.width;
				tfte.embedFonts = true;
				tfte.textFormat = TEXTFORMAT_TAG;
				return tfte;
			}
			
			input.promptFactory = function():ITextRenderer {
				var tr:TextFieldTextRenderer = new TextFieldTextRenderer();
				tr.width = input.width;
				tr.embedFonts = true;
				tr.textFormat = TEXTFORMAT_TAG_TEXT_INPUT_PROMPT;
				return tr;
			}
		}
		
		private function pinboredSearchTextInputInitializer(input:TextInput):void
		{
			// background vars
			var color:uint = 0x000000;
			var endAlpha:Number = 0;
			var triangleWidth:Number = 20;
			var altitude:Number = 50;
			
			// define background
			var backgroundSkin:Sprite = new Sprite();
			
			// draw quad
			var quad:Quad = new Quad(300, altitude, color);
			quad.setVertexAlpha(1, endAlpha);
			quad.setVertexAlpha(3, endAlpha);
			
			// draw triangle
			var triangle:Shape = new Shape();
			triangle.graphics.beginFill(color);
			triangle.graphics.moveTo(0, altitude / 2);
			triangle.graphics.lineTo(triangleWidth, 0);
			triangle.graphics.lineTo(triangleWidth, quad.height);
			triangle.graphics.lineTo(0, altitude / 2);
			triangle.graphics.endFill();
			
			// compose background of quad + triangle and set alpha
			backgroundSkin.addChild(triangle);
			quad.x = triangleWidth;
			backgroundSkin.addChild(quad);
			backgroundSkin.alpha = 0.3;
			
			// text input background
			input.backgroundSkin = backgroundSkin;
			
			
			input.textEditorFactory = function():ITextEditor {
				var tfte:TextFieldTextEditor = new TextFieldTextEditor();
				tfte.width = input.width;
				tfte.textFormat = TEXTFORMAT_TAG;
				return tfte;
			}
			
			input.promptFactory = function():ITextRenderer {
				var tr:TextFieldTextRenderer = new TextFieldTextRenderer();
				tr.width = input.width;
				tr.textFormat = TEXTFORMAT_TAG_TEXT_INPUT_PROMPT;
				return tr;
			}
			
			// gap update
			input.gap = 5;
			
			// add search icon
			var searchIcon:ImageLoader = new ImageLoader();
			searchIcon.source = this.searchIconTexture;
			searchIcon.snapToPixels = true;
			searchIcon.padding = 0;
			searchIcon.paddingTop = 4;
			searchIcon.paddingLeft = 10;
			input.defaultIcon = searchIcon;
			
			// padding
			input.paddingTop = altitude / 2 - 12;
			input.paddingBottom = 0;
			input.paddingLeft = input.paddingRight = searchIcon.paddingLeft + 8;
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
		
		private function pagerDefaultNumberedButtonInitializer(button:Button):void
		{
			pagerDefaultButtonInitializer(button);
			
			var disabledSkin:Quad = new Quad(10, 10, 0x0066CC);
			disabledSkin.alpha = 0.6;
			button.disabledSkin = disabledSkin;
			
			button.disabledLabelProperties.textFormat = TEXTFORMAT_PAGER_DISABLED_HIGHLIGHT;
		}
		
		private function pagerDefaultButtonInitializer(button:Button):void
		{
			var defaultSkin:Quad = new Quad(10, 10, 0x000000);
			defaultSkin.alpha = 0;//0.5;
			button.defaultSkin = defaultSkin;
			
			var downSkin:Quad = new Quad(10, 10, 0x000000);
			downSkin.alpha = 0.1;//.3;
			button.downSkin = downSkin;
			
			var hoverSkin:Quad = new Quad(10, 10, 0x000000);
			hoverSkin.alpha = 0.5;//0.7;
			button.hoverSkin = hoverSkin;
			
			var disabledSkin:Quad = new Quad(10, 10, 0x000000);
			disabledSkin.alpha = 0;//0.5;
			button.disabledSkin = disabledSkin;
			
			button.padding = 3;
			button.paddingLeft = button.paddingRight = 5;
			
			button.defaultLabelProperties.embedFonts = true;
			button.disabledLabelProperties.embedFonts = true;
			button.selectedDisabledLabelProperties.embedFonts = true;
			
			button.defaultLabelProperties.textFormat = TEXTFORMAT_PAGER;
			button.disabledLabelProperties.textFormat = TEXTFORMAT_PAGER_DISABLED;
			button.selectedDisabledLabelProperties.textFormat = TEXTFORMAT_PAGER_DISABLED;
			
			// use hand cursor over button
			button.useHandCursor = true;
		}
		
		private function quadContextAlternativeButtonInitializer(button:Button):void
		{
//			var defaultSkin:RoundedRectangle = new RoundedRectangle(10, 10, 3, 3, 3, 3);
//			defaultSkin.material = new FlatColorMaterial(0xC7C7C7);
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
			button.hoverLabelProperties.embedFonts = true;
			button.disabledLabelProperties.embedFonts = true;
			button.selectedDisabledLabelProperties.embedFonts = true;
			
			button.defaultLabelProperties.textFormat = TEXTFORMAT_BUTTON_ALTERNATIVE_DEFAULT;
			button.hoverLabelProperties.textFormat = TEXTFORMAT_BUTTON_ALTERNATIVE_HOVER;
			button.disabledLabelProperties.textFormat = TEXTFORMAT_BUTTON_ALTERNATIVE_DISABLED;
			button.selectedDisabledLabelProperties.textFormat = TEXTFORMAT_BUTTON_ALTERNATIVE_DISABLED;
			
			// use hand cursor over button
			button.useHandCursor = true;
		}
		
		private function quadContextSuccessButtonInitializer(button:Button):void
		{
//			var defaultSkin:RoundedRectangle = new RoundedRectangle(10, 10, 3, 3, 3, 3);
//			defaultSkin.material = new FlatColorMaterial(0x5CB85C);
			var defaultSkin:Quad = new Quad(10, 10, 0x5CB85C);
			defaultSkin.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.defaultSkin = defaultSkin;
			
			var downSkin:Quad = new Quad(10, 10, 0x5CB85C);
//			downSkin.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.downSkin = downSkin;
			
			var hoverSkin:Quad = new Quad(10, 10, 0x5CB85C);
//			hoverSkin.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.hoverSkin = hoverSkin;
			
			var disabledSkin:Quad = new Quad(10, 10, 0xCCF5CE);
//			disabledSkin.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.disabledSkin = disabledSkin;
			
			button.padding = 5;
			button.paddingLeft = button.paddingRight = 15;
			
			button.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			
			button.defaultLabelProperties.embedFonts = true;
			button.hoverLabelProperties.embedFonts = true;
			button.disabledLabelProperties.embedFonts = true;
			button.selectedDisabledLabelProperties.embedFonts = true;
			
			button.defaultLabelProperties.textFormat = TEXTFORMAT_BUTTON_DEFAULT;
			button.hoverLabelProperties.textFormat = TEXTFORMAT_BUTTON_HOVER;
			button.disabledLabelProperties.textFormat = TEXTFORMAT_BUTTON_DISABLED;
			button.selectedDisabledLabelProperties.textFormat = TEXTFORMAT_BUTTON_DISABLED;
			
			// use hand cursor over button
			button.useHandCursor = true;
		}
		
		private function quadContextDeleteButtonInitializer(button:Button):void
		{
//			var defaultSkin:RoundedRectangle = new RoundedRectangle(10, 10, 3, 3, 3, 3);
//			defaultSkin.material = new FlatColorMaterial(0xCF4F4B);
			var defaultSkin:Quad = new Quad(10, 10, 0xCF4F4B);
//			defaultSkin.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.defaultSkin = defaultSkin;
			
			var downSkin:Quad = new Quad(10, 10, 0xCF312C);
//			downSkin.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.downSkin = downSkin;
			
			var hoverSkin:Quad = new Quad(10, 10, 0xCF312C);
//			hoverSkin.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.hoverSkin = hoverSkin;
			
			var disabledSkin:Quad = new Quad(10, 10, 0xEAB0AE);
//			disabledSkin.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			button.disabledSkin = disabledSkin;
			
			button.padding = 5;
			button.paddingLeft = button.paddingRight = 15;
			
			button.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			
			button.defaultLabelProperties.embedFonts = true;
			button.hoverLabelProperties.embedFonts = true;
			button.disabledLabelProperties.embedFonts = true;
			button.selectedDisabledLabelProperties.embedFonts = true;
			
			button.defaultLabelProperties.textFormat = TEXTFORMAT_BUTTON_DEFAULT;
			button.hoverLabelProperties.textFormat = TEXTFORMAT_BUTTON_HOVER;
			button.disabledLabelProperties.textFormat = TEXTFORMAT_BUTTON_DISABLED;
			button.selectedDisabledLabelProperties.textFormat = TEXTFORMAT_BUTTON_DISABLED;
			
			// use hand cursor over button
			button.useHandCursor = true;
		}
		
		private function quadContextPrimaryButtonInitializer(button:Button):void
		{
			var defaultSkin:Quad = new Quad(10, 10, 0x428BCA);
			button.defaultSkin = defaultSkin;
			
			var downSkin:Quad = new Quad(10, 10, 0x2266A1);
			button.downSkin = downSkin;
			
			var hoverSkin:Quad = new Quad(10, 10, 0x3276B1);
			button.hoverSkin = hoverSkin;
			
			var disabledSkin:Quad = new Quad(10, 10, 0x80B0DB);
			button.disabledSkin = disabledSkin;
			
			// SELECTED SKIN
			button.selectedHoverSkin = hoverSkin;
			button.selectedDownSkin = defaultSkin;
			button.selectedUpSkin = downSkin;
			
			button.padding = 5;
			button.paddingLeft = button.paddingRight = 15;
			
			button.alpha = CONTEXT_BUTTON_DEFAULT_ALPHA;
			
			button.defaultLabelProperties.embedFonts = true;
			button.hoverLabelProperties.embedFonts = true;
			button.disabledLabelProperties.embedFonts = true;
			button.selectedDisabledLabelProperties.embedFonts = true;
			
			button.defaultLabelProperties.textFormat = TEXTFORMAT_BUTTON_DEFAULT;
			button.hoverLabelProperties.textFormat = TEXTFORMAT_BUTTON_HOVER;
			button.disabledLabelProperties.textFormat = TEXTFORMAT_BUTTON_DISABLED;
			button.selectedDisabledLabelProperties.textFormat = TEXTFORMAT_BUTTON_DISABLED;
			
			// use hand cursor over button
			button.useHandCursor = true;
		}
		
		private function drawRoundedRectStrokeButton(width:int, height:int, cornerRadius:int, strokeWidth:int, strokeColor:Number = 0xFFFFFF, strokeAlpha:Number = 1, bgColor:Number = 0x000000, bgAlpha:Number = 0):RoundedStrokeButtonSkin
		{	
			return new RoundedStrokeButtonSkin(width, height, cornerRadius, strokeWidth, strokeColor, strokeAlpha, bgColor, bgAlpha);
		}
		
		private function transparentPanelInitializer(panel:Panel):void
		{
			var bg:Quad = new Quad(10, 10, 0x000000);
			bg.alpha = 0.15;
			panel.backgroundSkin = bg;
			panel.backgroundDisabledSkin = bg;
		}
		
		private function transparentTagTextInputInitializer(textInput:TextInput):void
		{
			// define background
			var backgroundSkin:Quad = new Quad(10, 10, 0xFFFFFF);
			backgroundSkin.alpha = 0;
			
			// text input background
			textInput.backgroundSkin = backgroundSkin;
			
			textInput.textEditorFactory = function():ITextEditor {
				var tfte:TextFieldTextEditor = new TextFieldTextEditor();
				tfte.width = textInput.width;
				tfte.embedFonts = true;
				tfte.textFormat = TEXTFORMAT_TAG;
				return tfte;
			}
				
			textInput.promptFactory = function():ITextRenderer {
				var tr:TextFieldTextRenderer = new TextFieldTextRenderer();
				tr.width = textInput.width;
				tr.embedFonts = true;
				tr.textFormat = TEXTFORMAT_TAG_TEXT_INPUT_PROMPT;
				return tr;
			}
			
		}
	}
}