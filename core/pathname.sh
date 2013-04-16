# PATHNAME LIBRARY: DIRNAME'S AND BASENAME'S COOL FRIENDS
# Return 0 if the given test condition is true for PATH, 1 if not.
# Usage: is{test} PATH
function isfsobject   { [[ -e "$1" ]] ; }; export -f isfsobject
function isfile       { [[ -f "$1" ]] ; }; export -f isfile
function isdir        { [[ -d "$1" ]] ; }; export -f isdir
function islink       { [[ -L "$1" ]] ; }; export -f islink
function isreadable   { [[ -r "$1" ]] ; }; export -f isreadable
function iswritable   { [[ -w "$1" ]] ; }; export -f iswritable
function isexecutable { [[ -x "$1" ]] ; }; export -f isexecutable

# Return 0 if PATH is a readable file, 1 if not.
function issourceable { isfile "$1" && isreadable "$1"   ; }; export -f issourceable

# Return 0 if PATH is a writable file, 1 if not.
function isrunnable   { isfile "$1" && isexecutable "$1" ; }; export -f isrunnable

# Return 0 if PATH is browsable (executable) directory, 1 if not.
function isbrowsable  { isdir  "$1" && isexecutable "$1" ; }; export -f isbrowsable

# Echoes the part of PATH after the last slash to stdout.
# Usage: base_name [--strict] PATH
#        --strict  echo only the file name part of PATH to stdout, or nothing
#                  if PATH is not an existing file.
# Returns 1 if --strict is passed for PATH that is not an existing file, else 0.
# base_name is a drop in replacement for the BSD basename utility and can be aliased to it.
function base_name {
	local strict=false
	[[ $1 == '--strict' ]] && strict=true && shift
	[[ -z "$1" ]] && return 1
	if isfile "$1" || ! $strict; then
		[[ $1 != "/" ]] && echo "${1##*/}" || echo "$1"
	else
		return 1
	fi
}; export -f base_name

# Alias for base_name --strict
function file_name { base_name --strict "$1" ; }; export -f filename

# Echoes the part PATH before the last slash to stdout.
# Usage: dir_name [--strict] PATH
#        --strict  echo PATH if it is to an existing directory, or
#                  echo the conatining fodirectory of PATH if it is to a file
#                  inside an existing directory, or nothing
# Returns 1 if --strict is passed for PATH that is not an existing directory,
# or a file inside an existing directory; else 0.
# dir_name is a drop in replacement for the BSD dirname utility and can be aliased to it.
function dir_name {
	local strict=false
	[[ $1 == '--strict' ]] && strict=true && shift
	[[ -z "$1" ]] && return 1
	[[ $1 == "/" ]] && echo "$1"
	if isdir "$1" && $strict; then
		echo "$1"
	elif isdir "${1%/*}" || ! $strict; then
		echo "${1%/*}"
	else
		return 1
	fi
}; export -f dir_name

# Alias for dir_name --strict
function dir_path { dir_name --strict "$1" ; }; export -f dir_path

# Echoes the part of PATH after the last period to stdout.
# Usage: ext_name [--strict] PATH
#        --strict  only echo the extension part if PATH is to an existing file.
# Returns 1 if --strict is passed and PATH is not to an existing file, else 0.
function ext_name {
	local strict=''
	[[ $1 == '--strict' ]] && strict=true && shift
	[[ -z "$1" ]] && return 1
	local base="$(base_name ${strict:+--strict }"$1")" || return 1
	[[ $base != "${base##?*.}" ]] && echo "${base##*.}" # bypass dot files
}; export -f ext_name

# Alias for ext_name --strict
function file_ext { extname --strict "$1" ; }; export -f fileext

# Echoes the base name of PATH without any extension to stdout.
# Usage: root_name [--strict] PATH
#        --strict  echo the root part only if PATH is to an existing file.
# Returns 1 if --strict is passed and PATH is not to an existing file, else 0.
function root_name {
	local strict=''
	[[ $1 == '--strict' ]] && strict=true && shift
	[[ -z "$1" ]] && return 1
	local base="$(base_name ${strict:+--strict }"$1")" || return 1
	local ext="$(ext_name ${strict:+--strict }"$1")" || return 1
	echo "${base%.$ext}"
}; export -f root_name

# Alias for rootname --strict
function file_root { rootname --strict "$1" ; }; export -f file_root

# Echoes the fully expanded version of PATH to stdout.
# Usage: path_name [--real] PATH
#        --real  resolve symlinks
function path_name {
	local path
	local file
	local target
	local real=false
	[[ $1 == '--real' ]] && real=true && shift
	[[ -n "$1" ]] && isfsobject "$1" && target="$1" || return 1
	if $real; then
		path="$(if islink "$target"; then
			# relative links only resolve correctly from their own dir
			path="$(dir_name --strict "$target")" && cd -P "$path" || return 1
			target="$(readlink "$target")" || return 1
		fi
		path="$(dir_name --strict "$target")" && cd -P "$path" || return 1
		pwd)"
		# make sure we target the real target file afterwards
		# (the reassigned target above does not carry over from the $() subshell)
		islink "$target" && target="$(readlink "$target")"
	else
		path="$(dir_name --strict "$target")" && path="$(cd -L "$path" && pwd)" || return 1
	fi
	file="$(base_name --strict "$target")"
	echo "$path${file:+/$file}"
}; export -f path_name

# Alias for pathname --real
function real_path { path_name --real "$1" ; }; export -f real_path

# Echoes the current volume device name, or that for file if given, to stdout.
# Usage: vol_name [file]
function vol_name {
	[[ -z "$1" || -e "$1" ]] || return 1
	local target="${1:-$PWD}"
	local disk_re='/dev/[^ ]+'
	[[ $(df "$target") =~ $disk_re ]] && echo "${BASH_REMATCH[0]}"
}; export -f vol_name
