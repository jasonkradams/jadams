# Author: Jason Adams - j.adams@f5.com
# Create a datagroup with a list of Client IP Addresses.
# For this scenario, we also created a custom SNATPool with a single unique IP address so we
# could run a tcpdump on the serverside and listen only to that SNATPool IP address.
# This allowed us to only capture the clientside traffic we were interested in.

when CLIENT_ACCEPTED {
	# If the Clients' IP address is listed in the datagroup "client_addr",
	# then proceed to apply the custom changes.
	if { [ class match [IP::client_addr] equals test_10.16.205.50_class ] } {
		# Log to /var/log/ltm that we are assigning "client_addr" to our custom SNATPool
		log local0. "Setting [IP::client_addr] SNATPool to Test_10.16.205.50"
		snatpool Test_10.16.205.50
	}
}
when SERVER_CONNECTED {
	# If the Clients' IP address is listed in the datagroup "client_addr",
	# then proceed to apply the custom changes.
	if { [ class match [IP::client_addr] equals test_10.16.205.50_class ] } {
		# Log to /var/log/ltm that we are setting a custom TCP Idle timeout to 7200 seconds for "client_addr"
		log local0. "Setting [IP::client_addr] Idle Timeout from [IP::idle_timeout] to 7200"
		IP::idle_timeout 7200
	}
}