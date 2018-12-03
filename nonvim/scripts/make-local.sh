#!/usr/bin/env sh
#
# test invocations:
#  :wa | !% --print-data-base --debug 2>&1 | less
#
set -e
prgname="${0##*/}"

f_abort()
{
	echo "${prgname}: ERROR:" "$@" "-- aborting" 2>&1
	exit 1
}

unset -v g_cmd_make
: "${g_cmd_make:=${EVPLG_SNIPPETS_CMD_MAKE}}"
[ -n "${g_cmd_make}" ] || g_cmd_make=`which gnumake gmake make 2> /dev/null | head -n 1`
[ -n "${g_cmd_make}" -a -x "${g_cmd_make}" ] || f_abort "could not find a suitable make program"

unset -v g_rootdir
g_rootdir="${0%/nonvim/*}"
[ -n "${g_rootdir}" ] \
	|| f_abort "could not calculate the root directory for this project"
[ -d "${g_rootdir}/" -a -d "${g_rootdir}/snippetdirs/" ] \
	|| f_abort "calculated root dir '${g_rootdir}' has failed validation"
# get the absolute path, so nothing can go wrong (even passing '-C another_dir')
g_rootdir=`cd "${g_rootdir}" && pwd`

# TODO: pass other variables to the makefile
EVPLG_SNIPPETS_PRJ_LOCAL_ROOTDIR="${g_rootdir}"
export EVPLG_SNIPPETS_PRJ_LOCAL_ROOTDIR
exec "${g_cmd_make}" "$@"

