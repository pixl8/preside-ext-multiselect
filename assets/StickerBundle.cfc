component {

	public void function configure( bundle ) {
		bundle.addAsset( id="ext-jq-chosen"    , path="/js/lib/jquery.chosen.min.js"             );
		bundle.addAsset( id="ext-jq-chosen-sortable", path="/js/lib/jquery-chosen-sortable.min.js" );
		bundle.addAsset( id="ext-jq-chosen-jquery-ui", path="/js/lib/jquery-ui.min.js"             );
		bundle.addAsset( id="ext-custom-chosen", path="/js/specific/chosen/chosen.js"            );
		bundle.addAsset( id="ext-multi-select" , path="/js/specific/multiSelect/multi-select.js" );

		bundle.addAsset( id="ext-css-chosen"   , path="/css/lib/chosen.css"                      );

		bundle.asset( "ext-jq-chosen" ).dependsOn( "ext-css-chosen"    );
		bundle.asset( "ext-custom-chosen" ).dependsOn( "ext-jq-chosen" );
		bundle.asset( "ext-multi-select" ).after( "ext-custom-chosen"  );
		bundle.asset( "ext-jq-chosen-jquery-ui" ).after( "ext-jq-chosen" );
		bundle.asset( "ext-jq-chosen-sortable" ).dependsOn( "ext-jq-chosen-jquery-ui" );
	}
}