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
	public string function addToAllowList(
		  string targetObject  = ""
		, string filterBy      = ""
		, string filterByField = ""
		, string orderBy       = ""
		, string dbFilters     = ""
		, array  selectFields  = []
	) {
		var selectFieldsKey = _getSelectFieldsKey( arguments.selectFields );
		var cacheKey        = _getCacheKey(
			  targetObject    = arguments.targetObject
			, filterBy        = arguments.filterBy
			, filterByField   = arguments.filterByField
			, orderBy         = arguments.orderBy
			, dbFilters       = arguments.dbFilters
			, selectFieldsKey = selectFieldsKey
		);

		variables._allowListCache[ cacheKey ] = Duplicate( arguments.selectFields );

		return selectFieldsKey;
	}

	public boolean function isParameterCombinationAllowed(
		  string targetObject    = ""
		, string filterBy        = ""
		, string filterByField   = ""
		, string orderBy         = ""
		, string dbFilters       = ""
		, string selectFieldsKey = ""
	) {
		return StructKeyExists( variables._allowListCache, _getCacheKey( argumentCollection=arguments ) );
	}

	public array function getAllowedSelectFields(
		  string targetObject    = ""
		, string filterBy        = ""
		, string filterByField   = ""
		, string orderBy         = ""
		, string dbFilters       = ""
		, string selectFieldsKey = ""
	) {
		var selectFields = variables._allowListCache[ _getCacheKey( argumentCollection=arguments ) ] ?: [];

		return IsArray( selectFields ) ? Duplicate( selectFields ) : [];
	}

// PRIVATE HELPERS
	private string function _getCacheKey(
		  string targetObject    = ""
		, string filterBy        = ""
		, string filterByField   = ""
		, string orderBy         = ""
		, string dbFilters       = ""
		, string selectFieldsKey = ""
	) {
		return "targetObject:#arguments.targetObject#,filterBy:#arguments.filterBy#,filterByField:#arguments.filterByField#,orderBy:#arguments.orderBy#,dbFilters:#arguments.dbFilters#,selectFieldsKey=#arguments.selectFieldsKey#";
	}

	private string function _getSelectFieldsKey( required array selectFields ) {
		return LCase( Hash( ArrayToList( arguments.selectFields, Chr( 31 ) ), "MD5" ) );
	}

}
