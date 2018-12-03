# posix (2004) reference: http://pubs.opengroup.org/onlinepubs/009695399/utilities/awk.html
# TODO: put in a generic file to be included with '-f that_filename' before this script
# to_generic_file {{{

function f_abort( msg ) {
	printf( "ERROR: %s\n", msg ) > "/dev/stderr";
	exit(1);
}

function f_debug( msg ) {
	if ( ! g_debug ) { return 0; }
	printf( "DEBUG: %s\n", msg ) > "/dev/stderr";
	return !0;
}

function f_setup_supported_operations_add( operid ) {
	g_operations_supported[ operid ] = 1;
}

function f_setup_validate_operation() {
	if ( !( g_in_operid in g_operations_supported ) ) {
		f_abort( sprintf( "operation '%s' not supported by this script", g_in_operid ) );
	}
}

# NOTE: (for the "FIXME" below: produce the correct filename for each snipdirid)
#  ultisnips -> snippetdirs/ultisnips/UltiSnips
#  ultisnips.ultisnips -> snippetdirs/ultisnips/UltiSnips
#  ultisnips.snipmate -> snippetdirs/ultisnips/snipmate
#  # etc.
#
# IDEA: have a list in the 'BEGIN' section that populates two arrays:
#  [ "ultisnips.ultisnips", "ultisnips/UltiSnips" ],
#  [ "ultisnips.snipmate", "ultisnips/snipmate" ],
#  [ "snipmate.snipmate", "snipmate/snippets" ],
#  [ "snipmate-compat.snipmate", "snipmate-compat/snippets" ],
#  # etc.
#  and a "snipdirid" aliases mapping array:
#   g_map_snipdirid_alias_to_snipdirid[ "ultisnips" ] = "ultisnips.ultisnips";
#   g_map_snipdirid_alias_to_snipdirid[ "snipmate-compat" ] = "snipmate-compat.snipmate";
#   # etc.
#   #? (NOTE: a single id will create a single option with "id.id" internally)
#  that will produce:
#   g_map_snipdirid_to_subdir[ "ultisnips.ultisnips" ] = "ultisnips/UltiSnips";
#   g_map_snipdirid_to_subdir[ "snipmate-compat.snipmate" ] = "snipmate-compat/snippets";
#   # etc.
#   g_map_subdir_to_snipdirid[ "ultisnips/UltiSnips" ] = "ultisnips.ultisnips";
#   # etc.
function f_setup_snipdirid_subdir_mappings( snipdirid, subdir ) {
	g_map_snipdirid_to_subdir[ snipdirid ] = subdir;
	g_map_subdir_to_snipdirid[ subdir ] = snipdirid;
}

function f_setup_snipdirid_alias( snipdirid_alias, snipdirid_dst ) {
	g_map_snipdirid_aliases[ snipdirid_alias ] = snipdirid_dst;
}

function f_snipdirid_alias_resolve( snipdirid_alias,		snipdirid_dst ) {
	snipdirid_dst = snipdirid_alias;
	while ( snipdirid_dst in g_map_snipdirid_aliases ) {
		snipdirid_dst = g_map_snipdirid_aliases[ snipdirid_dst ];
	}
	return snipdirid_dst;
}

function f_snipdirid_to_subdir( snipdirid,		subdir ) {
	snipdirid = f_snipdirid_alias_resolve( snipdirid );
	if ( !( snipdirid in g_map_snipdirid_to_subdir ) ) {
		f_abort( sprintf( "no subdir mapping entry for snipdirid '%s'", snipdirid ) );
	}
	return g_map_snipdirid_to_subdir[ snipdirid ];
}

function f_subdir_to_snipdirid( subdir,			snipdirid ) {
	if ( !( subdir in g_map_subdir_to_snipdirid ) ) {
		f_abort( sprintf( "no snipdirid mapping entry for subdir '%s'", subdir ) );
	}
	return f_snipdirid_alias_resolve( g_map_subdir_to_snipdirid[ subdir ] );
}

function f_pathname_snippetdir_getsubpathname( pathname,	pathname_orig ) {
	# first, make sure that this is a valid pathname that contains g_snippetdirs_parentdir_str_regexfriendly
	pathname_orig = pathname;
	if ( !( sub( "^.*" g_snippetdirs_parentdir_str_regexfriendly "/+", "", pathname ) ) ) {
		f_abort( sprintf( "pathname does not seem to be a valid path containing '%s': '%s'", g_snippetdirs_parentdir_str_regexfriendly, pathname ) );
	}
	return pathname;
}

function f_pathname_getsnippetsidsubdir( pathname,		pathname_orig, subdir_parent ) {
	pathname_orig = pathname;
	# first, make sure that this is a valid pathname that contains g_snippetdirs_parentdir_str_regexfriendly
	pathname = f_pathname_snippetdir_getsubpathname( pathname );

	for ( subdir_parent in g_map_subdir_to_snipdirid ) {
		if ( index( pathname, subdir_parent "/" ) == 1 ) {
			return subdir_parent;
		}
	}
	f_abort( sprintf( "could not find a standard snippets subdir for pathname '%s'", pathname_orig ) );
}

function f_pathname_to_snipdirid( pathname,		pathname_orig, pathname_child ) {
	# prev: pathname_orig = pathname;
	# prev: # first, make sure that this is a valid pathname that contains g_snippetdirs_parentdir_str_regexfriendly
	# prev: pathname = f_pathname_snippetdir_getsubpathname( pathname );

	# prev: for ( subdir_parent in g_map_subdir_to_snipdirid ) {
	# prev: 	# other_function: pathname_child = pathname;
	# prev: 	# other_function: # MAYBE: use index(), substr(), length() instead
	# prev: 	# other_function: if ( sub( "^" subdir_parent "/", "", pathname_child ) ) {
	# prev: 	# other_function: }
	# prev: 	if ( index( pathname, subdir_parent "/" ) == 1 ) {
	# prev: 		return g_map_subdir_to_snipdirid[ subdir_parent ];
	# prev: 	}
	# prev: }
	# prev: f_abort( sprintf( "could not calculate a snipdirid for pathname '%s'", pathname_orig ) );
	return f_subdir_to_snipdirid( f_pathname_getsnippetsidsubdir( pathname ) );
}

function f_pathname_snippetdir_getstemname( pathname,		pathname_orig, subdir, stemname ) {
	pathname_orig = pathname;
	subdir = f_pathname_getsnippetsidsubdir( pathname );
	pathname = f_pathname_snippetdir_getsubpathname( pathname );
	# MAYBE: use sub() instead?
	stemname = substr( pathname, length( subdir "/" ) + 1 );
	return stemname;
}

#? function isline_autoconversion( 
# TODO: [awk-compatibility] put this in a function and call that from the 'BEGIN' below?
BEGIN {
	g_autoconversion_fieldvalue_none = "\n*none*\n";
	# prev: g_autoconversion_extractfieldname_regex = "^#+[[:blank:]]autoconversion-snippet-([^:]+):[[:blank:]]+.*$";
	# prev: g_autoconversion_extractfieldname_replace = "\\1";
	# TODO: [awk-compatibility] replaced: "[[:blank:]]" -> "[ \t]"
	g_autoconversion_extractfieldname1_regex = "^#+[ \t]autoconversion-snippet-";
	g_autoconversion_extractfieldname1_replace = "";
	g_autoconversion_extractfieldname2_regex = ":[ \t]+.*$";
	g_autoconversion_extractfieldname2_replace = "";
	g_autoconversion_extractfieldval_regex = "^[^:]+:[ \t]+";
	g_autoconversion_extractfieldval_replace = "";
	g_snippetdirs_parentdir_str_regexfriendly = "/snippetdirs";

	f_setup_snipdirid_alias( "ultisnips", "ultisnips.ultisnips" );
	f_setup_snipdirid_alias( "snipmate-compat", "snipmate-compat.snipmate" );
	f_setup_snipdirid_alias( "snipmate", "snipmate.snipmate" );

	f_setup_snipdirid_subdir_mappings( "ultisnips.ultisnips", "ultisnips/UltiSnips" );
	f_setup_snipdirid_subdir_mappings( "ultisnips.snipmate", "ultisnips/snippets" );
	f_setup_snipdirid_subdir_mappings( "snipmate.snipmate", "snipmate/snippets" );
	f_setup_snipdirid_subdir_mappings( "snipmate-compat.snipmate", "snipmate-compat/snippets" );
}

function f_autoconversion_extract_fieldvalue( line, fieldsuff,		fieldsuff_src, fieldval ) {
	fieldsuff_src = line;
	if ( !( \
			( sub( g_autoconversion_extractfieldname1_regex, g_autoconversion_extractfieldname1_replace, fieldsuff_src ) ) \
			&& \
			( sub( g_autoconversion_extractfieldname2_regex, g_autoconversion_extractfieldname2_replace, fieldsuff_src ) ) \
			&& \
			( fieldsuff_src == fieldsuff ) \
		) ) {
		f_debug( sprintf( "failed to find the requested fieldname. line='%s'; fieldsuff_src='%s'; fieldsuff='%s'", line, fieldsuff_src, fieldsuff ) );
		return g_autoconversion_fieldvalue_none;
	}
	fieldval = line;
	if ( !( ( sub( g_autoconversion_extractfieldval_regex, g_autoconversion_extractfieldval_replace, fieldval ) ) ) ) {
		# internal error
		return g_autoconversion_fieldvalue_none;
	}
	return fieldval;
}

# }}} to_generic_file

#
# test invocations:
#  :wa | !find %:h:h:h/snippetdirs/ -name '*.snippets' -print0 | sort -z | time xargs -0 --no-run-if-empty awk -f % -v 'g_debug=0' -v 'g_in_operid=makefile_dependencies' ; echo "rc: $?"
#  :wa | !for p in gawk mawk ; do echo "program: $p" && find %:h:h:h/snippetdirs/ -name '*.snippets' -print0 | sort -z | time xargs -0 --no-run-if-empty "$p" -f % -v 'g_debug=0' -v 'g_in_operid=makefile_dependencies' ; echo "rc: $?" ; done
#

function f_snippetsfilename_get_parentdir( fname_src,		fname ) {
	fname = fname_src;
	# FIXME: re-write so that we don't use "\\1", etc.
	# prev: if ( sub( "(/snippetdirs)/[^/]+.*$", "\\1", fname ) == 0 ) {
	if ( sub( g_snippetdirs_parentdir_str_regexfriendly "/[^/]+.*$", g_snippetdirs_parentdir_str_regexfriendly, fname ) == 0 ) {
		# return "";
		f_abort( sprintf( "could not get the parentdir for a snippetdir pathname '%s'", fname_src ) );
	}
	return fname;
}

#? function f_filename_get_basename

# FIXME: produce the correct filename for each snipdirid:
function f_snippetsfilename_sibling_from_snipdirid( fname_src, snipdirid,		dirparent, fname ) {
	# TODO: get the basename and parentdir from fname_src
	dirparent = f_snippetsfilename_get_parentdir( fname_src );
	if ( length( dirparent ) == 0 ) { return ""; }
	#- fname = fname_src;
	#- if ( sub( "^.*/([^/]+)(\\.snippet[^/\\.]*)$", "\\1_generated\\2", fname ) == 0 ) {
	fname_base = fname_src;
	#? fname_pref = fname_src;
	#? fname_suff = fname_src;
	# prev: ( sub( "^.*/", "", fname_base ) > 0 ) \
	#
	if ( !( \
			( length( fname_base = f_pathname_snippetdir_getstemname( fname_src ) ) ) \
			&& \
			( length( fname_pref = fname_base ) ) \
			&& \
			( length( fname_suff = fname_base ) ) \
			&& \
			( sub( "\\.snippet[^\\.]*$", "", fname_pref ) > 0 ) \
			&& \
			( length( fname_suff = substr( fname_base, length( fname_pref ) + 1 ) ) ) \
		) ) {
		return "";
	}
	#- fname = dirparent "/" snipdirid "/" fname;
	# TODO: get the "_generated" string from an optional input variable (g_in_output_basename_suff)
	# FIXME: produce the correct filename (see comment above this function)
	fname = dirparent "/" f_snipdirid_to_subdir( snipdirid ) "/" fname_pref "_generated" fname_suff;
	return fname;
}

function f_expand_scriptoptions( pathname, snipdirid ) {
	return sprintf( "-v 'g_in_inid=%s' -v 'g_in_outid=%s'", f_pathname_to_snipdirid( pathname ), snipdirid );
}

# TODO: [awk-compatibility] call the function to be created in the common awk script above?
BEGIN {
	f_setup_supported_operations_add( "output_filenames" );
	f_setup_supported_operations_add( "makefile_dependencies" );
	f_setup_validate_operation();
	# see also: https://www.oreilly.com/library/view/effective-awk-programming/9781491904930/ch04.html
	#  (search for: 'Points to Remember About getline')
	#  IDEA: skip all lines for the current file, if needed. (use 'while ( (getline some_var) > 0 ) { /* until FILENAME changes? */ }')
	#g_queryfiles_done
}

{
	f_debug( "processing line: " $0 )
	outids_str = f_autoconversion_extract_fieldvalue( $0, "out-ids" );
	# skip lines that are of no interest to us
	if ( ( outids_str == g_autoconversion_fieldvalue_none ) || ( length( outids_str ) == 0 ) ) { next; }
	outids_n = split( outids_str, outids_arr );
	for ( i = 1; i <= outids_n; ++i ) {
		r_outid_now = f_snipdirid_alias_resolve( outids_arr[ i ] );
		# prev: printf( "DEBUG: saving filename '%s', out_id '%s'\n", FILENAME, outids_arr[ i ] ) > "/dev/stderr";
		f_debug( sprintf( "saving filename '%s', out_id '%s'", FILENAME, r_outid_now ) );
		g_queryfiles[ FILENAME, r_outid_now ] = 1;
	}
}

END {
	# NOTE: if this is not supported on every 'awk(1)' (the for assigning
	# to the two variables at once, splitting the index at SUBSEP
	# automatically), then get each keay in a single variable, and split()
	# using SUBSEP as the separator.
	#-? for ( ( t_fname, t_outid ) in g_queryfiles ) {
	for ( t_key in g_queryfiles ) {
		if ( split( t_key, t_key_arr, SUBSEP ) < 2 ) {
			f_abort( sprintf( "output array index '%s' format is incorrect", t_key ) );
		}
		t_fname = t_key_arr[ 1 ];
		t_outid = t_key_arr[ 2 ];

		t_fname_out = f_snippetsfilename_sibling_from_snipdirid( t_fname, t_outid );
		# IDEA: provide another output, which is more complete, and would allow to output the parameters to use on each conversion (on a later call to this script):
		#  sample produced rule:
		#   output_file : autoconversion_options/outputid=ultisnips.ultisnips/another_opt=value source_file
		#  so the implicit rules would:
		#   * operate on the first dependency (TODO: check that's the way that makefiles work) to work out which rule to apply:
		#     IDEA #1:
		#      % : autoconversion_options/* # (how do I specify that?)
		#     IDEA #2: (very rough syntax -- TODO: do properly)
		#      % : %.autoconversion_options_as_src
		#        invoke_this_script (foreach v,$(subst $(filter %.autoconversion_options_as_src),/, ),$(subst %=,g_opt_%,$(v))) -- $(filter-out %.autoconversion_options_*)
		#      # TODO: work out how to avoid 'make' complain about that file not existing (use '.PHONY:'? (but that still needs a target rule, so maybe we could define one for all of them? ('%.autoconversion_options/%: (nothing)')))

		if ( g_in_operid == "output_filenames" ) {
			print t_fname_out;
		} else if ( g_in_operid == "makefile_dependencies" ) {
			#? printf( "%s: %s\n.PRECIOUS: %s\n", t_fname_out, t_fname, t_fname );
			printf( "%s : %s\n", t_fname_out, t_fname );
			#? printf( "\t$(subst __script_options__,%s,$(EVPLG_SNIPPETS_PRJ_CONVERT_CMD))", f_expand_scriptoptions( t_key_arr[ 3 ] ) );
			printf( "\t$(subst __script_options__,%s,$(EVPLG_SNIPPETS_PRJ_CONVERT_CMD))\n", f_expand_scriptoptions( t_fname, t_outid ) );
			print "";
			printf( "EVPLG_SNIPPETS_PRJ_SNIPPETFILES_SRC += %s\n", t_fname );
			printf( "EVPLG_SNIPPETS_PRJ_SNIPPETFILES_DST += %s\n", t_fname_out );
			print "";
		}
	}
}

