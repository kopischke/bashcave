# A REQUIRE SYSTEM FOR BASH FUNCTION LIBRARIES
# very loosely based on Ruby’s require command

# Set a path passed when sourced as $BASHCAVE_DIR
[[ -n "$1" ]] && export BASHCAVE_DIR="$1"

# Sources a bashcave library
# Usage: require LIBRARY
#        require --from LIBRARY function [function ... function]
# The first form sources LIBRARY if found in the bashcave.
# The second form sources LIBRARY (if found) only if at least one function is not defined.
# Returns 1 if sourcing fails or if the requested functions do not exist after sourcing, else 0.
#
# * bashcave will look for LIBRARY in $BASHCAVE_DIR, if defined, or in  its default directories
#   as well as in the directories listed in $BASHCAVE_PATH (if any) if not.
# * $BASHCAVE_DIR can be exported by passing it to bashcave.sh when sourcing.
# * LIBRARY has the canonical form 'module/name' (the '.sh' extension is optional).
#   If the module name is omitted, 'core' is assumed (i.e. 'require string' sources 'core/string').
function require {
	local path=''
	local paths=(/usr/share/bashcave)
	local lib=''
	local func=''
	local funcs=()
	local must_source=false

	# parse argument form
	if [[ $1 == '--from' ]] && (( $# > 2 )); then
		# request specific functions from a library
		lib="$2"
		funcs+=("${@:3}")
		# skip sourcing if the requested functions are present
		if (( ${#funcs[@]} > 0 )); then
			for func in "${funcs[@]}"; do
				[[ $(type -t "$func") == 'function' ]] || must_source=true
				$must_source && break
			done
		fi
		$must_source || return 0
	elif (( $# == 1 )); then
		# request a library without checking functions
		lib="$1"
	else
		return 1
	fi

	# sanitize library name (prevent directory traversal attacks)
	lib="${lib#~}";   lib="${lib#/}"                # strip absolute path elements
	lib="${lib#../}"; lib="${lib#./}"               # strip leading relative path elements
	lib="${lib//\/..\//\/}"; lib="${lib//\/.\//\/}" # strip inline relative path elements
	lib="${lib%/..}"; lib="${lib%/.}"               # strip trailing relative path elements
	
	# normalize library name
	[[ ${lib///} == "$lib" ]] && lib="core/$lib"    # assume core if module is missing
	lib="${lib%.sh}.sh"                             # ensure .sh extension
	
	# locate library path
	if [[ -d "$BASHCAVE_DIR" && -x "$BASHCAVE_DIR" ]]; then
		lib="$BASHCAVE_DIR/$lib"
		[[ -f "$lib" && -r "$lib" ]] && source "$lib" || return 1
	else # search BASHCAVE_PATH
		IFS=':' paths+=($BASHCAVE_PATH)
		for path in "${paths[@]}"; do
			lib="$path/$lib"
			[[ -f "$lib" && -r "$lib" ]] && source "$lib" && break || return 1
		done
	fi
	
	# check that the requested functions are present
	if (( ${#funcs[@]} > 0 )); then
		for func in "${funcs[@]}"; do
			[[ $(type -t "$func") == 'function' ]] || return 1
		done
	fi
}; export -f require
