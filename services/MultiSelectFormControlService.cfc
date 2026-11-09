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
			  targetObject           = arguments.reqContext.targetObject           ?: ""
			, filterBy               = arguments.reqContext.filterBy               ?: ""
			, filterByField          = arguments.reqContext.filterByField          ?: ( arguments.reqContext.filterBy ?: "" )
			, orderBy                = arguments.reqContext.orderBy                ?: "label"
			, dbFilters              = arguments.reqContext.dbFilters              ?: ""
			, maxRows                = arguments.reqContext.maxRows                ?: 0
			, searchTerm             = arguments.reqContext.searchTerm             ?: ""
			, ajaxTxtSearch          = $helpers.isTrue( arguments.reqContext.ajaxTxtSearch ?: 0 )
			, ajaxSearchCustomFilter = arguments.reqContext.ajaxSearchCustomFilter ?: ""
			, selectFieldsKey        = arguments.reqContext.selectFieldsKey        ?: ""
		};
	}

	public boolean function isAjaxRequestAllowed( required struct preparedParams, boolean textSearch = false ) {
		var allowListArguments = _getAllowListArguments( arguments.preparedParams );
		var targetObject       = allowListArguments.targetObject;
		var maxRows            = allowListArguments.maxRows;
		var searchTerm         = arguments.preparedParams.searchTerm ?: "";
		var ajaxTxtSearch      = allowListArguments.ajaxTxtSearch;

		if ( !Len( Trim( targetObject ) ) ||
			( arguments.textSearch && !ajaxTxtSearch ) ||
				( ajaxTxtSearch && !maxRows ) ||
					( !arguments.textSearch && Len( searchTerm ) )
		) {
			return false;
		}

		return _getMultiSelectAllowListService().isParameterCombinationAllowed( argumentCollection=allowListArguments );
	}

	public array function getAllowedSelectFields( required struct preparedParams ) {
		return _getMultiSelectAllowListService().getAllowedSelectFields(
			argumentCollection = _getAllowListArguments( arguments.preparedParams )
		);
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

	private struct function _getAllowListArguments( required struct preparedParams ) {
		return {
			  targetObject           = arguments.preparedParams.targetObject           ?: ""
			, filterBy               = arguments.preparedParams.filterBy               ?: ""
			, filterByField          = arguments.preparedParams.filterByField          ?: ""
			, orderBy                = arguments.preparedParams.orderBy                ?: ""
			, dbFilters              = arguments.preparedParams.dbFilters              ?: ""
			, maxRows                = arguments.preparedParams.maxRows                ?: 0
			, ajaxTxtSearch          = arguments.preparedParams.ajaxTxtSearch          ?: false
			, ajaxSearchCustomFilter = arguments.preparedParams.ajaxSearchCustomFilter ?: ""
			, selectFieldsKey        = arguments.preparedParams.selectFieldsKey        ?: ""
		};
	}

	private any function _getMultiSelectAllowListService() {
		return _multiSelectAllowListService;
	}
	private void function _setMultiSelectAllowListService( required any multiSelectAllowListService ) {
		_multiSelectAllowListService = arguments.multiSelectAllowListService;
	}
}