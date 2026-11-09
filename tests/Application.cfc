component {

	this.name = "Multiselect Test Suite";

	this.mappings[ "/tests"       ] = ExpandPath( "/" );
	this.mappings[ "/testbox"     ] = ExpandPath( "/testbox" );
	this.mappings[ "/multiselect" ] = ExpandPath( "../" );

	setting requesttimeout=60000;

}
