component extends="testbox.system.BaseSpec" {

	function run() {
		describe( "addToAllowList()", function() {
			it( "returns the select fields registered from code", function() {
				var service      = _newService();
				var selectFields = [ "id", "email_address as label" ];
				var registered   = _register( service, selectFields );
				var allowed      = service.getAllowedSelectFields( argumentCollection=registered );

				expect( service.isParameterCombinationAllowed( argumentCollection=registered ) ).toBeTrue();
				expect( SerializeJson( allowed ) ).toBe( SerializeJson( selectFields ) );
			} );

			it( "keeps distinct select field lists for the same object and filters", function() {
				var service    = _newService();
				var byEmail    = _register( service, [ "id", "email_address as label" ] );
				var byName     = _register( service, [ "id", "name as label" ] );
				var emailFields = service.getAllowedSelectFields( argumentCollection=byEmail );
				var nameFields  = service.getAllowedSelectFields( argumentCollection=byName );

				expect( SerializeJson( emailFields ) ).toBe( SerializeJson( [ "id", "email_address as label" ] ) );
				expect( SerializeJson( nameFields ) ).toBe( SerializeJson( [ "id", "name as label" ] ) );
			} );

			it( "rejects a select field list that was not registered", function() {
				var service = _newService();

				_register( service, [ "id", "label" ] );

				expect( service.isParameterCombinationAllowed(
					  targetObject    = "crm_contact"
					, selectFieldsKey = "id,(select sleep(5)) as label"
				) ).toBeFalse();
				expect( service.getAllowedSelectFields(
					  targetObject    = "crm_contact"
					, selectFieldsKey = "id,(select sleep(5)) as label"
				) ).toBe( [] );
			} );

			it( "keeps the registered fields when the original array later changes", function() {
				var service      = _newService();
				var selectFields = [ "id", "label" ];
				var registered   = _register( service, selectFields );
				var allowed      = "";

				ArrayAppend( selectFields, "(select sleep(5)) as label" );
				allowed = service.getAllowedSelectFields( argumentCollection=registered );

				expect( SerializeJson( allowed ) ).toBe( SerializeJson( [ "id", "label" ] ) );
			} );

			it( "rejects the same select fields when another parameter differs", function() {
				var service     = _newService();
				var registered  = _register( service, [ "id", "label" ], "label" );

				registered.orderBy = "datecreated desc";

				expect( service.isParameterCombinationAllowed( argumentCollection=registered ) ).toBeFalse();
			} );
		} );
	}

	private any function _newService() {
		return new multiselect.services.MultiSelectAllowListService();
	}

	private struct function _register(
		  required any   service
		, required array selectFields
		,          string orderBy = "label"
	) {
		var selectFieldsKey = arguments.service.addToAllowList(
			  targetObject = "crm_contact"
			, orderBy      = arguments.orderBy
			, selectFields = arguments.selectFields
		);

		return {
			  targetObject    = "crm_contact"
			, orderBy         = arguments.orderBy
			, selectFieldsKey = selectFieldsKey
		};
	}

}
