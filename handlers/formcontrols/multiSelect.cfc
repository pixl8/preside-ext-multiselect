component {
	property name="presideObjectService"               inject="PresideObjectService";
	property name="multiSelectAllowListService"        inject="multiSelectAllowListService";
	property name="multiSelectFormControlService"      inject="multiSelectFormControlService";
	property name="includeChosenJs"                    inject="coldbox:setting:multiSelect.includeChosenJs";
	property name="dataManagerService"                 inject="DataManagerService";

	public string function index( event, rc, prc, args={} ) {
		var object           = args.object        ?: "";
		var labelField       = args.labelField    ?: "label";
		var savedFilters     = args.objectFilters ?: "";
		var defaultEmptyList = args.defaultEmptyList ?: false;
		var orderBy          = args.orderBy       ?: 'label';
		var valueField       = args.valueField    ?: '';
		var filterBy         = args.filterBy      ?: "";
		var filterByField    = args.filterByField ?: filterBy;
		var selectFields     = [ "id",labelField & " as label" ];

		var ajaxSearch       = IsTrue( args.ajaxTextSearch ?: "" );
		var fieldName        = args.name ?: "";
		var maxRows          = ajaxSearch ? ( args.ajaxMaxRows ?: 0 ) : 0;

		multiSelectAllowListService.addToAllowList(
			  targetObject  = object
			, filterBy      = filterBy
			, filterByField = filterByField
			, orderBy       = orderBy
			, dbFilters     = savedFilters
			, maxRows       = maxRows
		);

		if( len( valueField ) ) {
			arrayAppend( selectFields, valueField );
		}

		if ( object.len() && !defaultEmptyList ) {
			args.records = presideObjectService.selectData(
				  objectName   = object
				, selectFields = selectFields
				, orderby      = orderBy
				, savedFilters = ListToArray( savedFilters )
				, maxRows      = maxRows
			);

			if( len( valueField ) ) {
				args.values = ValueArray( args.records[ valueField ] );
			} else {
				args.values = ValueArray( args.records.id );
			}
			args.labels = ValueArray( args.records.label );
		}

		args.multiple = args.multiple ?: true;
		args.sortable = args.sortable ?: false;

		if ( args.multiple && Len( args.sourceObject ?: "" ) && Len( args.relatedTo ?: "" ) ) {
			var sourceObject  = args.sourceObject;
			var sourceIdField = presideObjectService.getIdField( sourceObject );
			var targetIdField = presideObjectService.getIdField( args.relatedTo );

			if (  Len( Trim( args.savedData[ sourceIdField ] ?: "" ) ) ) {
				var useVersioning = Val( rc.version ?: "" ) && presideObjectService.objectIsVersioned( sourceObject );

				args.savedValue = presideObjectService.selectManyToManyData(
					  objectName       = sourceObject
					, propertyName     = args.name
					, id               = args.savedData[ sourceIdField ]
					, selectFields     = [ "#args.name#.#targetIdField# as id" ]
					, useCache         = false
					, fromVersionTable = useVersioning
					, specificVersion  = Val( rc.version ?: "" )
				);

				args.defaultValue = args.savedValue = ValueList( args.savedValue.id );
			}
		}

		event.include( "/js/specific/multiSelect/" );
		if( isTrue( args.sortable ) ) {
			event.include( "ext-jq-chosen-sortable" );
		}

		if ( includeChosenJs ) {
			event.include( "ext-custom-chosen" );
		}

		if ( Len( object ) && !defaultEmptyList && !Len( args.ajax ?: "" ) && ajaxSearch && maxRows ) {
			if ( Len( rc[ fieldName ] ?: "" ) && ( rc[ fieldName ] != args.defaultValue ) ) {
				args.defaultValue = rc[ fieldName ];
			}

			if ( Len( args.defaultValue ) ) {
				var defaultValues = ListToArray( args.defaultValue );

				arrayEach( defaultValues, function( item ) {
					if ( !ArrayFind( args.values, item ) ) {
						arrayAppend( args.values, item );
						ArrayAppend( args.labels, renderLabel( object, item ) );
					}
				});
			}

			event.include( "/js/specific/ajaxTextObjectRecSearch/" )
				.includeData( { searchTermUrl= event.buildLink( linkTo = "formcontrols.multiselect.getObjectRecordsForAjaxSelectControl" ) } );
		}

		return renderView( view="formcontrols/multiSelect/index", args=args );
	}

	public void function refreshChildOptions( event, rc, prc, args={} ) {
		// var targetObject   = rc.targetObject  ?: "";
		// var filterBy       = rc.filterBy      ?: "";
		// var filterByField  = rc.filterByField ?: filterBy;
		// var orderBy        = rc.orderBy       ?: "label";
		// var dbFilters      = rc.dbFilters     ?: "";
		// var requestAllowed = multiSelectAllowListService.isParameterCombinationAllowed(
		// 	  targetObject  = targetObject
		// 	, filterBy      = filterBy
		// 	, filterByField = filterByField
		// 	, orderBy       = orderBy
		// 	, dbFilters     = dbFilters
		// );

		// if ( !requestAllowed || !Len( Trim( targetObject ) ) ) {
		// 	event.renderData( data=[], type="json", statusCode=403 );
		// 	return;
		// }

		var preparedParams = multiSelectFormControlService.processRequestParamsForSelect( reqContext = rc );

		if ( !multiSelectFormControlService.isAjaxRequestAllowed( preparedParams = preparedParams ) ) {
			event.renderData( data=[], type="json", statusCode=403 );
			return;
		}

		var extraFilters = multiSelectFormControlService.getExtraFiltersFromFilterByValues(
			  reqContext    = rc
			, filterBy      = listToArray( preparedParams.filterBy )
			, filterByField = listToArray( preparedParams.filterByField )
			, targetObject  = preparedParams.targetObject
		);

		// filterBy      = listToArray( filterBy );
		// filterByField = listToArray( filterByField );

		// var extraFilters = [];
		// var i            = 0;
		// for( var key in filterBy ) {
		// 	var filter = {};
		// 	i++;
		// 	if ( structKeyExists( rc, key ) ) {
		// 		if ( ListLen( filterByField[ i ], "." ) > 1 ) {
		// 			filter[ filterByField[ i ] ] = ListToArray( rc[ key ] );
		// 		} else {
		// 			filter[ "#targetObject#.#filterByField[ i ]#" ] = ListToArray( rc[ key ] );
		// 		}

		// 		ArrayAppend( extraFilters, { filter = filter } );
		// 	}
		// }

		var records = presideObjectService.selectData(
			  objectName   = preparedParams.targetObject
			, selectFields = [ "id", "${labelfield} as label" ]
			, orderby      = preparedParams.orderBy
			, extraFilters = extraFilters
			, savedFilters = ListToArray( preparedParams.dbFilters )
		);
dumpLog(extraFilters,records,rc);
		event.renderData( data= QueryToArray( qry=records, columns=records.getColumnList( false ) ), type="json" );
	}

	public void function getObjectRecordsForAjaxSelectControl() {
		var preparedParams = multiSelectFormControlService.processRequestParamsForSelect( reqContext = rc );

		if ( !multiSelectFormControlService.isAjaxRequestAllowed( preparedParams = preparedParams, textSearch = true ) ) {
			event.renderData( data=[], type="json", statusCode=403 );
			return;
		}

		var extraFilters = multiSelectFormControlService.getExtraFiltersFromFilterByValues(
			  reqContext    = rc
			, filterBy      = listToArray( preparedParams.filterBy )
			, filterByField = listToArray( preparedParams.filterByField )
			, targetObject  = preparedParams.targetObject
		);

		var records = datamanagerService.getRecordsForAjaxSelect(
			  objectName   = preparedParams.targetObject
			, selectFields = [ "id", "${labelfield} as label" ]
			, savedFilters = ListToArray( preparedParams.dbFilters )
			, searchQuery  = preparedParams.searchTerm
			, extraFilters = extraFilters
			, maxRows      = preparedParams.maxRows
			, orderBy      = preparedParams.orderBy
		);

		event.renderData( type="json", data=records );
	}
}