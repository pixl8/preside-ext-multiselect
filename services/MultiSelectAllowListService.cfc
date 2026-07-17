/**
 * @presideService true
 * @singleton      true
 */
component {

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
		var hashedCacheKey = Hash( _getCacheKey( argumentCollection=arguments ) );

		try {
			$getPresideObject( "multiselect_allow_list" ).insertData( data={ id=hashedCacheKey } );
		} catch ( database e ) {
			if ( !$getPresideObject( "multiselect_allow_list" ).dataExists( id=hashedCacheKey, useCache=false ) ) {
				rethrow;
			}
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
		var hashedCacheKey = Hash( _getCacheKey( argumentCollection=arguments ) );

		return $getPresideObject( "multiselect_allow_list" ).dataExists( id=hashedCacheKey, useCache=false );
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