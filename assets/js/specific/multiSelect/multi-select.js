( function( $ ){
	var showHideOption = function( selectedParent, filterChild, ajaxUrl ){
		
		if ( selectedParent && $.isArray( selectedParent ) ) {
			selectedParent = selectedParent.join( "," );
		}
		
		$.each( filterChild, function( index, value ) {
			var $selectChild       = $( "#"+value );
			var selectedChildValue = $selectChild.val();

			if ( selectedChildValue && !$.isArray( selectedChildValue ) ) {
				selectedChildValue.split( "," );
			}

			var filterByField = $selectChild.data( 'filter-by' );

			var data = {};
			data[ filterByField  ] = selectedParent;
			data[ 'filterBy'     ] = $selectChild.data( 'filter-by' );
			data[ 'targetObject' ] = $selectChild.data( 'object' );
			data[ 'dbFilters'    ] = $selectChild.data( 'object-filters' );

			$.ajax({
				type: 'POST',
				url : ajaxUrl,
				data: data,
				dataType: 'json',
				success: function (data) {
					
					$selectChild.empty();
					for (var i = 0; i < data.length; i++) {
						if ( selectedChildValue && $.inArray( String(data[i].id), selectedChildValue ) > -1 ) {
							$selectChild.append('<option value=' + data[i].id + ' selected>' + data[i].label + '</option>');
						} else {
							$selectChild.append('<option value=' + data[i].id + '>' + data[i].label + '</option>');
						}
						
					}
					$selectChild.trigger("chosen:updated");
				}
			});
			
		} );
	}

	var processFilterByFields = function( $filterParent ) {
		var selectedParent = $filterParent.val();
		var filterChild    = $filterParent.data( "filter-child-id" ).split( "," );
		var ajaxUrl        = $filterParent.data( "ajax-url" );

		showHideOption( selectedParent, filterChild, ajaxUrl );
	}

	$( "body" ).on( "change", ".select-filter-by", function() {
		processFilterByFields( $( this ) );
	});

	$( document ).ready( function() {
		var $filterBy = $( ".select-filter-by" );

		$filterBy.each( function() {
			processFilterByFields( $( this ) );
		} );
		
	});
} )( jQuery );