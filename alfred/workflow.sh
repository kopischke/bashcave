# ALFRED WORKFLOW UTILITY LIBRARY: BASH CAN DO IT
# Setup a workflow for smooth sailing.
# Usage: workflow_init QUERY
# This does two things:
# 1. set the locale to be UTF-8 aware and export it as $WOKFLOW_LOCALE
# 2. normalize UTF-8 representation of QUERY and export it as $QUERY
function workflow_init {
	[[ -z "$1" ]] && return 1
	require --from 'platform/osx' 'osx_locale' 'utf8_normalize' || return 1

	# Ensure UTF-8 case awareness
	export WORKFLOW_LOCALE="$(osx_locale --cached "$(alfred_cache)"/.locale)"
	export LC_ALL="${WORKFLOW_LOCALE:-en_US}.UTF-8"

	# Normalize Unicode representation of non-ASCII characters in query
	is_7bit "$*" && QUERY=($@) || QUERY=($(utf8_normalize "$@"))
	export QUERY
}

# Echoes the path to the installed Alfred.app bundle to stdout.
# Usage: alfred_dir [--cache|--data]
#        --cache  echo Alfred's cache folder path to stdout.
#        --data   echo Alfred's data folder path to stdout.
function alfred_dir {
	case "$1" in
	  --cache)
		require --from 'platform/osx' 'cache_dir' || return 1
		echo "$(cache_dir)"/'com.runningwithcrayons.Alfred-2' ;;
	  --data)
	  	require --from 'platform/osx' 'app_support_dir' || return 1
	  	echo "$(app_support_dir)"/'com.runningwithcrayons.Alfred-2' ;;
	  ?*)
		return 1 ;;
	  *)
		require --from 'platform/osx' 'find_app' || return 1
		local found="$(find_app 'Alfred')" && echo "${found%/*}" ;;
	esac
}

# Aliases for retrieval of Alfred support folders.
function alfred_cache { alfred_dir --cache ; }; export -f alfred_cache
function alfred_data  { alfred_dir --data  ; }; export -f alfred_data

# Echoes the path to the running Alfred workflow to stdout.
# Usage: workflow_dir [--cache|--data]
#        --cache  echo the worklow cache folder path to stdout.
#        --data   echo the workflow data folder path to stdout.
function workflow_dir {
	case "$1" in
	  --cache|--data)
	 	echo "$(alfred_dir $1)/$(workflow_id)" ;;
	  ?*)
		return 1 ;;
	  *)
		[[ -n "$WORKFLOW_DIR" ]] && { echo "$WORKFLOW_DIR"; return 0; }
		require --from 'core/pathname' 'dir_name' 'ext_name' 'isdir'
		local dir="dir_name ${BASH_SOURCE[0]}"
		( shopt -s nocasematch
		  while isdir "$dir" && [[  "$(ext_name "$dir")" != 'alfredworkflow' ]]; do
		  	dir="$(dir_name "$dir")"
		  done
		  echo "$dir"
		) ;;
	esac
}

# Aliases for retrieval of workflow support folders.
function workflow_cache { workflow_dir --cache ; }; export -f workflow_cache
function workflow_data  { workflow_dir --data  ; }; export -f workflow_data

# Echoes workflow Info.plist KEY value to stdout.
# Usage: workflow_info [--known key] [KEY]
# Known key can be one of: id, name, description, author, link, readme.
function workflow_info {
	[[ -z "$1" ]] && return 1
	local key
	case "$1" in
	  --id)
		key='bundleid' ;;
	  --name|--description|--readme)
		key="${1#--}" ;;
	  --author)
		key='createdby' ;;
	  --link)
		key='webaddress' ;;
	  ?*)
		key="$1" ;;
	  *)
		return 1 ;;
	esac
	defaults read "$(workflow_dir)"/info.plist "$key"
}; export -f workflow_info
