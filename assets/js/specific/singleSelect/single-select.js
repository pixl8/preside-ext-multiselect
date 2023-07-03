( function( $ ) {

	$( document ).ready( function() {

		$(".chosen-container input").on('keyup',function(){
			var $selectField = $(this).closest( ".chosen-container" ).prev( "select" );
			var $inputField = $(this);

			var params = {};
			params[ 'searchTerm' ] = this.value;
			params[ 'requestUrl' ] = window.location.href;
			params[ 'fieldName' ]  = $selectField.attr( "name" );

			var selectedVal = $selectField.val();

			if ( this.value.length >= 4 ) {
				$.ajax({
					type: 'POST',
					url : cfrequest.searchTermUrl,
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

							var searched = $inputField.val();
							$selectField.trigger("chosen:updated");
							$(this).val( searched );
						}
					}
				});
			}
		});

	} );

} )( jQuery );