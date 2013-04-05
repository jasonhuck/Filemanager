[//lasso
	// Initialization
	// ----------------------------------------------------

	// /* live loading for debugging only
	( decimal(lasso_version( -lassoversion)) < 8.6 ) ? library('encode_json.inc'); // load every time to avoid version mismatches
	library('client_params.inc');
	library('encode_urlpath.inc');
	library('dictionary.inc');
	library('filemanager.inc');
	// */

	/*
	namespace_using(namespace_global);
		( decimal(lasso_version( -lassoversion)) < 8.6 ) ? library('encode_json.inc'); // load every time to avoid version mismatches
		!lasso_tagexists('client_params') || !lasso_tagexists('client_param') ? library('client_params.inc');
		!lasso_tagexists('encode_urlpath') ? library('encode_urlpath.inc');
		!lasso_tagexists('dictionary') ? library('dictionary.inc');
		!lasso_tagexists('filemanager') ? library('filemanager.inc');	
	/namespace_using;
	// */

	// serve JSON unless otherwise specified
	content_type('application/json');

	protect;
		handle_error;
			log_critical('[Filemanager] Configuration file is missing or corrupt.');
			content_body = '{Error: "Configuration File Missing", Code: -1}';
			abort;
		/handle_error;

		library('filemanager.config.inc');
	/protect;

	var('fm') = filemanager($config);



	// Authorization
	// ----------------------------------------------------

	if(!validuser);
		log_critical('[FileManager] Not a valid user.');
		content_body = '{Error: "' + $fm->lang->find('AUTHORIZATION_REQUIRED') + '", Code: ' + error_nopermission( -errorcode) + '}';
		abort;
	/if;



	// Request Handling
	// ----------------------------------------------------

	inline($fm->config->auth);			
		select(decode_url(client_param('mode')));
			case('getinfo');
				content_body = $fm->getinfo(
					-path=string(decode_url(client_param('path'))), 
					-getsize=(decode_url(client_param('getsize')) != 'false')
				);
				abort;
	
			case('getfolder');
				content_body = $fm->getfolder(
					decode_url(client_param('path')), 
					-getsizes=boolean(decode_url(client_param('showThumbs'))),
					-type=decode_url(client_param('type'))
				);
				abort;
			
			case('rename');
				content_body = $fm->rename(
					decode_url(client_param('old')), 
					decode_url(client_param('new'))
				);
				abort;		
			
			case('delete');
				content_body = $fm->delete(decode_url(client_param('path')));
				abort;		
			
			case('add');
				content_type('text/html');
				content_body = $fm->add(decode_url(client_param('currentpath')));
				abort;		
			
			case('addfolder');
				content_body = $fm->addfolder(
					decode_url(client_param('path')), 
					decode_url(client_param('name'))
				);
				abort;		
			
			case('download');
				$fm->download(decode_url(client_param('path')));
				
			case;
				content_body = encode_json(map(
					'Error' = $fm->getlang('MODE_ERROR'),
					'Code' = -1
				));
				abort;
				
		/select;	
	/inline;
]
