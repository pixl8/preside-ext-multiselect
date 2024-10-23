component {
	property name="presideObjectService"               inject="PresideObjectService";
	property name="multiSelectAllowListService"        inject="multiSelectAllowListService";
	property name="multiSelectFormControlService"      inject="multiSelectFormControlService";
	property name="includeChosenJs"                    inject="coldbox:setting:multiSelect.includeChosenJs";
	property name="dataManagerService"                 inject="DataManagerService";
	property name="labelRendererService"               inject="LabelRendererService";

	public string function index( event, rc, prc, args={} ) {
		var object           = args.object        ?: "";
		var labelField       = args.labelField    ?: "label";
		var savedFilters     = args.objectFilters ?: "";
		var defaultEmptyList = args.defaultEmptyList ?: false;
		var orderBy          = args.orderBy       ?: 'label';
		var valueField       = args.valueField    ?: '';
		var filterBy         = args.filterBy      ?: "";
		var filterByField    = args.filterByField ?: filterBy;

		var selectFields = _prepareSelectFields( args );

		var ajaxTxtSearch          = IsTrue( args.ajaxTextSearch ?: "" );
		var fieldName              = args.name ?: "";
		var maxRows                = ajaxTxtSearch ? ( args.ajaxMaxRows ?: 0 ) : 0;
		var selectUnion            = false;
		var ajaxSearchCustomFilter = args.ajaxSearchCustomFilter ?: "";

		multiSelectAllowListService.addToAllowList(
			  targetObject           = object
			, filterBy               = filterBy
			, filterByField          = filterByField
			, orderBy                = orderBy
			, dbFilters              = savedFilters
			, maxRows                = maxRows
			, ajaxTxtSearch          = ajaxTxtSearch
			, ajaxSearchCustomFilter = ajaxSearchCustomFilter
		);

		if( len( valueField ) ) {
			arrayAppend( selectFields, valueField );
		}

		if ( object.len() && !defaultEmptyList ) {
			if ( ajaxTxtSearch && maxRows  ) {
				if ( Len( rc[ fieldName ] ?: "" ) && ( rc[ fieldName ] != args.defaultValue ) ) {
					args.defaultValue = rc[ fieldName ];
				}

				if ( Len( args.defaultValue ?: "" ) ) {
					selectUnion = true;
				}
			}

			if ( selectUnion ) {
				args.records = presideObjectService.selectUnion(
					selectDataArgs = [
						{
							  objectName   = object
							, selectFields = selectFields
							, savedFilters = ListToArray( savedFilters )
							, orderby      = orderBy
							, maxRows      = maxRows
						}, {
							  objectName   = object
							, selectFields = selectFields
							, savedFilters = ListToArray( savedFilters )
							, filter       = { id = ListToArray( args.defaultValue ) }
						}
					]
				);
			} else {
				args.records = presideObjectService.selectData(
					  objectName   = object
					, selectFields = selectFields
					, orderby      = orderBy
					, savedFilters = ListToArray( savedFilters )
					, maxRows      = maxRows
				);
			}

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
		} else if ( Len( object ) && !defaultEmptyList && ajaxTxtSearch && maxRows ) {
			event.include( "/js/specific/ajaxTextObjectRecSearch/" );

			if ( !Len( args.ajaxSearchUrl ?: "" ) ) {
				args.ajaxSearchUrl = event.buildLink( linkTo = "formcontrols.multiselect.getObjectRecordsForAjaxSelectControl" );
			}
		}

		event.include( "/js/specific/multiSelect/" );
		if( isTrue( args.sortable ) ) {
			event.include( "ext-jq-chosen-sortable" );
		}

		if ( includeChosenJs ) {
			event.include( "ext-custom-chosen" );
		}

		return renderView( view="formcontrols/multiSelect/index", args=args );
	}

	public void function refreshChildOptions( event, rc, prc, args={} ) {
		var preparedParams = multiSelectFormControlService.processRequestParamsForSelect( reqContext = rc );

		if ( !multiSelectFormControlService.isAjaxRequestAllowed( preparedParams = preparedParams ) ) {
			event.renderData( data=[], type="json", statusCode=403 );
			return;
		}

		var selectFields = _prepareSelectFields( rc );

		var extraFilters = multiSelectFormControlService.getExtraFiltersFromFilterByValues(
			  reqContext    = rc
			, filterBy      = listToArray( preparedParams.filterBy )
			, filterByField = listToArray( preparedParams.filterByField )
			, targetObject  = preparedParams.targetObject
		);

		var records = "";

		if ( isArray( rc.defaultValues ?: "" ) ) {
			rc.defaultValues = arrayToList( rc.defaultValues );
		}

		if ( Len( rc.defaultValues ?: "" ) ) {
			records = presideObjectService.selectUnion(
				selectDataArgs = [
					{
						  objectName   = preparedParams.targetObject
						, selectFields = selectFields
						, extraFilters = extraFilters
						, savedFilters = ListToArray( preparedParams.dbFilters )
						, orderby      = orderBy
						, maxRows      = preparedParams.maxRows
					}, {
						  objectName   = preparedParams.targetObject
						, selectFields = selectFields
						, extraFilters = extraFilters
						, savedFilters = ListToArray( preparedParams.dbFilters )
						, filter       = { id = ListToArray( rc.defaultValues ) }
					}
				]
				, orderby      = preparedParams.orderBy
			);
		} else {
			records = presideObjectService.selectData(
				  objectName   = preparedParams.targetObject
				, selectFields = selectFields
				, extraFilters = extraFilters
				, savedFilters = ListToArray( preparedParams.dbFilters )
				, maxRows      = preparedParams.maxRows
				, orderby      = preparedParams.orderBy
			);
		}

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

		var selectFields = _prepareSelectFields( rc );

		var records = datamanagerService.getRecordsForAjaxSelect(
			  objectName   = preparedParams.targetObject
			, selectFields = selectFields
			, savedFilters = ListToArray( preparedParams.dbFilters )
			, searchQuery  = preparedParams.searchTerm
			, extraFilters = extraFilters
			, maxRows      = preparedParams.maxRows
			, orderBy      = preparedParams.orderBy
		);

		event.renderData( type="json", data=records );
	}

	private array function _prepareSelectFields( required struct formParams ) {
		var object = "";

		if ( StructKeyExists( formParams, "targetObject" ) ) {
			object = formParams.targetObject ?: "";
		} else {
			object = formParams.object ?: "";
		}

		if( len( formParams.labelField ?: "" ) ){
			return [ "id", formParams.labelField & " as label" ];
		}

		if ( !Len( object ) ) {
			return [ "id", "${labelfield} as label" ];
		}

		var labelRenderer = formParams.labelRenderer = formParams.labelRenderer ?: presideObjectService.getObjectAttribute( object, "labelRenderer" );
		var selectFields  = labelRendererService.getSelectFieldsForLabel( labelRenderer );

		var hasLabelOnSelectField = false;
		for ( var field in selectFields ) {
			if ( arrayLen( reMatchNoCase( "^(.*\s+as\s+)?label$", field ) ) ) {
				hasLabelOnSelectField = true;
				break;
			}
		}

		if ( !hasLabelOnSelectField ) {
			ArrayAppend( selectFields, "label" );
		}

		ArrayAppend( selectFields, "id" );

		return selectFields;
	}
}