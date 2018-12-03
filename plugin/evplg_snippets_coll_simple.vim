
if exists('g:loaded_evplg_snippets_coll_simple_plugin_evplg_snippets_coll_simple_vim') || &cp || version < 700
	finish
endif
let g:loaded_evplg_snippets_coll_simple_plugin_evplg_snippets_coll_simple_vim = 1

let s:plugin_snipmate_loaded = ( exists( ':SnipMateLoadScope' ) == 2 )
let s:plugin_ultisnips_loaded = ( exists( ':UltiSnipsEdit' ) == 2 )

" make sure we do nothing if none of the appopriate plugins are not currently installed/loaded.
if ( !( s:plugin_ultisnips_loaded || s:plugin_snipmate_loaded ) )
	finish
endif

" force "compatibility" mode {{{
if &cp | set nocp | endif
" set standard compatibility options ("Vim" standard)
let s:cpo_save=&cpo
set cpo&vim
" }}}

" MAYBE: fill in later?
let s:plugin_this_rootdir = fnamemodify( expand( '<sfile>' ), ':p:h:h' )

let s:dirs_suff = []
for [ s:cond_now, s:dirs_now ] in [
			\		[
			\			( s:plugin_snipmate_loaded || s:plugin_ultisnips_loaded ),
			\			[
			\				'snipmate-compat',
			\			],
			\		],
			\		[
			\			s:plugin_snipmate_loaded,
			\			[
			\				'snipmate',
			\			],
			\		],
			\		[
			\			s:plugin_ultisnips_loaded,
			\			[
			\				'ultisnips',
			\			],
			\		],
			\	]
	if ( ! s:cond_now ) | continue | endif
	let s:dirs_suff += s:dirs_now
endfor

" TODO: do this somewhere else (possibly in 'vim.evplg.snippets.baselib/plugin/*.vim'), and add every directory that exists and matches each of the patterns
"  IDEA: use 'evlib' (if possible) to do the "append to the end" on the
"  runtime directory elements (so that duplicates are avoided, and the paths
"  are added all at the end, as intended).
for s:dir_now in map( copy( s:dirs_suff ), 'printf(''%s/snippetdirs/%s'', s:plugin_this_rootdir, v:val)' )
	execute 'set runtimepath+=' . evlib#compat#fnameescape( s:dir_now )
endfor

" restore old "compatibility" options {{{
let &cpo=s:cpo_save
unlet s:cpo_save
" }}}

" vim600: set filetype=vim fileformat=unix:
" vim: set noexpandtab:
" vi: set autoindent tabstop=4 shiftwidth=4:
