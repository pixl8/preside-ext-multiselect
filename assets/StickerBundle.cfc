component {

	public void function configure( bundle ) {
		bundle.addAsset( id="ext-jq-chosen"    , path="/js/lib/jquery.chosen.min.js"             ); 
		bundle.addAsset( id="ext-custom-chosen", path="/js/specific/chosen/chosen.js"            );
		bundle.addAsset( id="ext-multi-select" , path="/js/specific/multiSelect/multi-select.js" ); 

		bundle.addAsset( id="ext-css-chosen"   , path="/css/lib/chosen.css"                      ); 

		bundle.asset( "ext-jq-chosen" ).dependsOn( "ext-css-chosen"    );
		bundle.asset( "ext-custom-chosen" ).dependsOn( "ext-jq-chosen" );
		bundle.asset( "ext-multi-select" ).after( "ext-custom-chosen"  );
	}
}