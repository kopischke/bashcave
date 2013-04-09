function get_global_locale {
	defaults read .GlobalPreferences AppleLocale 2>/dev/null
}

function get_locale {
	local locale
	# get cached value if requested and present, refresh asynchronously
	if [[ $1 == '--cached' ]]; then
		[[ -f "$2" ]] && locale=$(while read -r; do echo "$REPLY"; break; done < "$2")
		{ { mkdir -p "${2%/*}"; get_global_locale > "$2"; } & disown; } 2>/dev/null
	fi
	# get the defaults value otherwise
	[[ -n "$locale" ]] && echo "$locale" || get_global_locale
}
