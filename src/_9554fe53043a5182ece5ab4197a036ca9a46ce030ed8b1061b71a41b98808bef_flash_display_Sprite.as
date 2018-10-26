package
{
	COMPILE::SWF {
		import flash.display.Sprite;
		import flash.system.Security;
	}
		
	[ExcludeClass]
	COMPILE::SWF
	public class _9554fe53043a5182ece5ab4197a036ca9a46ce030ed8b1061b71a41b98808bef_flash_display_Sprite extends Sprite
	{
		
		
		public function _9554fe53043a5182ece5ab4197a036ca9a46ce030ed8b1061b71a41b98808bef_flash_display_Sprite()
		{
			super();
		}
		
		public function allowDomainInRSL(... rest) : void
		{
			Security.allowDomain.apply(null,rest);
		}
		
		public function allowInsecureDomainInRSL(... rest) : void
		{
			Security.allowInsecureDomain.apply(null,rest);
		}
	}
}
