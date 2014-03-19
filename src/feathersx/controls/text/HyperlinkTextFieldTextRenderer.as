package feathersx.controls.text
{
	import feathers.controls.text.TextFieldTextRenderer;
	
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class HyperlinkTextFieldTextRenderer extends TextFieldTextRenderer
	{
		private static const HELPER_POINT:Point = new Point();
		
		public function HyperlinkTextFieldTextRenderer()
		{
			this.isHTML = true;
		}
		
		override public function set isHTML(value:Boolean):void
		{
			super.isHTML = value;
			if(this._isHTML)
			{
				this.addEventListener(TouchEvent.TOUCH, touchHandler);
			}
			else
			{
				this.removeEventListener(TouchEvent.TOUCH, touchHandler);
			}
		}
		
		/**
		 * @private
		 */
		protected function touchHandler(event:TouchEvent):void
		{
			if(!this._isHTML)
			{
				return;
			}
			var touch:Touch = event.getTouch(this, TouchPhase.ENDED);
			if(!touch)
			{
				return;
			}
			touch.getLocation(this, HELPER_POINT);
			var charIndex:int = this.textField.getCharIndexAtPoint(HELPER_POINT.x, HELPER_POINT.y);
			var htmlCharIndex:int = -1;
			var htmlText:String = this._text;
			var regularText:String = this.textField.text;
			var htmlTextLength:int = htmlText.length;
			var lastHTMLContent:String;
			for(var i:int = 0; i <= charIndex; i++)
			{
				htmlCharIndex++;
				var regularChar:String = regularText.charAt(i);
				var htmlChar:String = htmlText.charAt(htmlCharIndex);
				do
				{
					if(htmlCharIndex >= htmlTextLength)
					{
						break;
					}
					if(htmlChar == "<")
					{
						var skipTo:int = htmlText.indexOf(">", htmlCharIndex);
						lastHTMLContent = htmlText.substr(htmlCharIndex + 1, skipTo - htmlCharIndex - 1);
						htmlCharIndex = skipTo + 1;
						htmlChar = htmlText.charAt(htmlCharIndex);
					}
					else if(htmlChar == "&")
					{
						skipTo = htmlText.indexOf(";", htmlCharIndex);
						//var entityName:String = (htmlText.substr(htmlCharIndex + 1, skipTo - htmlCharIndex - 1));
						htmlCharIndex = skipTo;
						htmlChar = regularChar;
					}
				}
				while(htmlChar != regularChar);
			}
			if(!lastHTMLContent || lastHTMLContent.search(/^a\s+/) != 0)
			{
				return;
			}
			var linkStartIndex:int = lastHTMLContent.search(/href=[\"\']/) + 6;
			if(linkStartIndex < 2)
			{
				return;
			}
			var linkEndIndex:int = lastHTMLContent.indexOf("\"", linkStartIndex + 1);
			if(linkEndIndex < 0)
			{
				linkEndIndex = lastHTMLContent.indexOf("'", linkStartIndex + 1);
				if(linkEndIndex < 0)
				{
					return;
				}
			}
			var url:String = lastHTMLContent.substr(linkStartIndex, linkEndIndex - linkStartIndex);
			navigateToURL(new URLRequest(url));
		}
	}
}