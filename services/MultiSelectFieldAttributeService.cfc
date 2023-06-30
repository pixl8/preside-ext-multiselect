/**
 * @presideService true
 * @singleton      true
 */
component {

	variables._selectFieldAttrCache = {};

// CONSTRUCTOR
	public any function init() {
		return this;
	}

	public void function addToSelectFieldAttritbutesCache(
		  required string partialUrl
		, required string fieldName
		,          string object        = ""
		,          string selectFields  = ""
		,          string filterBy      = ""
		,          string filterByField = ""
		,          string orderBy       = ""
		,          string savedFilters  = ""
		,         numeric maxRows       = 0
	) {
		var cacheKey = _getCacheKey( arguments.partialUrl, arguments.fieldName );

		if ( !StructKeyExists( variables._selectFieldAttrCache, cacheKey ) ) {
			variables._selectFieldAttrCache[ cacheKey ] = {
				  object        = arguments.object
				, selectFields  = arguments.selectFields
				, filterBy      = arguments.filterBy
				, filterByField = arguments.filterByField
				, orderBy       = arguments.orderBy
				, savedFilters  = arguments.savedFilters
				, maxRows       = arguments.maxRows
			};
		}
	}

	public struct function getFieldAttributes( required string requestUrl, required string fieldName ) {
		var urlRegex = "^(http[s]?):\/\/([^\/\s]+)([\/\w\-\.]+[^##?\s]*)?(?:\?([^##]*))?(?:##(.*))?$";
		var urlAnalyser = ReFindNoCase( urlRegex, arguments.requestUrl, 1, "true" );

		var cacheKey = _getCacheKey( urlAnalyser.match[ 4 ] ?: "", fieldName );

		return variables._selectFieldAttrCache[ cacheKey ] ?: {};
	}

	private string function _getCacheKey(
		  required string partialUrl
		, required string fieldName
	) {
		return _getPageSlug( arguments.partialUrl & "." & arguments.fieldName );
	}

	private string function _getPageSlug( required string partialUrl ) {
		return ListLast( partialUrl, "/" );
	}
}