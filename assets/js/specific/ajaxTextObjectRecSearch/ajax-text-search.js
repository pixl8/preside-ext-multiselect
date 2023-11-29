( function( $ ) {

	$( document ).ready( function() {

		$(".chosen-container input").on('keyup',function( e ){

			if ( !$(this).closest( ".chosen-container" ).prev( "select[data-ajax-txt-search='1']" ).length ) {
				return;
			}

			var $selectField = $(this).closest( ".chosen-container" ).prev( "select" );
			var $inputField = $(this);

			var selectedVal = $selectField.val();

			if ( this.value.length >= 2 && ( ( e.keyCode >= 48 && e.keyCode <= 90 ) || e.keyCode == 8 ) ) {

				var searchUrl = $selectField.data( 'ajax-search-url' );

				var params = {};
				params[ 'searchTerm'    ]          = this.value;
				params[ 'filterBy'      ]          = $selectField.data( 'filter-by' );
				params[ 'filterByField' ]          = $selectField.data( 'filter-by-field' );
				params[ 'targetObject'  ]          = $selectField.data( 'object' );
				params[ 'dbFilters'     ]          = $selectField.data( 'object-filters' );
				params[ 'orderBy'       ]          = $selectField.data( 'order-by' );
				params[ 'maxRows'       ]          = $selectField.data( 'ajax-maxrows' );
				params[ 'ajaxTxtSearch' ]          = $selectField.data( 'ajax-txt-search' );
				params[ 'ajaxSearchCustomFilter' ] = $selectField.data( "ajax-custom-filter" );

				// for child select, get parent selected value for filtering
				if ( typeof params[ 'filterBy' ] != 'undefined' ) {
					var filterByField = params[ 'filterBy' ];

					var selectedParentVal = $('select[data-filter-child-id*="'+ $selectField.attr( "id" ) +'"]').val();

					if ( selectedParentVal && $.isArray( selectedParentVal ) ) {
						selectedParentVal = selectedParentVal.join( "," );
					}

					params[ filterByField  ] = selectedParentVal;
				}

				// get custom id values for params
				if ( typeof params[ 'ajaxSearchCustomFilter' ] != 'undefined' ) {
					var customSearchFilter = params[ 'ajaxSearchCustomFilter' ].split( "," );

					$.each( customSearchFilter, function( index, value ) {
						params[ value ] = $( '#' + value ).val();
					} );
				}

				$.ajax({
					type: 'POST',
					url : searchUrl,
					data: params,
					dataType: 'json',
					success: function (data) {
						if ( data.length ) {
							$( 'option', $selectField ).not(':selected').remove();

							if ( selectedVal && !$.isArray( selectedVal ) ) {
								selectedVal = selectedVal.split( "," );
							}

							for (var i = ( data.length - 1 ); i >= 0; i--) {
								if ( $.inArray( String(data[i].value), selectedVal ) == -1 ) {
									$selectField.prepend('<option value=' + data[i].value + '>' + data[i].text + '</option>');
								}
							}

							var searched = $inputField.val();
							$selectField.trigger("chosen:updated");
							$inputField.val( searched );
						}
					}
				});
			}
		});
	} );

} )( jQuery );