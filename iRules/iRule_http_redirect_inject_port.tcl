# Created 1/7/2014 by Jason Adams -- F5 Network Support Engineer II
# This iRule is was created in response to SR C1493017.
# Customer problem description: Need to rewrite HTTP Redirect - HTTP Location Header - to include :XXXX Port designation.

when HTTP_REQUEST {
	set port [TCP::local_port]
}
when HTTP_RESPONSE {
	if { [HTTP::is_redirect] } {
#		log local0.debug "HTTP Location Header == [string tolower [HTTP::header Location]] "
#		log local0.debug "URI::host == [URI::host [HTTP::header Location]]"
#		log local0.debug "URI::port == [URI::port [HTTP::header Location]]"
#		log local0.debug "URI::basename == [URI::basename [HTTP::header Location]]"
#		log local0.debug "URI::path == [URI::path [HTTP::header Location]]"
#		log local0.debug "URI::protocol == [URI::protocol [HTTP::header Location]]"
#		log local0.debug "Rebuilt Location Header == [URI::protocol [HTTP::header Location]]://[URI::host [HTTP::header Location]]:$port[URI::path [HTTP::header Location]][URI::basename [HTTP::header Location]]"

		HTTP::header replace Location "[URI::protocol [HTTP::header Location]]://[URI::host [HTTP::header Location]]:$port[URI::path [HTTP::header Location]][URI::basename [HTTP::header Location]]"
	}
}