function get_global_locale {
	defaults read .GlobalPreferences AppleLocale 2>/dev/null
}

function get_locale {
	local locale
	# get cached value if requested and present
	[[ $1 == '--cached' && -f "$2" ]] && locale=$(while read -r; do echo "$REPLY"; break; done < "$2")
	# get the defaults value if there is no cached value present, or if none has been requested
	[[ -z "$locale" ]] && locale=$(get_global_locale)
	# asynchronously refresh cache (if requested)
	[[ $1 == '--cached' ]] && { { mkdir -p "${2%/*}"; get_global_locale > "$2"; } & disown; }
	echo "$locale"
}
