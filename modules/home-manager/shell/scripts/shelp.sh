#!/bin/sh
#
# shelp — validate positional args against a spec and emit generated usage.
#
# Usage (from inside another script/function):
#   shelp [--name NAME] <"name|description"...> -- "$@" || exit 1
#
# Spec format: "name|description". A trailing "?" on the name marks it optional
# (shown in usage as [name], not counted toward the required minimum).
#
# Exit status: 0 if enough positional args were supplied, 1 otherwise.
# On failure, a usage block is printed to stderr:
#
#   usage: NAME <name> [ref]
#     name   worktree dir + branch suffix
#     ref    commit-ish to branch from
#
# Because a child process can't terminate its caller, the caller is responsible
# for acting on the exit status: `shelp ... -- "$@" || exit 1`.
 
set -eu
 
delim='|'
name=''
 
# name can be inferred by caller or explicitly set via --name or #2 arg
if [ "${1:-}" = "--name" ]; then
	name=$2
	shift 2
fi
if [ -z "$name" ]; then
	name=$(cat "/proc/$PPID/comm" 2>/dev/null || echo command)
fi
 
specs=''
usage=''
required=0
 
while [ "$#" -gt 0 ] && [ "$1" != "--" ]; do
	spec=$1
	argname=${spec%%"$delim"*}
	case "$argname" in
	*'?') usage="$usage [${argname%\?}]" ;;
	*)
		usage="$usage <$argname>"
		required=$((required + 1)) ;;
	esac
	specs="$specs$spec
"
	shift
done
[ "${1:-}" = "--" ] && shift
 
if [ "$#" -lt "$required" ]; then
	{
		printf 'usage: %s%s\n' "$name" "$usage"
		printf '%s' "$specs" | while IFS= read -r spec; do
			[ -n "$spec" ] || continue
			n=${spec%%"$delim"*}
			d=${spec#*"$delim"}
			printf '  %-12s %s\n' "${n%\?}" "$d"
		done
	} >&2
	exit 1
fi
 
exit 0
