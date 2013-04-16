# IO.SH LIBRARY: HANDLE FILES ELEGANTLY
# Echoes the contents of FILE to stdout.
# Usage: cheetah FILE
#
# NB: cheetah is faster than cat for small files, but slower for very large ones,
# hence its name: a faster cat ... on short ranges.
function cheetah {
	while read -r || [[ -n "$REPLY" ]]; do echo "$REPLY"; done < "$1"
}
