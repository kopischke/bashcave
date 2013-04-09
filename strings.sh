function is_in_class {
	local regex="[^$1]"
	[[ $2 =~ $regex ]] && return 1 || return 0
}

function is_7bit {
	local LC_ALL='C' # avoid printing char collation
	is_in_class '[:cntrl:][:space:][:print:]' "$1"
}

function is_blank {
	is_in_class '[:blank:]' "$1"
}

function is_upper {
	is_in_class '[:upper:]' "$1"
}

function is_lower {
	is_in_class '[:lower:]' "$1"
}

function is_mixed {
	! is_upper "$1" && ! is_lower "$1"
}

function is_title {
	is_upper "${1:0:1}" && is_lower "${1:1}"
}

function utf8_normalize {
	echo "$1" | iconv -s -f UTF-8-Mac -t UTF-8
}

function match {
	local regex="$1"
	[[ $2 =~ $regex ]] && echo "${BASH_REMATCH[0]}"
}

function ltrim {
	echo "$(match '[^[:space:]].*' "$1")"
}

function rtrim {
	echo "$(match '[^[:space:]].*$' "$1")"
}

function trim {
	echo "$(match '[^[:space:]](.*[^[:space:]])?' "$1")"
}
