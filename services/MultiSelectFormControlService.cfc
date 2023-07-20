/**
 * @presideService true
 * @singleton      true
 */
component {
// CONSTRUCTOR
	/**
	 * @multiSelectAllowListService.inject   MultiSelectAllowListService
	 */
	public any function init( required any multiSelectAllowListService ) {
		_setMultiSelectAllowListService( arguments.multiSelectAllowListService );

		return this;
	}

	public struct function processRequestParamsForSelect( required struct reqContext ) {
		return {
			  targetObject          = arguments.reqContext.targetObject  ?: ""
			, filterBy              = arguments.reqContext.filterBy      ?: ""
			, filterByField         = arguments.reqContext.filterByField ?: ( arguments.reqContext.filterBy ?: "" )
			, orderBy               = arguments.reqContext.orderBy       ?: "label"
			, dbFilters             = arguments.reqContext.dbFilters     ?: ""
			, maxRows               = arguments.reqContext.maxRows       ?: 0
			, searchTerm            = arguments.reqContext.searchTerm    ?: ""
			, ajaxTxtSearch         = $helpers.isTrue( arguments.reqContext.ajaxTxtSearch ?: 0 )
			, ajaxSearchCustomFilter = arguments.reqContext.ajaxSearchCustomFilter    ?: ""
		};
	}

	public boolean function isAjaxRequestAllowed( required struct preparedParams, boolean textSearch = false ) {
		var targetObject           = arguments.preparedParams.targetObject;
		var filterBy               = arguments.preparedParams.filterBy;
		var filterByField          = arguments.preparedParams.filterByField;
		var orderBy                = arguments.preparedParams.orderBy;
		var dbFilters              = arguments.preparedParams.dbFilters;
		var maxRows                = arguments.preparedParams.maxRows;
		var searchTerm             = arguments.preparedParams.searchTerm;
		var ajaxTxtSearch          = arguments.preparedParams.ajaxTxtSearch;
		var ajaxSearchCustomFilter = arguments.preparedParams.ajaxSearchCustomFilter

		if ( !Len( Trim( targetObject ) ) ||
			( arguments.textSearch && !ajaxTxtSearch ) ||
				( ajaxTxtSearch && !maxRows ) ||
					( arguments.textSearch && !Len( searchTerm ) )
		) {
			return false;
		}

		var requestAllowed = _getMultiSelectAllowListService().isParameterCombinationAllowed(
			  targetObject           = targetObject
			, filterBy               = filterBy
			, filterByField          = filterByField
			, orderBy                = orderBy
			, dbFilters              = dbFilters
			, maxRows                = maxRows
			, ajaxTxtSearch          = ajaxTxtSearch
			, ajaxSearchCustomFilter = ajaxSearchCustomFilter
		);

		if ( !requestAllowed ) {
			return false;
		}

		return true;
	}

	public array function getExtraFiltersFromFilterByValues( required struct reqContext, required array filterBy, required array filterByField, required string targetObject ) {

		if ( !ArrayLen( arguments.filterBy ) ) {
			return [];
		}

		var extraFilters = [];
		var i            = 0;
		for( var key in arguments.filterBy ) {
			var filter = {};

			i++;

			if ( structKeyExists( arguments.reqContext, key ) ) {
				if ( ListLen( arguments.filterByField[ i ], "." ) > 1 ) {
					filter[ arguments.filterByField[ i ] ] = ListToArray( arguments.reqContext[ key ] );
				} else {
					filter[ "#arguments.targetObject#.#arguments.filterByField[ i ]#" ] = ListToArray( arguments.reqContext[ key ] );
				}

				ArrayAppend( extraFilters, { filter = filter } );
			}
		}

		return extraFilters;
	}

	private any function _getMultiSelectAllowListService() {
		return _multiSelectAllowListService;
	}
	private void function _setMultiSelectAllowListService( required any multiSelectAllowListService ) {
		_multiSelectAllowListService = arguments.multiSelectAllowListService;
	}
}