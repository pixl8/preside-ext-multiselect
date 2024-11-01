pixl8presideExtMultiselect.fn.ajaxSearch = function( $container ) {
	$( "select.custom-select[data-ajax-txt-search=1]", $container ).each( function() {
		let   $selectField     = $( this )
			, $chosenContainer = $selectField.next( ".chosen-container" )
			, $inputField      = $chosenContainer.find( "input" )
			, searchUrl        = $selectField.data( 'ajax-search-url' )
			, getSearchTerm    = function() { return $inputField.val() };

			$chosenContainer.attr( "data-result-is-from-searchterm", false );

			$chosenContainer.on( "click", function(){
				let resultIsFromSearchterm = $chosenContainer.data( "result-is-from-searchterm" );

				if ( resultIsFromSearchterm ) {
					_ajaxSearch();
				}
			});

			$inputField.on('keyup',function( e ){
				let searchTerm = getSearchTerm();

				if ( ( searchTerm.length >= 2 || e.keyCode == 8 ) && ( ( e.keyCode >= 48 && e.keyCode <= 90 ) || e.keyCode == 8 ) ) {
					_ajaxSearch();
				}
			});

			function _ajaxSearch() {
				let searchTerm   = getSearchTerm();
				let selectedVal  = $selectField.val();

				var params = {};
				params[ 'searchTerm'    ]          = searchTerm;
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
							console.log( searchTerm );
							$chosenContainer.data( "result-is-from-searchterm", searchTerm.length >0 );

							$( 'option', $selectField ).not(':selected').remove();

							if ( selectedVal && !$.isArray( selectedVal ) ) {
								selectedVal = selectedVal.split( "," );
							}

							for (var i = ( data.length - 1 ); i >= 0; i--) {
								if ( $.inArray( String(data[i].value), selectedVal ) == -1 ) {
									$selectField.prepend('<option value=' + data[i].value + '>' + data[i].text + '</option>');
								}
							}

							var searched = getSearchTerm();
							$selectField.trigger("chosen:updated");
							$inputField.val( searched );
						}
					}
				});
			}
	} );
};
( function( $ ) {

	$( document ).ready( function() {
		pixl8presideExtMultiselect.fn.ajaxSearch( $( "body" ) );
	} );

} )( jQuery );