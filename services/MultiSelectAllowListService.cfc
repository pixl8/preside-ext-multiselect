/**
 * @presideService true
 * @singleton      true
 */
component {

	variables._allowListCache = {};

// CONSTRUCTOR
	public any function init() {
		return this;
	}

// PUBLIC API METHODS
	public void function addToAllowList(
		  string targetObject           = ""
		, string filterBy               = ""
		, string filterByField          = ""
		, string orderBy                = ""
		, string dbFilters              = ""
		, numeric maxRows               = 0
		, boolean ajaxTxtSearch         = false
		, string ajaxSearchCustomFilter = ""
	) {
		var cacheKey = _getCacheKey( argumentCollection=arguments );

		if ( !StructKeyExists( variables._allowListCache, cacheKey ) ) {
			variables._allowListCache[ cacheKey ] = true;
		}
	}

	public boolean function isParameterCombinationAllowed(
		  string targetObject           = ""
		, string filterBy               = ""
		, string filterByField          = ""
		, string orderBy                = ""
		, string dbFilters              = ""
		, numeric maxRows               = 0
		, boolean ajaxTxtSearch         = false
		, string ajaxSearchCustomFilter = ""
	) {
		return variables._allowListCache[ _getCacheKey( argumentCollection=arguments ) ] ?: false;
	}

// PRIVATE HELPERS
	private string function _getCacheKey(
		  string targetObject           = ""
		, string filterBy               = ""
		, string filterByField          = ""
		, string orderBy                = ""
		, string dbFilters              = ""
		, numeric maxRows               = 0
		, boolean ajaxTxtSearch         = false
		, string ajaxSearchCustomFilter = ""
	) {
		return "targetObject:#arguments.targetObject#,filterBy:#arguments.filterBy#,filterByField:#arguments.filterByField#,orderBy:#arguments.orderBy#,dbFilters:#arguments.dbFilters#,maxRows:#arguments.maxRows#,ajaxTxtSearch=#arguments.ajaxTxtSearch#,ajaxSearchCustomFilter=#arguments.ajaxSearchCustomFilter#";
	}
}