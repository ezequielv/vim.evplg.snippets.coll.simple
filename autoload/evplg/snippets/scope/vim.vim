
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

" prev: function! s:_get_cachedict_key()
" prev: 	return printf( '%s:%s', &filetype, &syntax )
" prev: endfunction
" prev: 
" prev: function! evplg#snippets#scope#vim#init_lazy()
" prev: 	let l:scope_cachedict_key = s:_get_cachedict_key()
" prev: 	if get( b:, 'evplg_snippets_current_cachedict_key', '' ) ==# l:scope_cachedict_key
" prev: 		return
" prev: 	endif
" prev: 	unlet! b:evplg_snippets_current_cachedict_key
" prev: 
" prev: 	" TODO: have a "changedtick"-sortof-based global definitions, which can be
" prev: 	" manually reset (and thus its "changedtick" would be increased, thus
" prev: 	" triggering refreshing from every buffer's snippets when those are used).
" prev: 	"
" prev: 	" TODO: move to another function (possibly 'evplg#snippets#baselib#*()') {{{
" prev: 	if ( ! exists( 'g:evplg_snippets_scopes_specdict' ) )
" prev: 		" TODO: implement registration?
" prev: 		let g:evplg_snippets_scopes_specdict = {}
" prev: 	endif
" prev: 	if ( ! exists( 'g:evplg_snippets_scopes_procdict' ) )
" prev: 		let g:evplg_snippets_scopes_procdict = {}
" prev: 	endif
" prev: 	if ( ! exists( 'b:evplg_snippets_scopes_cachedict' ) )
" prev: 		let b:evplg_snippets_scopes_cachedict = {}
" prev: 	endif
" prev: 	" }}}
" prev: 
" prev: 	" re-generate the entry in 'b:evplg_snippets_scopes_cachedict' if needed
" prev: 	if ( ! has_key( b:evplg_snippets_scopes_cachedict, l:scope_cachedict_key ) )
" prev: 		let l:runtime_spec_pref = 'evplg/snippets/init/scopes/'
" prev: 		let l:scopes_list = evlib#strset#AsList( evlib#strset#Add( evlib#strset#Create( split( l:scope_cachedict_key, '\W' ) ), [ 'all' ] ) )
" prev: 		" echomsg 'DEBUG: l:scopes_list=' . string( l:scopes_list )
" prev: 		for l:scope_now in l:scopes_list
" prev: 			if ! has_key( g:evplg_snippets_scopes_procdict, l:scope_now )
" prev: 				let g:evplg_snippets_scopes_procdict[ l:scope_now ] = {}
" prev: 			endif
" prev: 			let l:scope_procdict = g:evplg_snippets_scopes_procdict[ l:scope_now ]
" prev: 			if ( ! get( l:scope_procdict, 'done_runtime', 0 ) )
" prev: 				" do a 'runtime' on the appropriately named files:
" prev: 				"  (something like: runtime! evplg/snippets/scopes/SCOPE{[-_]*,}.vim)
" prev: 				" prev: \ 'evlib#compat#fnameescape( printf(''%s%s%s.vim'', l:runtime_spec_pref, l:scope_now, v:val ) )'
" prev: 				let l:runtime_specs_now = join(
" prev: 							\		map(
" prev: 							\				[
" prev: 							\					'',
" prev: 							\					'[-_]*',
" prev: 							\				],
" prev: 							\				'printf(''%s%s%s.vim'', l:runtime_spec_pref, l:scope_now, v:val )'
" prev: 							\			),
" prev: 							\		' '
" prev: 							\	)
" prev: 				try
" prev: 					" prev: " flag that this is done before actually doing it, so we cope
" prev: 					" prev: " with bad scripts/errors by not re-'runtime'-ing them
" prev: 					" prev: " repeteadly.
" prev: 					" prev: let l:scope_procdict[ 'done_runtime' ] = !0
" prev: 					" echomsg 'DEBUG: about to run runtime! ' . l:runtime_specs_now
" prev: 					execute 'runtime! ' . l:runtime_specs_now
" prev: 				catch
" prev: 					echomsg 'ERROR: lazy_init(): caught exception sourcing script. exception=' . string( v:exception ) . '; location=' . stirng( v:throwpoint )
" prev: 				finally
" prev: 					" flag the "scope" as having been dealt with, even when
" prev: 					" there was an error, so we avoid re-'runtime'-ing buggy
" prev: 					" or unlucky scripts repeatedly.
" prev: 					let l:scope_procdict[ 'done_runtime' ] = !0
" prev: 				endtry
" prev: 			endif
" prev: 		endfor
" prev: 
" prev: 		" now we make a new cache entry in b:evplg_snippets_scopes_cachedict,
" prev: 		" so that the 'init_functions' elements can use the (TODO: implement)
" prev: 		" functions that work on the current cache entry.
" prev: 		let b:evplg_snippets_scopes_cachedict[ l:scope_cachedict_key ] = {}
" prev: 		let b:evplg_snippets_current_cachedict_key = l:scope_cachedict_key
" prev: 
" prev: 		" call the 'init_functions' registered by the runtime scripts in the
" prev: 		" previous loop.
" prev: 		" prev: " FIXME: re-add later: for l:scope_now in l:scopes_list
" prev: 		" prev: for l:scope_now in [] " FIXME: code inside the 'for' disabled for now
" prev: 		for l:scope_now in l:scopes_list
" prev: 			" prev: " prev: if ! has_key( b:evplg_snippets_scopes_procdict, l:scope_now )
" prev: 			" prev: " prev: 	let b:evplg_snippets_scopes_procdict[ l:scope_now ] = {}
" prev: 			" prev: " prev: endif
" prev: 			" prev: " prev: let l:scope_procdict = b:evplg_snippets_scopes_procdict[ l:scope_now ]
" prev: 			let l:scope_procdict = g:evplg_snippets_scopes_procdict[ l:scope_now ]
" prev: 			" prev: " prev: if ( ! get( l:scope_procdict, 'done_init_functions', 0 ) )
" prev: 			" prev: " TODO: instead: if ( ! evplg#snippets#baselib#scopecache#get_cached_value( 'done_init_functions', 0 ) )
" prev: 			" prev: if ( ! evplg#snippets#baselib#scopecache#get_cached_value( '*done_init_functions', 0 ) )
" prev: 			if !0
" prev: 				" TODO: implement a priority-based list of 'init_functions',
" prev: 				" so that we can execute a final list with the priority being
" prev: 				" the primary key, and the relative order of "scopes" as a
" prev: 				" likely secondary order (or just define the order to be
" prev: 				" arbitrary between entries with the same priority).
" prev: 				"  IDEA: populate a list/dict/whatever with a priority, and
" prev: 				"  have a loop later to iterate through those
" prev: 				"   IDEA: have a priority-based collection (or a generically
" prev: 				"   sorted collection) in 'evlib'.
" prev: 				"   IDEA: or just add elements to a priority-keyed dict (where
" prev: 				"   each element is a list), and then write the resulting list
" prev: 				"   iterating in sorted key order.
" prev: 				"    IDEA: this can still be in evlib...
" prev: 				"     evlib#keyedmlist#Create()
" prev: 				"     evlib#keyedmlist#Add(keyedmlist, key, val) " to be used by 'registration' functions
" prev: 				"     evlib#keyedmlist#Extend(keyedmlist, srcdst, srctoadd) " to update the priority list for every scope in the loop
" prev: 				"     evlib#keyedmlist#GetFlat(keyedmlist, ... ) " opt: sortfunction (see ':h sort()') -- to get the final list of functions/funcrefs to call, in priority order
" prev: 				for l:buffer_init_func_orig in get( l:scope_procdict, 'init_functions', [] )
" prev: 					unlet! l:Buffer_init_func
" prev: 					let l:Buffer_init_func = l:buffer_init_func_orig
" prev: 					unlet l:buffer_init_func_orig
" prev: 					try
" prev: 						call call( l:Buffer_init_func, [ l:scope_now ] )
" prev: 					catch
" prev: 						echomsg 'ERROR: lazy_init(): caught exception executing initialisation function '
" prev: 									\	. string( l:Buffer_init_func )
" prev: 									\	'. exception=' . string( v:exception ) . '; location=' . string( v:throwpoint )
" prev: 					endtry
" prev: 				endfor
" prev: 				" prev: " prev: let l:scope_procdict[ 'done_init_functions' ] = !0
" prev: 				" prev: call evplg#snippets#baselib#scopecache#set_cached_value( '*done_init_functions', !0 )
" prev: 			endif
" prev: 		endfor
" prev: 		"? let l:specdict_now = l:scope_specdict[ l:scope_now ]
" prev: 		"? if ! has_key( l:scope_specdict, l:scope_now ) | continue | endif
" prev: 	endif
" prev: endfunction

" TODO: complete
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

" prev: " for now, each element's value matches its key, which is (by our convention)
" prev: " the "long" version.
" prev: let s:local_keywordflavours_dict_function_long = map(
" prev: 			\		deepcopy( s:local_keywordflavours_dict_function_short ),
" prev: 			\		'v:key'
" prev: 			\	)
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
	" prev: call extend(
	" prev: 			\		a:keywords_dict,
	" prev: 			\		s:local_keywordflavours_dict_function_short,
	" prev: 			\		"force"
	" prev: 			\	)
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
	" prev: call extend(
	" prev: 			\		a:keywords_dict,
	" prev: 			\		s:local_keywordflavours_dict_function_long,
	" prev: 			\		"force"
	" prev: 			\	)
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

" prev: " prev: let s:local_keyworddetection_search_function_regex = '\v^\s*<(fu%[nction])>'
" prev: let s:local_keyworddetection_search_function_regex = '\v^\s*<(fu%[nctio])|(function)>'
" TODO: let s:local_keyworddetection_search_others01_regex = '\v^\s*<(fu%[nction])>'

" prev: \			'regex': s:local_keyworddetection_search_function_regex,
let s:local_keyworddetection_proclist = [
			\		{
			\			'search_regex': '\v^\s*<%((fu%[nctio])|(function))>',
			\			'search_keywords_dict_map': {
			\					2: s:local_keywordflavours_dict_function_short,
			\					3: s:local_keywordflavours_dict_function_long,
			\				},
			\		},
			\		{
			\			'search_regex': '\v^\s*<%((%(en%[di])|%(el%[s])|elsei|endfo|%(con%[tinu])|brea|%(wh%[il])|%(endw%[hil]))|(endif|else|elseif|endfor|continue|break|while|endwhile))>',
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
			" prev: if has_key( l:proc_elem_now, 'keywords_dict_map' )
			" prev: 			\	&& has_key( l:proc_elem_now[ 'keywords_dict_map' ], l:subpattern_number )
			" prev: 	" ref: l:subpattern_number
			" prev: endif
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
	" prev: let l:keyword_dict_final = evplg#snippets#baselib#scopecache#get_cached_value( 'keyword_dict_final', s:local_any_def )
	" prev: if l:keyword_dict_final isnot s:local_any_def
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
	" prev: return a:keyword
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
