
if exists('g:evplg_snippets_coll_simple_autoload_scope_vim') || &cp
	finish
endif
let g:evplg_snippets_coll_simple_autoload_scope_vim = 1

" force "compatibility" mode {{{
if &cp | set nocp | endif
" set standard compatibility options ("Vim" standard)
let s:cpo_save=&cpo
set cpo&vim
" }}}

let s:local_keywordflavours_dict_function_short = {
			\		'function': 'fu',
			\		'endfunction': 'endf',
			\	}

" MAYBE: separate in finer-grained groups (and update related "proc map",
" below).
let s:local_keywordflavours_dict_group01_short = {
			\		'unlet': 'unl',
			\		'lockvar': 'lockv',
			\
			\		'if': 'if',
			\		'endif': 'en',
			\		'else': 'el',
			\		'elseif': 'elsei',
			\
			\		'while': 'wh',
			\		'endwhile': 'endw',
			\
			\		'for': 'for',
			\		'endfor': 'endfo',
			\		'continue': 'con',
			\		'break': 'brea',
			\
			\		'try': 'try',
			\		'endtry': 'endt',
			\		'catch': 'cat',
			\		'finally': 'fina',
			\		'throw': 'th',
			\
			\		'finish': 'fini',
			\
			\		'echo': 'ec',
			\		'echon': 'echon',
			\		'echohl': 'echoh',
			\		'echomsg': 'echom',
			\		'echoerr': 'echoe',
			\
			\		'execute': 'exe',
			\	}

function! s:local_create_keywordflavours_dict_long_from_short( src_keywords_dict_short )
	" for now, each element's value matches its key, which is (by our
	" convention) the "long" version.
	return map(
				\		deepcopy( a:src_keywords_dict_short ),
				\		'v:key'
				\	)
endfunction

for [ s:local_tmp_keywordflavours_dict_varname_dst, s:local_tmp_keywordflavours_dict_varname_src ]
			\	in [
			\			[
			\				's:local_keywordflavours_dict_function_long',
			\				's:local_keywordflavours_dict_function_short',
			\			],
			\			[
			\				's:local_keywordflavours_dict_group01_long',
			\				's:local_keywordflavours_dict_group01_short',
			\			],
			\		]
	let { s:local_tmp_keywordflavours_dict_varname_dst } = s:local_create_keywordflavours_dict_long_from_short(
				\		{ s:local_tmp_keywordflavours_dict_varname_src }
				\	)
endfor
unlet! s:local_tmp_keywordflavours_dict_varname_src s:local_tmp_keywordflavours_dict_varname_dst

function! s:local_extenddicts( dict_dst, dicts, ... )
	let l:extend_mode = ( ( a:0 > 0 ) ? a:1 : 'force' )
	for l:dict_now in a:dicts
		call extend( a:dict_dst, l:dict_now, l:extend_mode )
	endfor
	return a:dict_dst
endfunction

function! s:local_keywordpopulatedict_short( keywords_dict )
	call s:local_extenddicts(
				\		a:keywords_dict,
				\		[
				\			s:local_keywordflavours_dict_function_short,
				\			s:local_keywordflavours_dict_group01_short,
				\		],
				\		'force'
				\	)
	return !0
endfunction

function! s:local_keywordpopulatedict_long( keywords_dict )
	call s:local_extenddicts(
				\		a:keywords_dict,
				\		[
				\			s:local_keywordflavours_dict_function_long,
				\			s:local_keywordflavours_dict_group01_long,
				\		],
				\		'force'
				\	)
	return !0
endfunction

let s:local_keyworddetection_proclist = [
			\		{
			\			'search_regex': '\v^\s*<%((fu%[nctio])|(function))>',
			\			'search_keywords_dict_map': {
			\					2: s:local_keywordflavours_dict_function_short,
			\					3: s:local_keywordflavours_dict_function_long,
			\				},
			\		},
			\		{
			\			'search_regex': '\v^\s*<%((%(en%[di])|%(el%[s])|elsei|endfo|%(con%[tinu])|brea|%(wh%[il])|%(endw%[hil])|%(fini%[s]))|(endif|else|elseif|endfor|continue|break|while|endwhile|finish))>',
			\			'search_keywords_dict_map': {
			\					2: s:local_keywordflavours_dict_group01_short,
			\					3: s:local_keywordflavours_dict_group01_long,
			\				},
			\		},
			\	]

function! s:local_keywordpopulatedict_detect( keywords_dict )
	let l:keyword_dict_is_final = !0
	for l:proc_elem_now in s:local_keyworddetection_proclist
		let l:matched_element_flag = 0

		let l:regex_now = get( l:proc_elem_now, 'search_regex', '' )
		if ( ! empty( l:regex_now ) )
			let l:matched_element_flag = 0
			let l:subpattern_number = search(
						\		l:regex_now,
						\		'bnpw'
						\	)
			if l:subpattern_number > 0
				let l:matched_element_flag = !0
				if has_key( l:proc_elem_now, 'search_keywords_dict_map' )
					let l:keywords_dict_map = l:proc_elem_now[ 'search_keywords_dict_map' ]
					if has_key( l:keywords_dict_map, l:subpattern_number )
						call extend(
									\		a:keywords_dict,
									\		l:keywords_dict_map[ l:subpattern_number ],
									\		'force'
									\	)
					else
						let l:keyword_dict_is_final = 0
					endif
				endif
			else
				let l:keyword_dict_is_final = 0
			endif
		endif

		" NOTE: this is meant to be used for "modeline"-like tags, so that
		" this "detection" can read those and use the user-specified
		" setting(s) in preference to the detected one(s).
		if l:matched_element_flag && get( l:proc_elem_now, 'finish_processing_on_match', 0 )
			break
		endif
	endfor
	return l:keyword_dict_is_final
endfunction

let s:local_keywordflavours_map = {
			\		'short': function( 's:local_keywordpopulatedict_short' ),
			\		'long': function( 's:local_keywordpopulatedict_long' ),
			\		'detect': function( 's:local_keywordpopulatedict_detect' ),
			\	}

function! evplg#snippets#scope#vim#init_lazy()
	call evplg#snippets#baselib#init#init_lazy()

	" TODO: own stuff to be done on every expansion (keep it cheap)
	"  IDEA #1: detect evplg#snippets#baselib#scopecache#has_cached_key( 'forced_keyworddict' )
	"   if not found: IDEA: detect ...?
	"  IDEA #2: detect evplg#snippets#baselib#scopecache#has_cached_key( 'keyword_dict_final' )
	"   if not set: detect b:evplg_snippets_scopectrl_keywordflavour_id (one of: 'short', 'long', 'detect')
	"   IDEA #2.1: detect b:evplg_snippets_scopectrl_keywordflavour_overrides (dictionary type)
	"    (note: use 'extend' with 'force' to write over the ones set up by the
	"    'id').
	"  IDEA: once set, assign to cache key: evplg#snippets#baselib#scopecache#set_cached_value()
	"   TODO: work out a way by which we can keep using 'detect' possibly
	"    until the user sets a value himself (like 'long' and a "customdict")
	"   TODO: is he supposed to execute the command to remove the cache
	"    entries for the current buffer? that seems excessive for the use case
	"    where a new file is being edited, for which there is still no code
	"    from which to detect the current (keyword) style.
	"    IDEA: use a dict for the ids, where each element is a funcref that is
	"    supposed to return a boolean indicating whether the return value is
	"    definitive.
	"    { 'short': s:local_keywordpopulatedict_short, ... }
	"    function! s:local_keywordpopulatedict_short( keywords_dict )
	"    	call extend( a:keywords_dict, { 'function': 'fu', ... }, 'force' )
	"    	return !0
	"    endfunction
	"     TODO: but what would be the default for the 'detect' case? 'long' or
	"     'short'? maybe it'd be best to have a list of 'id's, so if all of
	"     them say "truthy", then we can set 'keyword_dict_final'.
	"      IDEA: for the 'detect' case: work with 'b:changedtick' to make sure
	"      we won't be doing a multi-line search several times per snippet,
	"      for example.
	"       IDEA: or use a time-based cache? (maybe not)
	if ( ! evplg#snippets#baselib#scopecache#get_cached_value( 'keyword_dict_is_final', 0 ) )
		let l:keyword_dict = {}
		let l:keywordflavours = evlib#stdtype#AsTopLevelList(
					\		get(
					\				b:, 'evplg_snippets_scopectrl_keywordflavour_id',
					\				evplg#snippets#baselib#scopecache#get_cached_value(
					\						'keywordflavour_ids',
					\						get(
					\								b:, 'evplg_snippets_scopectrl_keywordflavour_id_default',
					\								get(
					\										g:, 'evplg_snippets_scopectrl_keywordflavour_id_default',
					\										[ 'long', 'detect', ]
					\									)
					\							)
					\					)
					\			)
					\	)
		let l:keyword_dict_is_final = !0
		for l:keyword_flavour_now in l:keywordflavours
			let l:keyword_dict_is_final = (
						\		s:local_keywordflavours_map[ l:keyword_flavour_now ]( l:keyword_dict )
						\		&&
						\		l:keyword_dict_is_final
						\	)
		endfor
		if l:keyword_dict_is_final
			call evplg#snippets#baselib#scopecache#set_cached_value( 'keyword_dict_is_final', l:keyword_dict_is_final )
		endif
		call evplg#snippets#baselib#scopecache#set_cached_value( 'keyword_dict', l:keyword_dict )
	endif
endfunction

function! evplg#snippets#scope#vim#get_default_function_prefix()
	call evplg#snippets#scope#vim#init_lazy()
	return (
				\		( expand('%:p') =~ '\v<autoload/' )
				\			?	substitute(matchstr(expand('%:p'),'\v<autoload/\zs.*\ze\.vim$'),'[/\\]','#','g').'#'
				\			:	''
				\	)
endfunction

function! evplg#snippets#scope#vim#keyword( keyword )
	call evplg#snippets#scope#vim#init_lazy()
	return get(
				\		evplg#snippets#baselib#scopecache#get_cached_value(
				\				'keyword_dict',
				\				{}
				\			),
				\		a:keyword,
				\		a:keyword
				\	)
endfunction

"+/-? ... " dictionary elements format:
"+/-? ... "  'parts_sreplace' list of 2 elements:
"+/-? ... "   0: magic-setting-agnostic "search" expression
"+/-? ... "   1: replacement value (':h substitute()'), from which the replacement
"+/-? ... "   tokens ('\0', '\1', '\2', ...) will create corresponding elements
"+/-? ... function! s:local_get_guardsymbol_pathname_customdict( proc_dict )
"+/-? ... endfunction

" TODO: move generic function to evlib
" optional args: [return_matching_input_index_too]
"  return_matching_input_index_too:
"   ==0: returns matchlist_return_value
"   !0: changes the return value to [ index_of_src_pattern, matchlist_return_value ]
function! s:local_matchlist_multilist( patterns_list, haystack, ... )
	" TODO: remove: DEBUG: echomsg 'DEBUG: local_matchlist_multilist() entered: haystack=' . string(a:haystack) . '; patterns_list=' . string(a:patterns_list)
	"+? prev: v1: let l:ret_index_flag = ( a:0 > 0 ) && ( !! a:1 )
	let l:ret_index_flag = !! get( a:000, 0, 0 )
	let l:idx_now = -1

	for l:pat_now in a:patterns_list
		let l:idx_now += 1
		try
			if empty( l:pat_now )
				continue
			endif

			let l:ret_list = matchlist( a:haystack, l:pat_now )
			" TODO: remove: DEBUG: echomsg 'DEBUG:  searched: haystack=' . string(a:haystack) . '; pattern_now=' . string( l:pat_now ) . '; result=' . string(l:ret_list)

			" for now, only consider the search valid if the matched string is non-empty
			"+? if ( ! empty( l:ret_list ) ) && ( ! empty( l:ret_list[0] ) )
			if ! empty( get( l:ret_list, 0, 0 ) )
				return ( l:ret_index_flag ? [ l:idx_now, l:ret_list ] : l:ret_list )
			endif
		catch
			" MAYBE: log debug message
		endtry
	endfor
	return ( l:ret_index_flag ? [ -1, [] ] : [] )
endfunction

let s:local_getpathname_components_currentfile_proc_dict_matched_common_def = {
			\		'calculated_keys': [
			\				{
			\					'pn_full': {
			\							'expr': 'fnamemodify(l:match_list_orig[0], ":p")',
			\							'flag_overwriteprevemptyvalue': !0,
			\							'flag_allowsettingemptyvalue': !0,
			\						},
			\				},
			\				{
			\					'proj_id': {
			\							'expr': '( index( [ "", expand( "$HOME" ), "/" ], get( l:match_dict, "pn_proj_worktree", "" ) ) >= 0 ) ? "" : fnamemodify( l:match_dict[ "pn_proj_worktree" ], ":t" )',
			\							'expr__TODO_remove_1': 'fnamemodify(l:proj_worktree, ":t")',
			\						},
			\				},
			\			],
			\	}

let s:local_getpathname_components_currentfile_proc_dict_list_def = {
			\		'calculated_keys': [
			\				{
			\					'pn_proj_file_full':
			\						{ 'value': '' },
			\				},
			\				{
			\					'pn_proj_file_dir': {
			\							'expr': 'fnamemodify( l:match_dict[ "pn_proj_file_full" ], ":h" )',
			\						},
			\				},
			\				{
			\					'pn_pathident_dir_comp':
			\						{ 'value__TODO_remove_1': '' },
			\				},
			\				{
			\					'pn_pathident_dir_workdir': {
			\							'expr': 'empty( get( l:match_dict, "pn_pathident_dir_comp", "" ) ) ? "" : matchlist( l:match_dict[ "pn_full" ], "\\v^(.*/" . EVVimRC_util_regex_literaltoregex_verymagic( l:match_dict[ "pn_pathident_dir_comp" ] ) . ")/.+$")[1]',
			\							'expr__TODO_remove_1': 'empty( get( l:match_dict, "pn_pathident_dir_comp", "" ) ) ? "" : substitute( l:match_dict[ "pn_full" ], "\\v^(.*/" . l:match_dict[ "pn_pathident_dir_comp" ] . ")/.+$", "\\1", "" )',
			\						},
			\				},
			\				{
			\					'pn_pathident_file_full': {
			\							'expr': 'empty( get( l:match_dict, "pn_pathident_dir_comp", "" ) ) ? "" : matchlist( l:match_dict[ "pn_full" ], "\\v^.*/(" . EVVimRC_util_regex_literaltoregex_verymagic( l:match_dict[ "pn_pathident_dir_comp" ] ) . "/.+)$")[1]',
			\						},
			\				},
			\				{
			\					'pn_pathident_file_dir': {
			\							'expr': 'empty( get( l:match_dict, "pn_pathident_file_full", "" ) ) ? "" : fnamemodify( l:match_dict[ "pn_pathident_file_full" ], ":h" )',
			\						},
			\				},
			\				{
			\					'pn_basename_full': {
			\							'expr': 'fnamemodify( l:pathname, ":t" )',
			\							'flag_overwriteprevemptyvalue': !0,
			\						},
			\				},
			\				{
			\					'pn_basename_noext': {
			\							'expr': 'fnamemodify( l:match_dict[ "pn_basename_full" ], ":r" )',
			\							'flag_overwriteprevemptyvalue': !0,
			\						},
			\				},
			\			],
			\	}

" optional args:
"  [named_args_dict]
"   'proc_dict_list_all_pre'
"   'proc_dict_list_default_pre'
"   'proc_dict_list_all_post'
"   'proc_dict_all_pre'
"   'proc_dict_matched_post'
"   'proc_dict_all_post'
"
" returns a dict with the following components
" 'pn_full': full pathname
" 'proj_id': project id (usually, the "top-level" directory basename
" 'pn_proj_worktree': project "work tree" (example: as returned by FugitiveWorkTree()')
" 'pn_proj_file_full'
" 'pn_proj_file_dir'
" 'pn_pathident_dir_comp'
" 'pn_pathident_dir_workdir'
" 'pn_pathident_file_full'
" 'pn_pathident_file_dir'
" 'pn_basename_full'
" 'pn_basename_noext'
function! s:local_getpathname_components_currentfile( ... )
	let l:named_args_dict = get( a:000, 0, {} )
	let l:pathname = expand( '%:p' )

	let l:proj_worktree = ''
	if empty( l:proj_worktree ) && exists( '*FugitiveWorkTree' )
		" ref: ':h filename-modifiers'
		" NOTE: as FugitiveWorkTree() returns a valid directory (NOTE: not
		" '/'-terminated anyway), we know that the ':p' will add the '/' at
		" the end, so we use the ':h' to get its "head" (before the last '/').
		let l:proj_worktree = fnamemodify( FugitiveWorkTree(), ':p:h' )
	endif

	" TODO: move this to module-level constants, and conditionally construct
	" this, for those (patterns? values?) that do not depend on the input
	" value.
	let l:patterns_proc_dict_list =
				\		get( l:named_args_dict, 'proc_dict_list_all_pre', [] )
				\		+
				\		get( l:named_args_dict, 'proc_dict_list_default_pre', [] )
				\		+
				\		(	( ! empty( l:proj_worktree ) )
				\			?	[
				\					{
				\						'search_multi': {
				\								'search_pattern': '\v'
				\									. '^'
				\										. EVVimRC_util_regex_literaltoregex_verymagic( l:proj_worktree )
				\									. '/'
				\									. '(.+)$',
				\								'matchlist_key_index_mapping': {
				\										'pn_proj_file_full': 1,
				\									},
				\							},
				\						'calculated_keys': [
				\								{
				\									'pn_proj_worktree': {
				\											'expr__TODO_remove_1': 'fnamemodify(l:proj_worktree, ":p")',
				\											'value': l:proj_worktree,
				\										},
				\								},
				\							],
				\					}
				\				]
				\			:	[]
				\		)
				\		+
				\		get( l:named_args_dict, 'proc_dict_list_all_post', [] )

	" TODO: remove (debug)
	"echomsg 'DEBUG: l:patterns_proc_dict_list=' . string( l:patterns_proc_dict_list )

	let [ l:match_list_element_index, l:match_list_orig ] = s:local_matchlist_multilist(
				\		map(
				\				copy( l:patterns_proc_dict_list ),
				\				'get( get( v:val, "search_multi", {} ), "search_pattern", "" )'
				\			),
				\		l:pathname,
				\		!0
				\	)

	" FIXME: TESTING: remove this line when the implementation is done
	" TODO: remove: DEBUG: return [ l:match_list_element_index, l:match_list_orig ]

	let l:ret_errvalue = {}
	" NOTE: 'l:match_dict' used inside expression strings to be 'eval()'-ed by
	" vim.
	let l:match_dict = {}

	if l:match_list_element_index >= 0
		let l:patterns_proc_dict_matched = l:patterns_proc_dict_list[ l:match_list_element_index ]
		if ! has_key( l:patterns_proc_dict_matched, 'search_multi' )
			" TODO: check that this is the way to deal with errors/raise
			" exceptions within this project.
			return l:ret_errvalue
		endif

		let l:matchlist_key_index_mapping_dict = get( l:patterns_proc_dict_matched[ 'search_multi' ], 'matchlist_key_index_mapping', {} )
		if ! empty( l:matchlist_key_index_mapping_dict )
			call extend(
						\		l:match_dict,
						\		map(
						\				copy( l:matchlist_key_index_mapping_dict ),
						\				'l:match_list_orig[ v:val ]'
						\			),
						\		'keep'
						\	)
		endif

		let l:proc_dict_all_pre			= get( l:named_args_dict, 'proc_dict_all_pre', {} )
		let l:proc_dict_matched_post	= get( l:named_args_dict, 'proc_dict_matched_post', {} )
		let l:proc_dict_all_post		= get( l:named_args_dict, 'proc_dict_all_post', {} )

		for l:calculated_keys_dict_now in
					\	get( l:proc_dict_all_pre, 'calculated_keys', [] )
					\		+ get( l:patterns_proc_dict_matched, 'calculated_keys', [] )
					\		+ get( s:local_getpathname_components_currentfile_proc_dict_matched_common_def, 'calculated_keys', [] )
					\		+ get( l:proc_dict_matched_post, 'calculated_keys', [] )
					\		+ get( s:local_getpathname_components_currentfile_proc_dict_list_def, 'calculated_keys', [] )
					\		+ get( l:proc_dict_all_post, 'calculated_keys', [] )
			for [ l:match_dict_key_now, l:calculated_keys_proc_dict_now ] in items( l:calculated_keys_dict_now )
				" skip trying to set a value for entries already present in
				" l:match_dict, unless 'flag_forced' is set to a "truthy"
				" value (default is "falsy", which means only set elements for
				" non-existing keys).
				"+ prev: v1: if has_key( l:match_dict, l:match_dict_key_now ) | continue | endif
				"+ prev: v2: if has_key( l:match_dict, l:match_dict_key_now ) && ( ! get( l:calculated_keys_proc_dict_now, 'flag_forced', 0 ) )
				"?... v3: if
				"?... v3: 			\	!(
				"?... v3: 			\		(
				"?... v3: 			\			( ! has_key( l:match_dict, l:match_dict_key_now ) )
				"?... v3: 			\			||
				"?... v3: 			\			get( l:calculated_keys_proc_dict_now, 'flag_forced', 0 )
				"?... v3: 			\		)
				"?... v3: 			\		&&
				"?... v3: 			\		(
				"?... v3: 			\		)
				"?... v3: 			\	)
				if
							\	has_key( l:match_dict, l:match_dict_key_now )
							\	&&
							\	(
							\		( ! get( l:calculated_keys_proc_dict_now, 'flag_forced', 0 ) )
							\		||
							\		(
							\			empty( l:match_dict[ l:match_dict_key_now ] )
							\			&&
							\			( ! get( l:calculated_keys_proc_dict_now, 'flag_overwriteprevemptyvalue', 0 ) )
							\		)
							\	)
					continue
				endif

				"+ prev: v1: if has_key( l:calculated_keys_proc_dict_now, 'value' )
				"+ prev: v1: 	let l:match_dict[ l:match_dict_key_now ] = l:calculated_keys_proc_dict_now[ 'value' ]
				"+ prev: v1: elseif has_key( l:calculated_keys_proc_dict_now, 'expr' )
				"+ prev: v1: 	let l:match_dict[ l:match_dict_key_now ] = eval( l:calculated_keys_proc_dict_now[ 'expr' ] )
				"+ prev: v1: " NOTE: for now, we ignore entries for which we have no "handler"
				"+ prev: v1: "  MAYBE: report as warning/error, and keep going
				"? unlet! l:xvalue
				if has_key( l:calculated_keys_proc_dict_now, 'value' )
					let l:xvalue = l:calculated_keys_proc_dict_now[ 'value' ]
				elseif has_key( l:calculated_keys_proc_dict_now, 'expr' )
					let l:xvalue = eval( l:calculated_keys_proc_dict_now[ 'expr' ] )
				" NOTE: for now, we ignore entries for which we have no "handler"
				"  MAYBE: report as warning/error, and keep going
				endif

				if exists( 'l:xvalue' )
					if
								\	(
								\		( ! (
								\			empty( l:xvalue )
								\		) )
								\		||
								\		(
								\			get( l:calculated_keys_proc_dict_now, 'flag_allowsettingemptyvalue', 0 )
								\		)
								\	)
						let l:match_dict[ l:match_dict_key_now ] = l:xvalue
					endif
					unlet l:xvalue
				endif
			endfor
		endfor
	endif

	return l:match_dict
endfunction

let s:local_guardsymbol_sep = '_'

" optional args:
"  [result_to_be_used_as_symbol_or_prefix]
"
"   result_to_be_used_as_symbol_or_prefix (default: !0)
"		whether the individual string is to be used at the beginning of a
"		multi-part symbol construct, or if the result is meant to be used as
"		the full symbol.
"
" function to use within these "processing" elements to create valid vim
" identifiers.
"  NOTE: for example, it should deal with pathnames starting with a number or
"  another invalid pathname component character (including separators), etc.
function! evplg#snippets#scope#vim#symbol_from_str( src, ... )
	let l:retval =
				\	(	( !! get( a:000, 0, !0 ) )
				\		?	substitute(
				\					a:src,
				\					'\v^[^a-zA-Z_]',
				\					s:local_guardsymbol_sep,
				\					''
				\				)
				\		:	a:src
				\	)
	let l:retval = substitute(
				\		l:retval,
				\		'\v[^a-zA-Z0-9_]',
				\		s:local_guardsymbol_sep,
				\		'g'
				\	)
	" TODO: define a new function in evlib for 'tolower()' (not available on vim-7.0) instead of doing this hack here
	let l:retval = exists( '*tolower' ) ? tolower( l:retval ) : substitute( l:retval, '\v^.*$', '\L&', '' )
	return l:retval
endfunction

function! evplg#snippets#scope#vim#symbol_from_list_or_str( src_list_or_str )
	if type( a:src_list_or_str ) == type( '' )
		return evplg#snippets#scope#vim#symbol_from_str( a:src_list_or_str )
	endif

	let l:ret_nothing = ''

	let l:helper_func_args =
				\		map(
				\				filter(
				\						copy( a:src_list_or_str ),
				\						'!empty(v:val)'
				\					),
				\				'[ 0, v:val ]'
				\			)
	if empty( l:helper_func_args )
		return l:ret_nothing
	endif

	" only the first (non-empty, which has been already filtered) string is to
	" be treated as a "symbol prefix", as following items will have a valid
	" prefix, and thus allow more values (digits, in our case).
	let l:helper_func_args[ 0 ][ 0 ] = !0

	return join(
				\		map(
				\				l:helper_func_args,
				\				'evplg#snippets#scope#vim#symbol_from_str(v:val[1], v:val[0])'
				\			),
				\		s:local_guardsymbol_sep
				\	)
endfunction

" returns a dict with the following components
"  'sym_full': (guard) symbol for the whole pathname ('pn_full')
"  'sym_proj_id'
"  'sym_proj_worktree'
"  'sym_proj_file_full'
"  'sym_proj_file_dir'
"  "? 'sym_proj_dirpath_1' (example: 'autoload')
"  "? 'sym_proj_dirpath_2_to_end' (example: symbol from path 'evplg/snippets/scope/vim.vim')
"-? "  'sym_leaf_basenoext'
"-? "  'sym_leaf_basefull'
"  'sym_pathident_dir_comp'
"  'sym_pathident_dir_workdir'
"  'sym_pathident_file_full'
"  'sym_pathident_file_dir'
"  'sym_basename_full'
"  'sym_basename_noext'
function! evplg#snippets#scope#vim#get_guardsymbol_comps_currentfile( ... )
	let l:match_dict = call( function("s:local_getpathname_components_currentfile"), a:000 )

	" TODO: create loop processing (yet another) "processing" elements list to
	" evaluate expressions and optionally override elmeents in the match_dict copy
	" (to be returned from this function)
	call extend(
				\		l:match_dict,
				\		map(
				\				filter(
				\						map(
				\								{
				\									'sym_full':						'pn_full',
				\									'sym_proj_id':					'proj_id',
				\									'sym_proj_worktree':			'pn_proj_worktree',
				\									'sym_proj_file_full':			'pn_proj_file_full',
				\									'sym_proj_file_dir':			'pn_proj_file_dir',
				\									'sym_pathident_dir_comp':		'pn_pathident_dir_comp',
				\									'sym_pathident_dir_workdir':	'pn_pathident_dir_workdir',
				\									'sym_pathident_file_full':		'pn_pathident_file_full',
				\									'sym_pathident_file_dir':		'pn_pathident_file_dir',
				\									'sym_basename_full':			'pn_basename_full',
				\									'sym_basename_noext':			'pn_basename_noext',
				\								},
				\								'substitute( get( l:match_dict, v:val, "" ), "^/", "", "" )'
				\							),
				\						'!empty(v:val)'
				\					),
				\				'evplg#snippets#scope#vim#symbol_from_str(v:val)'
				\			),
				\		'keep'
				\	)

	return l:match_dict
endfunction

" restore old "compatibility" options {{{
let &cpo=s:cpo_save
unlet s:cpo_save
" }}}

" vim600: set filetype=vim fileformat=unix:
" vim: set noexpandtab:
" vi: set autoindent tabstop=4 shiftwidth=4:
