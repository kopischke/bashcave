# OS X PLATFORM LIBRARY: JUST BASHES
# Echoes the value of KEY of preferences DOMAIN to stdout.
# Usage: preferences [--cached cache] DOMAIN KEY
#        --cached  cache value to cache, read it from there if present
function preferences { # one step beyond defaults
	require --from 'core/io' 'cheetah' || return 1
	local pref
	# get cached value if requested and present, refresh asynchronously
	if [[ $1 == '--cached' ]]; then
		[[ -z "$2" ]] && return 1
		[[ -f "$2" ]] && pref="$(cheetah "$2")"
		{ { mkdir -p "${2%/*}";
			defaults read "$3" "$4" > "$2"; } &
			disown;
		} 2>/dev/null
		shift 2
	fi
	# get the defaults value otherwise
	[[ -n "$pref" ]] && echo "$pref" || defaults read "$1" "$2"
}; export -f preferences

# Echoes WORD to stdout after transcoding it from UTF-8-Mac to UTF-8.
# Usage: utf8_normalize WORD
function utf8_normalize {
	echo "$1" | iconv -s -f UTF-8-Mac -t UTF-8
}; export -f utf8_normalize

# Echoes the user's locale as set in OS X global preferences to stdout.
# Usage: osx_locale
function osx_locale {
	preferences "$@" .GlobalPreferences AppleLocale 2>/dev/null
}; export -f osx_locale

# Echoes the path of the Library folder to stdout.
# Usage: library_dir [--user|--shared|--system]
#        --user    the current user's Library folder
#        --shared  the OS' shared Library folder
#        --system  the OS' private Library folder
# with no argument, '--user' is implied.
function library_dir {
	case "$1" in
	  --user)
		echo "$HOME"/Library ;;
	  --shared)
		echo /Library ;;
	  --system)
		echo /System/Library ;;
	  --?*)
	  	return 1 ;;
	  --*)
		echo "$HOME"/Library ;;
	esac
}; export -f library_dir

# Echoes the path of the Cache folder to stdout.
# Usage: cache_dir [--user|--shared|--system]
# The flags are used as in library_dir.
function cache_dir {
	echo "$(library_dir "$@")"/Caches
}; export -f cache_dir

# Echoes the path of the Preferences folder to stdout.
# Usage: prefs_dir [--user|--shared|--system]
# The flags are used as in library_dir.
function prefs_dir {
	echo "$(library_dir "$@")"/Preferences
}; export -f prefs_dir

# Echoes the path of the Appplication Support folder to stdout.
# Usage: app_support_dir [--user|--shared|--system]
# The flags are used as in library_dir.
function app_support_dir {
	echo "$(library_dir "$@")"/'Application Support'
}; export -f app_support_dir

function find_app {
	# TODO: implement
	:
}
