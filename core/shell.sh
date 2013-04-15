# SHELL LIBRARY: NOT JUST FOR TURTLES
# Return 0 if the current shell is of the specified type, 1 if not.
function shell_remote  { [[ -n $SSH_TTY ]] ; }; export -f shell_remote
function shell_local      { ! shell_remote ; }; export -f shell_local
function shell_interactive { [[ -n $PS1 ]] ; }; export -f shell_interactive

# Return 0 if the currently ecxectuing script is of teh specified type, 1 if not.
function script_sourced { [[ ${BASH_SOURCE[0]} != "$0" ]] ; }; export -f script_sourced
function script_called  { ! script_sourced ; }; export -f script_called


# Returns 0 if a command is found in the current environment, 1 if not.
# Specifying a type argument restricts the match to the indicated type, i.e.
# --alias     a shell alias
# --builtin   a shell builtin command
# --command   an executable file in the path (alias: --file)
# --function  a shell function
function isdefined  {
	case "$1" in
	  --alias|--builtin|--file|--function)
		[[ $(type -t "$2") == ${1#--} ]] ;;
	  --command)
		[[ $(type -t "$2") == 'file' ]] ;;
	  ?*)
		return 1 ;;
	  *)
		type -t "$1" &>/dev/null ;;
	esac
}
function isalias    { isdefined --alias    "$1" ; }; export -f isalias
function isbuiltin  { isdefined --builtin  "$1" ; }; export -f isbuiltin
function iscommand  { isdefined --command  "$1" ; }; export -f iscommand
function isfunction { isdefined --function "$1" ; }; export -f isfunction

# Run a command only when it is defined.
# Specifying a type argument restricts the match to the indicated type, i.e.
# --alias     a shell alias
# --builtin   a shell builtin command
# --command   an executable file in the path (alias: --file)
# --function  a shell function
function run {
	case "$1" in
	  --alias|--builtin|--commabnd|--file|--function)
		isdefined "${@:1:2}" && "${@:2}" ;;
	  ?*)
	  	return 1 ;;
	  *)
	  	isdefined "$1" && "$1" ;;
	esac
}; export -f run
function runalias    { run --alias    "$1" ; }; export -f runalias
function runbuiltin  { run --builtin  "$1" ; }; export -f runbuiltin
function runcommand  { run --command  "$1" ; }; export -f runcommand
function runfunction { run --function "$1" ; }; export -f runfunction

# Echoes the full path to the first executable NAME found in path to stdout.
# Usage: whoom [-a|--all|-s|--silent] NAME
#        -a|--all     echo the paths to all found exectubales, one per line
#        -s|--silent  do not echo anything, only return 0 if a match is found
# whoom is a drop-in replacement for BSD which and can be aliased to it.
function whoom { # the sound a faster which makes
	case "$1" in
	  -a|--all)
		type -aP "$2" ;;
	  -s|--silent)
		type -P "$2" >/dev/null ;;
	  ?*)
		type -P "$1" ;;
	  *)
		return 1 ;;
	esac
}; export -f whoom
