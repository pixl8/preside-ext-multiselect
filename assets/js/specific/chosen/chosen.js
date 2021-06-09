( function( $ ){
    var customChosen = function( $container ) {
        $('.custom-select', $container ).each(function() {
            var deselect     = ( typeof $(this).data('deselect') !== 'undefined' );
            var chosenConfig = { allow_single_deselect: deselect };
            var maxSelected  = $( this ).data( "max-selected" );
            if ( $.isNumeric( maxSelected ) ) {
                chosenConfig[ "max_selected_options" ] = maxSelected;
            }
            $(this).chosen( chosenConfig );

            if( $(this).hasClass( "chosen-sortable" ) ) {
                $(this).chosenSortable();
            }
        });

        if ($('.chosen-container').length > 0) {
            $('.chosen-container').on('touchstart tap', function(e){
                e.stopPropagation(); e.preventDefault();
                // Trigger the mousedown event.
                $(this).trigger('mousedown');
            });
        }
    };

	$( document ).ready( function() {
		customChosen( $("body") );
	} );

} )( jQuery );