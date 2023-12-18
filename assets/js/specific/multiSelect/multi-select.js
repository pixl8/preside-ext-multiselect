var pixl8presideExtMultiselect = function() {

	var processFilterByFields = function( $filterParent ) {
		var selectedParent = $filterParent.val();
		var filterChild    = $filterParent.data( "filter-child-id" ).split( "," );
		var ajaxUrl        = $filterParent.data( "ajax-url" );

		showHideOption( selectedParent, filterChild, ajaxUrl );
	};

	var showHideOption = function( selectedParent, filterChild, ajaxUrl ){

		if ( selectedParent && $.isArray( selectedParent ) ) {
			selectedParent = selectedParent.join( "," );
		}

		$.each( filterChild, function( index, value ) {
			var $selectChild       = $( "#"+value );
			var selectedChildValue = $selectChild.val();

			if ( selectedChildValue && !$.isArray( selectedChildValue ) ) {
				selectedChildValue = selectedChildValue.split( "," );
			}

			var filterByField = $selectChild.data( 'filter-by' );

			var data = {};
			data[ filterByField   ]          = selectedParent;
			data[ 'filterBy'      ]          = $selectChild.data( 'filter-by' );
			data[ 'filterByField' ]          = $selectChild.data( 'filter-by-field' );
			data[ 'targetObject'  ]          = $selectChild.data( 'object' );
			data[ 'dbFilters'     ]          = $selectChild.data( 'object-filters' );
			data[ 'orderBy'       ]          = $selectChild.data( 'order-by' );
			data[ 'maxRows'       ]          = $selectChild.data( 'ajax-maxrows' );
			data[ 'ajaxTxtSearch' ]          = $selectChild.data( 'ajax-txt-search' );
			data[ 'ajaxSearchCustomFilter' ] = $selectChild.data( "ajax-custom-filter" );
			var allowDeselect                = $selectChild.data( "deselect" );

			// if ajax txt search enabled, check pre-selected value (might not be in the option list on first page)
			if ( typeof data[ 'ajaxTxtSearch' ] != 'undefined' && typeof data[ 'maxRows' ] != 'undefined' ) {
				data[ 'defaultValues' ] = $selectChild.val();
			}

			$.ajax({
				type: 'POST',
				url : ajaxUrl,
				data: data,
				dataType: 'json',
				success: function (data) {

					$selectChild.empty();

					if( allowDeselect == 1 ){
						$selectChild.append('<option value=""></option>');
					}

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

	return {

		/*
			Public function, can be accessed from js/specific/ scripts
			pixl8presideExtMultiselect.fn.updateChildSelect = function() {};
		*/
		fn: {
			updateChildSelect: function( selectedParent, filterChild, ajaxUrl ) {
				showHideOption( selectedParent, filterChild, ajaxUrl );
			}
		} /* End general public function */

		, init: function() {

			$( "body" ).on( "change", ".select-filter-by", function() {
				processFilterByFields( $( this ) );
			});

			$( ".select-filter-by" ).each( function() {
				processFilterByFields( $( this ) );
			} );

			return this;

		}

	};
}();

( function( $ ) {

	$( document ).ready( function() {

		pixl8presideExtMultiselect.init();

	} );

} )( jQuery );