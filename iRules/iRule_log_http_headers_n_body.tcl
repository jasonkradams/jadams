# Author: Jason Adams
# Date  : 2017-04-26
# Credit: https://devcentral.f5.com/wiki/iRules.log.ashx
# Credit: https://devcentral.f5.com/wiki/iRules.http__collect.ashx
# NOTE: Log output will be URI Encoded with the [URI::encode] command.
# I use this site to decode the output: http://www.asciitohex.com/

when RULE_INIT {

	# Informational Logging
	set static::payload_debug 0

	# Payload Local Logging
	set static::logPayload 1

	# Max characters to log locally (must be less than 1024 bytes)
	# https://devcentral.f5.com/wiki/iRules.log.ashx
	set static::max_chars 900

	# MATCH ONLY THESE REQUESTS:
	# What HTTP::path do you want to log?
	set static::pathMatch "/"

}

when HTTP_REQUEST {
	set RUN 0
	
	# If you want to match everything, remove this if statment.
	# WARNING: There may be a large number of logs.

	if { "[HTTP::path]" equals "$static::pathMatch" } {
		set RUN 1
		# Prevent the server from sending a compressed response
		# remove the compression offerings from the client
		HTTP::header remove "Accept-Encoding"

		# Don't allow response data to be chunked
		if { [HTTP::version] eq "1.1" } {

			# Force downgrade to HTTP 1.0, but still allow keep-alive connections.
			# Since HTTP 1.1 is keep-alive by default, and 1.0 isn't,
			# we need make sure the headers reflect the keep-alive status.

			# Check if this is a keep alive connection
			if { [HTTP::header is_keepalive] } {

				# Replace the connection header value with "Keep-Alive"
				HTTP::header replace "Connection" "Keep-Alive"
			}

			# Set server side request version to 1.0
			# This forces the server to respond without chunking
			HTTP::version "1.0"
		}

		set LogString "Client [IP::client_addr]:[TCP::client_port] -> [HTTP::host][HTTP::uri]"
		if {$static::payload_debug}{
			log local0.debug "============================================="
			log local0.debug "$LogString (request)"
		}

		# log each Header.
		foreach aHeader [HTTP::header names] {
			if {$static::payload_debug}{log local0.debug "$aHeader: [HTTP::header value $aHeader]"}

		}
		if {$static::payload_debug}{log local0.debug "============================================="}

		switch -glob -- "[HTTP::header Content-Type]" {

			"*image*" -
			"*png*" {return}
			default {

				if {[HTTP::header "Content-Length"] ne "" && [HTTP::header "Content-Length"] <= 1048000} {
					HTTP::collect [HTTP::header "Content-Length"]
				} else {
					HTTP::collect 1048000
				}
			}
		}
	}
}

when HTTP_REQUEST_DATA {

	if {$RUN} {

		# Log the bytes collected
		if {$static::payload_debug}{log local0.debug "Collected [HTTP::payload length] bytes"}	

		# Log the payload locally
		if {[HTTP::payload length] < $static::max_chars}{
			if {$static::logPayload}{log local0.debug "Payload=[HTTP::payload]"}
		} else {

			# Initialize variables
			set chunk 1
			set start 0
			set end 0
			set remaining [expr {[HTTP::payload length] -1}]
			set bytes_logged 0

			# Loop through and log each chunk of the payload
			if {$static::payload_debug}{log local0.debug "remaining=$remaining, static_max_chars=$static::max_chars"}
			while {$remaining > $static::max_chars}{

				# Get the end chunk to log (subtract 1 from the end as string range is 0 indexed)
				if {$static::payload_debug}{log local0.debug "start + static::max_chars -1 == [expr {$start + $static::max_chars -1}]"}
				set end [expr {$start + $static::max_chars}]

				if {$static::payload_debug}{log local0.debug "chunk $chunk=$end"}

				# Log the chunk of HTTP Payload locally.
				if {$static::logPayload}{log local0.debug "${chunk}\t[b64encode [string range "[HTTP::payload]" $start $end]]"}

				# Add the length of the end chunk to the start for the next chunk
				# incr start $static::max_chars
				set start [expr {$end + 1}]

				# Get the next chunk to log
				set remaining [expr {$remaining - $static::max_chars}]
				incr chunk
				incr bytes_logged $static::max_chars
				if {$static::payload_debug}{log local0.debug "remaining bytes=$remaining, \$start=$start, \$chunk=$chunk, \$bytes_logged=$bytes_logged"}
			}
			if {$remaining < $static::max_chars}{
				set end [HTTP::payload length]

				# Log the chunk of HTTP Payload locally.
				if {$static::logPayload}{log local0.debug "${chunk}\t[b64encode [string range "[HTTP::payload]" $start $end]]"}

				if {$static::payload_debug}{log local0.debug "chunk $chunk=$end"}
				incr bytes_logged $remaining
			}
			if {$static::payload_debug}{log local0.debug "Logged $chunk chunks for a total of $bytes_logged bytes"}
		}
	}

}

when HTTP_RESPONSE {

	if {$RUN} {
		# Log the response headers.
		if {$static::payload_debug}{
			log local0.debug "============================================="
			log local0.debug "$LogString (response ss)"
		}
		# log each Header.
		foreach aHeader [HTTP::header names] {
			if {$static::payload_debug}{log local0.debug "$aHeader: [HTTP::header value $aHeader]"}

		}
		if {$static::payload_debug}{log local0.debug "============================================="}

		switch -glob -- "[HTTP::header Content-Type]" {

			"*image*" -
			"*png*" {return}
			default {

				if {[HTTP::header "Content-Length"] ne "" && [HTTP::header "Content-Length"] <= 1048000} {
					HTTP::collect [HTTP::header "Content-Length"]
				} else {
					HTTP::collect 1048000
				}
			}
		}
	}
}

when HTTP_RESPONSE_DATA {

	if {$RUN} {

		# Log the bytes collected
		if {$static::payload_debug}{log local0.debug "Collected [HTTP::payload length] bytes"}	

		# Log the payload locally
		if {[HTTP::payload length] < $static::max_chars}{
			if {$static::logPayload}{log local0.debug "Payload=[HTTP::payload]"}
		} else {

			# Initialize variables
			set chunk 1
			set start 0
			set end 0
			set remaining [expr {[HTTP::payload length] -1}]
			set bytes_logged 0

			# Loop through and log each chunk of the payload
			if {$static::payload_debug}{log local0.debug "remaining=$remaining, static_max_chars=$static::max_chars"}
			while {$remaining > $static::max_chars}{

				# Get the end chunk to log (subtract 1 from the end as string range is 0 indexed)
				if {$static::payload_debug}{log local0.debug "start + static::max_chars -1 == [expr {$start + $static::max_chars -1}]"}
				set end [expr {$start + $static::max_chars}]

				if {$static::payload_debug}{log local0.debug "chunk $chunk=$end"}

				# Log the chunk of HTTP Payload locally.
				if {$static::logPayload}{log local0.debug "${chunk}\t[URI::encode [string range "[HTTP::payload]" $start $end]]"}

				# Add the length of the end chunk to the start for the next chunk
				# incr start $static::max_chars
				set start [expr {$end + 1}]

				# Get the next chunk to log
				set remaining [expr {$remaining - $static::max_chars}]
				incr chunk
				incr bytes_logged $static::max_chars
				if {$static::payload_debug}{log local0.debug "remaining bytes=$remaining, \$start=$start, \$chunk=$chunk, \$bytes_logged=$bytes_logged"}
			}
			if {$remaining < $static::max_chars}{
				set end [HTTP::payload length]

				# Log the chunk of HTTP Payload locally.
				if {$static::logPayload}{log local0.debug "${chunk}\t[URI::encode [string range "[HTTP::payload]" $start $end]]"}

				if {$static::payload_debug}{log local0.debug "chunk $chunk=$end"}
				incr bytes_logged $remaining
			}
			if {$static::payload_debug}{log local0.debug "Logged $chunk chunks for a total of $bytes_logged bytes"}
		}
	}
}
