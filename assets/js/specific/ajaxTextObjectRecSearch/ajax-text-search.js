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

				var params = {};
				params[ 'searchTerm'   ] = this.value;
				params[ 'filterBy'     ] = $selectField.data( 'filter-by' );
				params[ 'targetObject' ] = $selectField.data( 'object' );
				params[ 'dbFilters'    ] = $selectField.data( 'object-filters' );
				params[ 'orderBy'      ] = $selectField.data( 'order-by' );
				params[ 'maxRows'      ] = $selectField.data( 'ajax-maxrows' );

				if ( typeof params[ 'filterBy' ] != 'undefined' ) {
					var filterByField = params[ 'filterBy' ];

					var selectedParentVal = $('select[data-filter-child-id*="'+ this.id +'"]').val();

					params[ filterByField  ] = selectedParentVal;
				}

				$.ajax({
					type: 'POST',
					url : cfrequest.searchTermUrl,
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