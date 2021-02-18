<cfscript>
	inputName          = args.name             ?: "";
	inputId            = args.id               ?: "";
	defaultValue       = args.defaultValue     ?: "";
	defaultLabel       = args.defaultLabel     ?: "";
	values             = args.values           ?: arrayNew();
	labels             = args.labels           ?: values;
	extraClass         = args.extraClass       ?: "";
	placeholder        = args.placeholder      ?: "";
	// ajax filter options
	filterChildId      = args.filterChildId    ?: "";
	ajax               = args.ajax             ?: "";
	filterBy           = args.filterBy         ?: "";
	object             = args.object           ?: "";
	objectFilters      = args.objectFilters    ?: "";
	multiple           = args.multiple         ?: true;
	orderBy            = args.orderBy          ?: "label";
	allowDeselect      = args.allowDeselect    ?: false;
	sortable           = args.sortable         ?: false;

	if ( IsSimpleValue( values ) ) { values = ListToArray( values ); }
	if ( IsSimpleValue( labels ) ) { labels = ListToArray( labels ); }

	value = Trim( event.getValue( name=inputName, defaultValue=defaultValue ) );
	if ( not IsSimpleValue( value ) ) {
		value = "";
	}
	if( isTrue( sortable ) ) {
		extraClass &= " chosen-sortable "
	}
</cfscript>

<cfoutput>
	<select id="#inputId#" name="#inputName#" class="#Trim( ListAppend( 'form-control custom-select',extraClass, ' ' ) )#" tabindex="#getNextTabIndex()#" data-placeholder="#placeholder#" <cfif Len( filterChildId )>
		data-filter-child-id="#filterChildId#"
	</cfif> <cfif Len( ajax )>
		data-ajax-url="#ajax#"
	</cfif> <cfif Len( filterBy )>
		data-filter-by="#filterBy#"
	</cfif> <cfif Len( object )>
		data-object="#object#"
	</cfif> <cfif Len( objectFilters )>
		data-object-filters="#objectFilters#"
	</cfif><cfif multiple>
		 multiple
	</cfif> <cfif Len( orderBy )>
		data-order-by="#orderBy#"
	</cfif> <cfif isTrue( allowDeselect )>
		data-deselect="true"
	</cfif> >
		<cfloop array="#values#" index="i" item="selectValue">
			<cfset isSelectedValue = ListFindNoCase( value, selectValue ) />
			<cfif isTrue( allowDeselect )><option value=""></option></cfif>
			<option value="#HtmlEditFormat( selectValue )#"
				<cfif isSelectedValue || (!len(value) && labels[i]==defaultLabel ) > selected="selected"</cfif>
			>#HtmlEditFormat( translateResource( labels[i] ?: "", labels[i] ?: "" ) )#</option>
		</cfloop>
	</select>
</cfoutput>