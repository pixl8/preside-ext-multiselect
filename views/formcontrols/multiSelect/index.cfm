<cfscript>
	inputName          = args.name             ?: "";
	inputId            = args.id               ?: "";
	defaultValue       = args.defaultValue     ?: "";
	defaultLabel       = args.defaultLabel     ?: "";
	values             = args.values           ?: arrayNew();
	labels             = args.labels           ?: values;
	extraClass         = args.extraClass       ?: "";
	placeholder        = args.placeholder      ?: "";
	disabled           = args.disabled         ?: false;
	// ajax filter options
	filterChildId          = args.filterChildId          ?: "";
	ajax                   = args.ajax                   ?: "";
	filterBy               = args.filterBy               ?: "";
	filterByField          = args.filterByField          ?: filterBy;
	object                 = args.object                 ?: "";
	objectFilters          = args.objectFilters          ?: "";
	multiple               = args.multiple               ?: true;
	maxSelected            = args.maxSelected            ?: "";
	orderBy                = args.orderBy                ?: "label";
	allowDeselect          = args.allowDeselect          ?: false;
	sortable               = args.sortable               ?: false;
	ajaxTextSearch         = args.ajaxTextSearch         ?: false;
	ajaxMaxRows            = args.ajaxMaxRows            ?: 0;
	ajaxSearchUrl          = args.ajaxSearchUrl          ?: "";
	ajaxSearchCustomFilter = args.ajaxSearchCustomFilter ?: "";

	if ( IsSimpleValue( values ) ) { values = ListToArray( values ); }
	if ( IsSimpleValue( labels ) ) { labels = ListToArray( labels ); }

	value = Trim( event.getValue( name=inputName, defaultValue=defaultValue ) );
	if ( not IsSimpleValue( value ) ) {
		value = "";
	}

	indexOrder = "";
	if( isTrue( sortable ) ) {
		extraClass &= " chosen-sortable "
		if( !isEmptyString( value ) ) {
			for( var selected in listToArray( value ) ) {
				indexOrder = listAppend( indexOrder, arrayFind( values, selected ) );
			}
		}
	}
</cfscript>

<cfoutput>
	<select id="#inputId#" name="#inputName#" class="#Trim( ListAppend( 'form-control custom-select',extraClass, ' ' ) )#" tabindex="#getNextTabIndex()#" data-placeholder="#placeholder#" <cfif Len( filterChildId )>
		data-filter-child-id="#filterChildId#"
	</cfif> <cfif Len( ajax )>
		data-ajax-url="#ajax#"
	</cfif> <cfif Len( filterBy )>
		data-filter-by="#filterBy#"
	</cfif> <cfif Len( filterByField )>
		data-filter-by-field="#filterByField#"
	</cfif> <cfif Len( object )>
		data-object="#object#"
	</cfif> <cfif Len( objectFilters )>
		data-object-filters="#objectFilters#"
	</cfif><cfif multiple>
		 multiple
		<cfif isNumeric( maxSelected ) AND maxSelected GT 0> data-max-selected="#maxSelected#"</cfif>
	</cfif> <cfif Len( orderBy )>
		data-order-by="#orderBy#"
	</cfif> <cfif isTrue( allowDeselect )>
		data-deselect="true"
	</cfif> <cfif isTrue( sortable )>
		data-index-order="#indexOrder#"
	</cfif> <cfif isTrue( ajaxTextSearch )>
		data-ajax-txt-search="1"
	</cfif> <cfif ajaxMaxRows gt 0>
		data-ajax-maxrows="#ajaxMaxRows#"
	</cfif><cfif Len( ajaxSearchUrl )>
		data-ajax-search-url="#ajaxSearchUrl#"
	</cfif><cfif Len( ajaxSearchCustomFilter )>
		data-ajax-custom-filter="#ajaxSearchCustomFilter#"
	</cfif><cfif disabled>
		disabled="disabled"
	</cfif>>
		<cfloop array="#values#" index="i" item="selectValue">
			<cfset isSelectedValue = ListFindNoCase( value, selectValue ) />
			<cfif isTrue( allowDeselect )><option value=""></option></cfif>
			<option value="#HtmlEditFormat( selectValue )#"
				<cfif isSelectedValue || (!len(value) && labels[i]==defaultLabel ) > selected="selected"</cfif>
			>#HtmlEditFormat( translateResource( labels[i] ?: "", labels[i] ?: "" ) )#</option>
		</cfloop>
	</select>
</cfoutput>