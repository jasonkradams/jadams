# Created By: Jason Adams
# Date: 11/21/2013
# This rule is designed to log the X-Forwarded-For header, if there is one.
when HTTP_REQUEST {
	if { [HTTP::header exists X-Forwarded-For] } {
	set XFF_HEADER [HTTP::header X-Forwarded-For]
	}
	else {
		log local0.info "We did not see XFF Header"
	}
}

when SERVER_CONNECTED {
	log local0.info "Client [IP::client_addr] has HTTP Header X-Forwared-For value of $XFF_HEADER and SNAT IP Address of [IP::local_addr]"
}