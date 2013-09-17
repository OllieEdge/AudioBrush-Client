package com.edgington.util.localisation
{
	import com.edgington.util.debug.LOG;

	/**
	 * Localisation helper; calls through to the LOCALE_INSTANCE variable to retrieve the supplied key, creating a 
	 * log message should the key not be avaliable.
	 */
	public function gettext(localeKey : String, tokens : Object = null)  : String
	{
		if (!LOCALE_INSTANCE.contains(localeKey)) {
			LOG.info("'" + localeKey + "' has not been found in the currently loaded translations XML");
			return localeKey;
		}
		
		return LOCALE_INSTANCE.getString(localeKey, tokens);
	}
}