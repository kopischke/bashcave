# STRING LIBRARY: REGEXES AND EXPANSIONS, SHAKEN, NOT STIRRED
# Returns 0 if REGEX matches WORD, 1 if not.
# Usage: match [--case|--no-case] REGEX WORD
#        --case     perform case sensitive matching
#        --no-case  perform case insenstive matching
# If no case flag is passed, the current nocasematch setting applies.
# Match results can be retrieved from BASH_REMATCH.
function match {
	local casematch=$(shopt -p nocasematch)
	case "$1" in
	  --case)
		shopt -u nocasematch
		shift ;;
	  --no-case)
		shopt -s nocasematch
		shift ;;
	  *)
	  	casematch='' ;;
	esac

	local regex="$1"
	local retval=0
	[[ $2 =~ $regex ]] || retval=$?
	[[ -n "$casematch" ]] && $casematch
	return $retval
}; export -f match

# Returns 0 if all characters of WORD are in CLASS, 1 if not.
# Usage: is_in_class [--case|--no-case] CLASS WORD
#        --case     perform case sensitive matching
#        --no-case  perform case insenstive matching
# CLASS needs to be a POSIX character class or character range (i.e. [:upper:] or [a-z]).
function is_in_class {
	local flags=()
	local flag_regex='^--[^-]+'
	while [[ $1 =~ $flag_regex ]]; do flags+=("$1"); shift; done
	[[ -z "$2" ]] || match "${flags[@]}" "[^$1]" "$2" && return 1
	true
}; export -f is_in_class

# Returns 0 if all characters of WORD are in the 7 bit ASCII range, 1 if not.
# Usage: is_7_bit WORD
function is_7bit {
	local LC_ALL='C' # avoid printing char collation
	is_in_class '[ -~]' "$1"
}; export -f is_7_bit

# Returns 0 if WORD is blank (empyt or consisting of whitespace), 1 if not.
# Usage: is_blank WORD
function is_blank {
	[[ -z "$1" ]] || is_in_class '[:blank:]' "$1"
}; export -f is_blank

# Returns 0 if all characters of WORD are upper case, 1 if not.
# Usage: is_upper WORD
function is_upper {
	is_in_class --case '[:upper:]' "$1"
}; export -f is_upper

# Returns 0 if all characters of WORD are lower case, 1 if not.
# Usage: is_lower WORD
function is_lower {
	is_in_class --case '[:lower:]' "$1"
}; export -f is_lower

# Returns 0 if WORD is all alphabetic characters in mixed case,
# but neither all upper case, nor all lower case; 1 if not.
# Usage: is_mixed WORD
function is_mixed {
	(( ${#1} > 1 )) && match '[:alpha:]' && ! is_upper "$1" && ! is_lower "$1"
}; export -f is_mixed

# Returns 0 if WORD's first character is upper case, all other lower case; 1 if not.
# Usage: is_capitalized WORD
function is_capitalized {
	is_upper "${1:0:1}" && is_lower "${1:1}"
}; export -f is_capitalized

# Echoes WORD to stdout without any leading or trailing charaters matching pattern.
# Usage: trim [--left|--right] WORD [pattern]
#        --left  only trim leading chars to trim (alias: --leading)
#        --right only trim trailing chars to trim (alias: --trailing)
# The characters to trim pattern must consist of one or more POSIX character
# classes and / or character ranges. If not pattern argument is passed,
# the POSIX class [:whitespace:] is trimmed.
function trim {
	case "$1" in
	  --left|--leading)
		local to_trim="${3:-[:space:]}"
		match "[^$to_trim].*$" "$2" && echo "${BASH_REMATCH[0]}" ;;
	  --right|--trailing)
		local to_trim="${3:-[:space:]}"
		match "^.*[^$to_trim]" "$2" && echo "${BASH_REMATCH[0]}" ;;
	  ?*)
		local to_trim="${2:-[:space:]}"
		match "[^$to_trim](.*[^$to_trim])?" "$1" && echo "${BASH_REMATCH[0]}" ;;
	  *)
		return 1 ;;
	esac
}; export -f trim

function ltrim { trim --left "$@" ;  }; export -f ltrim
function rtrim { trim --right "$@" ; }; export -f rtrim
