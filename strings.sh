function is_in_class {
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
	
	local regex="[^$1]"
	local retval=0
	[[ -z "$2" || $2 =~ $regex ]] && retval=1
	[[ -n "$casematch" ]] && $casematch
	return $retval
}

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
	[[ $2 =~ $regex ]] && echo "${BASH_REMATCH[0]}" || retval=$?
	[[ -n "$casematch" ]] && $casematch
	return $retval
}

function is_7bit {
	local LC_ALL='C' # avoid printing char collation
	is_in_class '[:cntrl:][:space:][:print:]' "$1"
}

function is_blank {
	[[ -z "$1" ]] || is_in_class '[:blank:]' "$1"
}

function is_upper {
	is_in_class --case '[:upper:]' "$1"
}

function is_lower {
	is_in_class --case '[:lower:]' "$1"
}

function is_mixed {
	(( ${#1} > 1 )) && ! is_upper "$1" && ! is_lower "$1"
}

function is_title {
	is_upper "${1:0:1}" && is_lower "${1:1}"
}

function utf8_normalize {
	echo "$1" | iconv -s -f UTF-8-Mac -t UTF-8
}

function ltrim {
	local to_trim="${2:-[:space:]}"
	match "[^$to_trim].*$" "$1"
}

function rtrim {
	local to_trim="${2:-[:space:]}"
	match "^.*[^$to_trim]" "$1"
}

function trim {
	local to_trim="${2:-[:space:]}"
	match "[^$to_trim](.*[^$to_trim])?" "$1"
}
