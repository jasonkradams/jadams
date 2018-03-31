# Created this iRule in response to SR C1414812
# It forces the VS to send a RST packet to the client if there are no available pool members.
# And log a message /var/log/ltm
# The client found that he was able to make telnet connections to his VS when it had no pool members,
# which was creating false positives with his monitoring tool (which creates a simple telnet connection)

when CLIENT_ACCEPTED {
	if { [active_members [LB::server pool]] == 0 } {
		reject
		log local0. "We have rejected [IP::client_addr]"
	}
}