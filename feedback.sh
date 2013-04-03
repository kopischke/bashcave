# First, call:
#
#     feedback --start [encoding]
#
# then, for every item repeat:
#
#     feedback title [--subtitle=subtitle] [--uid=uid] [--action=action] [--valid]
#			     	 [--completion=completion] [--icon=icon] [--fileicon|--filetype]
# finally, call:
#
#     feedback --end
#
function feedback {
	case "$1" in
	  --start) # start of XML output
	  	echo '<?xml version="1.0" encoding="'${2:-UTF-8}'"?>'
	  	echo '<items>'
	  	;;
	  --end)   # end of XML output
	  	echo '</items>'
		;;
	  ?*)      # any other string: item XML output
		local title="$1"; shift # item title (mandatory)
		local subtitle=''       # item subtitle
		local uid='default'     # item uid attribute; you should really set this one!
		local action=''         # item arg attribute
		local valid='no'        # item valid attribute
		local completion=''     # item autocomplete attribute
		local icon=''           # item icon path or file type ID
		local icon_type=''      # icon type attribute

	  	while (( $# > 0 )); do
		  	case "$1" in
		  	  --uid=*|--action=*|--completion=*|--subtitle=*|--icon=*)
		  	  	# parse --arg='values' into variable $arg set to 'values'
		  	  	argname="${1#--}"; argname="${argname%%=*}"
		  	  	eval "$argname='${1#*=}'"
		  	  	;;
		  	  --valid)
		  	  	valid='yes'
		  	  	;;
		  	  --fileicon|--filetype)
		  	  	icon_type="${1#--}"
		  	  	;;
		  	esac
		  	shift
		done
		[[ -n "$icon_type" ]]  &&  icon_type=' type="'"$icon_type"'"'
		[[ -n "$completion" ]] && completion=' autocomplete="'"$completion"'"'
		
		# always use CDATA tags for node content
		echo '<item uid="'"$uid"'" arg="'"$action"'" valid="'$valid'"'"$completion"'>'
		echo '<title><![CDATA['"$title"']]></title>'
		[[ -n "$subtitle" ]] && echo '<subtitle><![CDATA['"$subtitle"']]></subtitle>'
		[[ -n "$icon" ]] && echo '<icon'"$icon_type"'><![CDATA['"$icon"']]></icon>'
		echo '</item>'
		;;
	  *)
	  	return 1;
	  	;;
	esac
}
