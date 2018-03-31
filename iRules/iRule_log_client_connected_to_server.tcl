# Created 12/17/2013 by Jason Adams -- F5 Network Support Engineer II
# This iRule will log the that the ClientIP:Ephemeral has been attached to Member:DestPort
when SERVER_CONNECTED  {
	set clientip "1.2.3.4"
	if {[IP::client_addr] equals $clientip } {
		log local0.info "Client Connected from [IP::client_addr]:[TCP::client_port] to Pool Member [IP::server_addr]:[TCP::remote_port]"
	}
}

when HTTP_RESPONSE {
	if {[IP::client_addr] equals $clientip } {		
		log local0.info "Response code [HTTP::status] from [IP::server_addr]:[serverside {TCP::remote_port}]"
	}
}