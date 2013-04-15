# IO.SH LIBRARY: HANDLE FILES ELEGANTLY
# Echoes the contents of a file to stdout.
function cheetah { # a faster cat ... for short bursts
	[[ -f "$1" && -r "$1" ]] || return 1
	while read -r || [[ -n "$REPLY" ]]; do echo "$REPLY"; done < "$1"
}
