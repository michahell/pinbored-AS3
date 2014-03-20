package nl.powergeek.pinbored.services
{
	public class UrlCheckerFactory
	{
		public function UrlCheckerFactory()
		{
		}
		
		public static function get():UrlChecker {
			return new UrlChecker();
		}
	}
}