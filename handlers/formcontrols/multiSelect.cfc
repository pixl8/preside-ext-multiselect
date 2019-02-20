component {
	property name="presideObjectService" inject="PresideObjectService";
	property name="includeChosenJs"      inject="coldbox:setting:multiSelect.includeChosenJs";

	public string function index( event, rc, prc, args={} ) {
		var object       = args.object        ?: "";
		var labelField   = args.labelField    ?: "label";
		var savedFilters = args.objectFilters ?: "";
		var orderBy      = args.orderBy       ?: 'label';
		var valueField   = args.valueField    ?: '';
		var selectFields = [ "id",labelField & " as label" ];

		if( len( valueField ) ) {
			arrayAppend( selectFields, valueField );
		}

		if ( object.len() ) {
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

		event.include( "ext-multi-select" );

		if ( includeChosenJs ) {
			event.include( "ext-custom-chosen" );
		}
		
		return renderView( view="formcontrols/multiSelect/index", args=args );
	}

	public void function refreshChildOptions( event, rc, prc, args={} ) {
		var filterBy      = rc.filterBy      ?: "";
        var filterByField = rc.filterByField ?: filterBy;
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
				, orderby      = "label"
				, filter       = filter
				, savedFilters = ListToArray( rc.dbFilters ?: "" )
			);
			
		}
		event.renderData( data= QueryToArray( qry=records, columns=records.getColumnList( false ) ), type="JSON" );
	}
}
