<cfscript>
	param name="url.reporter"  default="simple";
	param name="url.bundles"   default="";
	param name="url.directory" default="";
	param name="url.recurse"   default="true";
	param name="url.labels"    default="";
	param name="url.excludes"  default="";

	if ( len( url.bundles ) ) {
		url.directory = "";
	} else if ( !len( url.directory ) ) {
		url.directory = "tests.unit";
	}

	testbox = new testbox.system.TestBox(
		  options  = {}
		, reporter = url.reporter
		, labels   = url.labels
		, excludes = url.excludes
	);

	if ( len( url.bundles ) ) {
		testbox.addBundles( url.bundles );
	} else {
		testbox.addDirectory( {
			  mapping = url.directory
			, recurse = url.recurse
			, filter  = function( required path ) {
				return ReFindNoCase( "(Spec|Test)\.cfc$", arguments.path ) > 0;
			}
		} );
	}

	results = Trim( testbox.run() );

	content reset=true; echo( results ); abort;
</cfscript>
