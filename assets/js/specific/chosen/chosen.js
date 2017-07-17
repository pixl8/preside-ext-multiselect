( function( $ ){
    var customChosen = function( $container ) {

        $('.custom-select', $container ).chosen();

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