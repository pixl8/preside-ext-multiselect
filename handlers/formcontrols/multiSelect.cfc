component {
	property name="presideObjectService" inject="PresideObjectService";
	property name="includeChosenJs"      inject="coldbox:setting:multiSelect.includeChosenJs";

	public string function index( event, rc, prc, args={} ) {
		var object       = args.object        ?: "";
		var labelField   = args.labelField    ?: "label";
		var savedFilters = args.objectFilters ?: "";
		var defaultEmptyList = args.defaultEmptyList ?: false;
		var orderBy      = args.orderBy       ?: 'label';
		var valueField   = args.valueField    ?: '';
		var selectFields = [ "id",labelField & " as label" ];

		if( len( valueField ) ) {
			arrayAppend( selectFields, valueField );
		}

		if ( object.len() && !defaultEmptyList ) {
			args.records = presideObjectService.selectData(
				  objectName   = object
				, selectFields = selectFields
				, orderby      = orderBy
				, savedFilters = ListToArray( savedFilters )
			);

			if( len( valueField ) ) {
				args.values = ValueArray( args.records[ valueField ] );
			} else {
				args.values = ValueArray( args.records.id );
			}
			args.labels = ValueArray( args.records.label );
		}

		args.multiple = args.multiple ?: true;

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

		event.include( "ext-multi-select" );

		if ( includeChosenJs ) {
			event.include( "ext-custom-chosen" );
		}

		return renderView( view="formcontrols/multiSelect/index", args=args );
	}

	public void function refreshChildOptions( event, rc, prc, args={} ) {
		var filterBy      = rc.filterBy      ?: "";
		var filterByField = rc.filterByField ?: filterBy;
		var orderBy       = rc.orderBy       ?: "label";
		filterBy          = listToArray( filterBy );
		filterByField     = listToArray( filterByField );

		var filter = {};
		var i      = 0;

		if ( Len( rc.targetObject ?: "" ) ) {
			for( var key in filterBy ) {
				i++;
				if ( structKeyExists( rc, key ) ) {
					if ( ListLen( filterByField[ i ], "." ) > 1 ) {
					    filter[ filterByField[ i ] ] = ListToArray( rc[ key ] );
					} else {
						filter[ "#rc.targetObject#.#filterByField[ i ]#" ] = ListToArray( rc[ key ] );
					}
				}
			}

		 	var records = presideObjectService.selectData(
				  objectName   = rc.targetObject
				, selectFields = [ "id", "${labelfield} as label" ]
				, orderby      = orderBy
				, filter       = filter
				, savedFilters = ListToArray( rc.dbFilters ?: "" )
			);

		}
		event.renderData( data= QueryToArray( qry=records, columns=records.getColumnList( false ) ), type="JSON" );
	}
}
