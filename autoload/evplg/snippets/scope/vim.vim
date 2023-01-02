
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
	let l:autoload_funcbasename = matchstr( expand( '%:p' ), '\v/autoload/\zs.*\ze\.vim$' )
	return (
				\		! empty( l:autoload_funcbasename )
				\			?	( substitute( l:autoload_funcbasename, '[/\\]\+', '#', 'g' ) . '#' )
				\			:	''
				\	)
endfunction

" NOTE: see function evplg#snippets#scope#vim#bufexpr_to_symbol() for
" information on the supported dictionary elements.
"
let s:bufexpr_to_symbol_transform_dict_list =
			\	[
			\	]

" TODO: move to a language-agnostic file (and use the language-specific
" functions (such as evplg#snippets#scope#vim#get_symbol_base_for_buffer())
" from snippets).
"
" prev: evplg#snippets#scope#vim#get_include_guard_symbol() abort
" optional args:
"  * bufexpr (string, default: '%')
"  * list_transform_pre (list of dict, default: empty)
"  * list_transform_post (list of dict, default: empty)
"
" TODO: document the dictionary elements supported format.
function! evplg#snippets#scope#vim#bufexpr_to_symbol( ... ) abort
	call evplg#snippets#scope#vim#init_lazy()

	let l:retval_none = ''

	let l:bufexpr = get( a:000, 0, '%' )
	let l:transform_dict_list_pre = get( a:000, 1, [] )
	let l:transform_dict_list_post = get( a:000, 2, [] )

	" only allocate a temporary list when using specified "custom" dictionary
	" list(s).
	"+ prev: v1: let l:transform_dict_list =
	"+ prev: v1: 			\	(	( empty( l:transform_dict_list_pre ) && empty( l:transform_dict_list_post ) )
	"+ prev: v1: 			\		?	s:bufexpr_to_symbol_transform_dict_list
	"+ prev: v1: 			\		:	( l:transform_dict_list_pre + s:bufexpr_to_symbol_transform_dict_list + l:transform_dict_list_post )
	"+ prev: v1: 			\	)
	let l:transform_dict_list = evlib#stdtype#ExtendInOrderOrGetRef(
				\		[
				\			l:transform_dict_list_pre,
				\			s:bufexpr_to_symbol_transform_dict_list,
				\			l:transform_dict_list_post,
				\		]
				\	)

	for l:pathname_transform_dict in l:transform_dict_list
		let l:symbol = ""

		let l:fname_part = get( l:pathname_transform_dict, 'fname_part', 'basename' )
		let l:fnamemod_flags = ''
		if l:fname_part ==# 'basename'
			let l:fnamemod_flags = ':t'
		elseif l:fname_part ==# 'full'
			let l:fnamemod_flags = ':p'
		else
			" TODO: throw
		endif
		if empty( l:fnamemod_flags )
			continue " prev: return l:retval_none
		endif

		" prev: let l:pathname = expand( '%' . l:fnamemod_flags )
		let l:pathname = fnamemodify( bufname( l:bufexpr ), l:fnamemod_flags )
		if empty( l:pathname )
			continue " prev: return l:retval_none
		endif

		let l:match_regex = get( l:pathname_transform_dict, 'match_regex', '' )
		if ( ! empty( l:match_regex ) )
			let l:match_str = matchstr( l:pathname, l:match_regex )
			if empty( l:match_str )
				continue " prev: return l:retval_none
			endif
			let l:match_subst_expr = get( l:pathname_transform_dict, 'match_subst', '' )
			if ( ! empty( l:match_subst_expr ) )
				let l:symbol = substitute( l:pathname, l:match_regex, l:match_subst_expr, 'g' )
			endif
		" NOTE: other matching criteria: elseif ( ... )
		endif
		if ( ! empty( l:symbol ) )
			break
		endif
	endfor
	if empty( l:symbol )
		return l:retval_none
	endif
	" sanitise calculated symbol name
	" prev: v1:\		[ '\v^', 'sourceproc_' ],
	" prev: v1:\		[ '\v$', '_included' ],
	" prev: v1:\		[ '\v^%([g]:)@<!', 'g:' ],
	for [ l:match_regex, l:match_subst_expr ] in
				\	[
				\		[ '\v(_){2,}', '\1' ],
				\		[ '\v[^a-zA-Z0-9_]', '_' ],
				\	]
		let l:symbol = substitute( l:symbol, l:match_regex, l:match_subst_expr, 'g' )
	endfor
	return l:symbol
endfunction

let s:bufexpr_to_symbol_vim_transform_dict_list =
			\	[
			\		{
			\			'match_regex': '\v^([a-z][^\.]*)%(\..*)?$',
			\			'match_subst': '\1',
			\		},
			\	]

" optional args:
"  * varname_base : varname to use instead of the default
"  * imp_a_000 : array with arguments to be passed (expanded) to the
"    implemenetation function 'evplg#snippets#scope#vim#bufexpr_to_symbol()'.
"    NOTE: arguments can be used as "additional" data to calculated values
"    inside this function.
function! evplg#snippets#scope#vim#bufexpr_to_symbol_wrapper( ... ) abort
	"+? prev: v3: let l:varname_pref_noscope = get( a:000, 0, 'evplg_snippets_scope_vim_' . 'buftosym_' . 'transform_dict_list' )
	let l:varname_pref_noscope = get( a:000, 0, '' )
	" TODO: validate l:varname_pref_noscope (valid id? or just non-empty?)
	if empty( l:varname_pref_noscope ) || ( l:varname_pref_noscope =~ '\v[\*\=]' )
		let l:varname_pref_noscope = 'evplg_snippets_scope_vim_' . 'buftosym_' . 'transform_dict_list'
	endif

	let l:null_list = []

	"+? prev: v1: let l:wrapped_args_list = [ '%', l:null_list, l:null_list ]
	let l:wrapped_args_list = copy( get( a:000, 1, [] ) )
	call evlib#stdtype#ListSetDefaultElements( l:wrapped_args_list, [ '%', l:null_list, l:null_list ] )

	" example final varnames: (TODO: complete)
	"  evplg_snippets_scope_vim_buftosym_transform_dict_list_pre
	"  evplg_snippets_scope_vim_buftosym_transform_dict_list
	"  evplg_snippets_scope_vim_buftosym_transform_dict_list_post
	for [ l:wrapped_argidx, l:varname_suff ] in [
				\		[ 1, '_pre' ],
				\		[ 1, '' ],
				\		[ 1, s:bufexpr_to_symbol_vim_transform_dict_list ],
				\		[ 2, '_post' ],
				\	]
		"+ prev: v1: let l:varname_now = l:varname_pref_noscope . l:varname_suff
		"+ prev: v1: let l:wrapped_args_list[ l:wrapped_argidx ] = evlib#stdtype#ExtendInOrderOrGetRef(
		"+ prev: v1: 			\		[
		"+ prev: v1: 			\			l:wrapped_args_list[ l:wrapped_argidx ],
		"+ prev: v1: 			\			get( b:, l:varname_now, l:null_list ),
		"+ prev: v1: 			\			get( g:, l:varname_now, l:null_list ),
		"+ prev: v1: 			\		]
		"+ prev: v1: 			\	)
		if type( l:varname_suff ) == type( '' )
			let l:varname_now = l:varname_pref_noscope . l:varname_suff
		endif
		"? prev: v2: let l:wrapped_args_list[ l:wrapped_argidx ] = evlib#stdtype#ExtendInOrderOrGetRef(
		"? prev: v2: 			\		[
		"? prev: v2: 			\			l:wrapped_args_list[ l:wrapped_argidx ],
		"? prev: v2: 			\		]
		"? prev: v2: 			\			+
		"? prev: v2: 			\			(	( type( l:varname_suff ) == type( l:null_list ) )
		"? prev: v2: 			\				?	[ l:varname_suff ]
		"? prev: v2: 			\				:	[
		"? prev: v2: 			\						get( b:, l:varname_now, l:null_list ),
		"? prev: v2: 			\						get( g:, l:varname_now, l:null_list ),
		"? prev: v2: 			\					]
		"? prev: v2: 			\			)
		"? prev: v2: 			\	)
		"-? prev: v3: let l:wrapped_args_list[ l:wrapped_argidx ] = evlib#stdtype#ExtendInOrderOrGetRef(
		"-? prev: v3: 			\		[
		"-? prev: v3: 			\			l:wrapped_args_list[ l:wrapped_argidx ],
		"-? prev: v3: 			\			(	( type( l:varname_suff ) == type( l:null_list ) )
		"-? prev: v3: 			\				?	l:varname_suff
		"-? prev: v3: 			\				:	l:null_list
		"-? prev: v3: 			\			),
		"-? prev: v3: 			\			"-? get( b:, l:varname_now, l:null_list ),
		"-? prev: v3: 			\			"-? get( g:, l:varname_now, l:null_list ),
		"-? prev: v3: 			\		]
		"-? prev: v3: 			\	)
		let l:wrapped_args_list[ l:wrapped_argidx ] = evlib#stdtype#ExtendInOrderOrGetRef(
					\		[
					\			l:wrapped_args_list[ l:wrapped_argidx ],
					\		]
					\			+
					\			(	( type( l:varname_suff ) == type( l:null_list ) )
					\				?	[ l:varname_suff ]
					\				:	[
					\						get( b:, l:varname_now, l:null_list ),
					\						get( g:, l:varname_now, l:null_list ),
					\					]
					\			)
					\	)
		unlet! l:varname_suff l:varname_now
	endfor
	return call( 'evplg#snippets#scope#vim#bufexpr_to_symbol', l:wrapped_args_list )
endfunction

"+/-? ... function! evplg#snippets#scope#vim#get_include_guard_symbol() abort
"+/-? ... 	return evplg#snippets#scope#vim#bufexpr_to_symbol(
"+/-? ... 				\		'%',
"+/-? ... 				\		[],
"+/-? ... 				\	)
"+/-? ... endfunction
"+ prev: v1: function! evplg#snippets#scope#vim#get_include_guard_symbol() abort
function! evplg#snippets#scope#vim#get_symbol_base_for_buffer() abort
	return evplg#snippets#scope#vim#bufexpr_to_symbol_wrapper()
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

" restore old "compatibility" options {{{
let &cpo=s:cpo_save
unlet s:cpo_save
" }}}

" vim600: set filetype=vim fileformat=unix:
" vim: set noexpandtab:
" vi: set autoindent tabstop=4 shiftwidth=4:
