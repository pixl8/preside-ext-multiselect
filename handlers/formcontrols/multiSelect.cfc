component {
	property name="presideObjectService"               inject="PresideObjectService";
	property name="multiSelectAllowListService"        inject="multiSelectAllowListService";
	property name="includeChosenJs"                    inject="coldbox:setting:multiSelect.includeChosenJs";
	property name="multiSelectFieldAttributeService"   inject="MultiSelectFieldAttributeService";
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

		var ajaxSearch       = IsTrue( args.ajaxSearch ?: "" );
		var fieldName        = args.name ?: "";
		var maxRows          = args.maxRows ?: 0;

		multiSelectAllowListService.addToAllowList(
			  targetObject  = object
			, filterBy      = filterBy
			, filterByField = filterByField
			, orderBy       = orderBy
			, dbFilters     = savedFilters
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

		if ( !args.multiple && Len( object ) && !defaultEmptyList && IsTrue( ajaxSearch ) && maxRows ) {
			multiSelectFieldAttributeService.addToSelectFieldAttritbutesCache(
				  partialUrl    = prc._presideUrlPath ?: ""
				, fieldName     = fieldName
				, object        = object
				, selectFields  = ArrayToList( selectFields )
				, filterBy      = filterBy
				, filterByField = filterByField
				, orderBy       = orderBy
				, savedFilters  = savedFilters
				, maxRows       = maxRows
			);

			if ( Len( args.defaultValue ) ) {
				if ( !ArrayFind( args.values, args.defaultValue ) ) {
					arrayAppend( args.values, args.defaultValue );
					ArrayAppend( args.labels, renderLabel( object, args.defaultValue ) );
				}
			}

			event.include( "/js/specific/singleSelectAjax/" )
				.includeData( { searchTermUrl= event.buildLink( linkTo = "formcontrols.multiselect.getObjectRecordsForAjaxSelectControl" ) } );
		}

		return renderView( view="formcontrols/multiSelect/index", args=args );
	}

	public void function refreshChildOptions( event, rc, prc, args={} ) {
		var targetObject   = rc.targetObject  ?: "";
		var filterBy       = rc.filterBy      ?: "";
		var filterByField  = rc.filterByField ?: filterBy;
		var orderBy        = rc.orderBy       ?: "label";
		var dbFilters      = rc.dbFilters     ?: "";
		var requestAllowed = multiSelectAllowListService.isParameterCombinationAllowed(
			  targetObject  = targetObject
			, filterBy      = filterBy
			, filterByField = filterByField
			, orderBy       = orderBy
			, dbFilters     = dbFilters
		);

		if ( !requestAllowed || !Len( Trim( targetObject ) ) ) {
			event.renderData( data=[], type="json", statusCode=403 );
			return;
		}

		filterBy      = listToArray( filterBy );
		filterByField = listToArray( filterByField );

		var filter = {};
		var i      = 0;
		for( var key in filterBy ) {
			i++;
			if ( structKeyExists( rc, key ) ) {
				if ( ListLen( filterByField[ i ], "." ) > 1 ) {
					filter[ filterByField[ i ] ] = ListToArray( rc[ key ] );
				} else {
					filter[ "#targetObject#.#filterByField[ i ]#" ] = ListToArray( rc[ key ] );
				}
			}
		}

		var records = presideObjectService.selectData(
			  objectName   = targetObject
			, selectFields = [ "id", "${labelfield} as label" ]
			, orderby      = orderBy
			, filter       = filter
			, savedFilters = ListToArray( dbFilters )
		);

		event.renderData( data= QueryToArray( qry=records, columns=records.getColumnList( false ) ), type="json" );
	}

	public string function getObjectRecordsForAjaxSelectControl() {
		if ( !Len( rc.requestUrl ?: "" ) || !Len( rc.fieldName ?: "" ) ) {
			return "";
		}
		var formControlAttributes = multiSelectFieldAttributeService.getFieldAttributes( requestUrl = rc.requestUrl, fieldName = rc.fieldName );
		if ( !StructCount( formControlAttributes ) ) {
			return "";
		}
		var records = datamanagerService.getRecordsForAjaxSelect(
			  objectName   = formControlAttributes.object
			, selectFields = ListToArray( formControlAttributes.selectFields )
			, savedFilters = ListToArray( formControlAttributes.savedFilters )
			, searchQuery  = rc.searchTerm
			, maxRows      = formControlAttributes.maxRows
			, orderBy      = formControlAttributes.orderBy
		);
		event.renderData( type="json", data=records );
	}
}