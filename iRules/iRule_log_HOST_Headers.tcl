# Created By: Jason Adams
# Date: 01/28/2014
# This rule is designed to log the Host header, if there is one.
when HTTP_REQUEST {
	if { [HTTP::header exists Host] } {
		set HOST_HEADER [HTTP::header Host]
	}
	else {
		log local0.info "We did not see HOST Header"
	}
}

when SERVER_CONNECTED {
	log local0.info "Client [IP::client_addr] has HTTP Host Header value of $HOST_HEADER and SNAT IP Address of [IP::local_addr]:[TCP::local_port]"
}