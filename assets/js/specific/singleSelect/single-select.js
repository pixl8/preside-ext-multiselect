( function( $ ) {

	$( document ).ready( function() {

		$(".chosen-container input").on('keyup',function(){
			if ( this.value.length < 4 ) return;
			var $selectField = $(this).closest( ".chosen-container" ).prev( "select" );
			var params = {};
			params[ 'searchTerm' ] = this.value;
			params[ 'requestUrl' ] = window.location.href;
			params[ 'fieldName' ]  = $selectField.attr( "name" );

			var selectedVal = $selectField.val();

			$.ajax({
				type: 'POST',
				url : cfrequest.searchTermurl,
				data: params,
				dataType: 'json',
				success: function (data) {
					if ( data.length ) {
						$selectField.empty();
						for (var i = 0; i < data.length; i++) {
								if ( selectedVal && $.inArray( String(data[i].value), selectedVal ) > -1 ) {
										$selectField.append('<option value=' + data[i].value + ' selected>' + data[i].text + '</option>');
								} else {
										$selectField.append('<option value=' + data[i].value + '>' + data[i].text + '</option>');
								}
						}
						var keyedValue = params[ 'searchTerm' ];
						$selectField.trigger("chosen:updated");
						$(this).val( keyedValue );
					}
				}
			});
		});

	} );

} )( jQuery );