component {

	public void function configure( bundle ) {
		bundle.addAssets(
			  directory   = "/js/"
			, match       = function( path ){ return ReFindNoCase( "_[0-9a-f]{8}\..*?\.min.js$", arguments.path ); }
			, idGenerator = function( path ) {
				return ListDeleteAt( path, ListLen( path, "/" ), "/" ) & "/";
			}
		);
		bundle.addAssets(
			  directory   = "/css/"
			, match       = function( path ){ return ReFindNoCase( "_[0-9a-f]{8}\..*?\.min.css$", arguments.path ); }
			, idGenerator = function( path ) {
				return ListDeleteAt( path, ListLen( path, "/" ), "/" ) & "/";
			}
		);

		bundle.addAsset( id="ext-jq-chosen"          , path="/js/lib/jquery.chosen.min.js"             );
		bundle.addAsset( id="ext-jq-chosen-sortable" , path="/js/lib/jquery-chosen-sortable.min.js" );
		bundle.addAsset( id="ext-jq-chosen-jquery-ui", path="/js/lib/jquery-ui.min.js"             );
		bundle.addAsset( id="ext-custom-chosen"      , path="/js/specific/chosen/chosen.js"            );

		bundle.addAsset( id="ext-css-chosen"   , path="/css/lib/chosen.css"                      );

		bundle.asset( "ext-jq-chosen" ).dependsOn( "ext-css-chosen"    );
		bundle.asset( "ext-custom-chosen" ).dependsOn( "ext-jq-chosen" );
		bundle.asset( "ext-jq-chosen-jquery-ui" ).after( "ext-jq-chosen" );
		bundle.asset( "ext-jq-chosen-sortable" ).dependsOn( "ext-jq-chosen-jquery-ui" );

		bundle.asset( "/js/specific/multiSelect/" ).after( "ext-custom-chosen"  );
		bundle.asset( "/js/specific/singleSelectAjax/" ).after( "/js/specific/multiSelect/" );
	}
}