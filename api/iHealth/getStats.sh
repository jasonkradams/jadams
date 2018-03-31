#!/bin/bash

getCommands () {

	tmctl_a="$(curl -H"Accept: application/vnd.f5.ihealth.api" --user-agent "MyGreatiHealthClient" --cookie cookiefile --cookie-jar cookiefile -o - https://ihealth-api.f5.com/qkview-analyzer/api/qkviews/${i}/commands/ec763272f520d0d2973ce7f371f89f0f7b1a2c05 2>/dev/null | grep -oPm1 "(?<=<output>)[^<]+"  | base64 --decode 2>/dev/null)"

	while (( "$#" ))
	do
		if [ "$1" = "pagemem" ]
		then

			grep '^pagemem' <<< "${tmctl_a}"

		elif [ "$1" == "access_uri_info" ]
		then
			echo -e "memory_usage_stat\t="
                        (egrep '^(access_uri_info|name)' | grep -B1 access_uri_info | head -2 | awk '{print($1,$2,$3)}' | column -t | awk '{print("\t",$0)}') <<< "${tmctl_a}"
		fi
		shift

	done
}

getMetaData () {

	# Get QKView MetaData
	metadata=$(curl -qs -H"Accept: application/vnd.f5.ihealth.api" --user-agent "MyGreatiHealthClient" --cookie cookiefile --cookie-jar cookiefile -o - https://ihealth-api.f5.com/qkview-analyzer/api/qkviews/${i})

	# Iterate through each argument.
	while (( "$#" ))
	do
		if [ "$1" = "generation_date" ]
		then
			# Convert generation_date epoch time (milliseconds) to readable Date Time.
			epochDate=$(echo ${metadata} | grep -oPm1 "(?<=<${1}>)[^<]+")
			echo -e "$1\t=\t$(date -d @${epochDate%???})"
		elif [ "$1" = "gui_uri" ]
		then
			echo -e "$1\t\t=\t$(echo ${metadata} | grep -oPm1 "(?<=<${1}>)[^<]+")"
		else
			echo -e "$1\t=\t$(echo ${metadata} | grep -oPm1 "(?<=<${1}>)[^<]+")"
		fi
		shift
	done

}

for i in $(cat qkviews)
do
	getMetaData hostname gui_uri generation_date
	echo -e "Pagemem Usage\t=\t$(getCommands pagemem | head -1 | awk '$0 ~ "pagemem" {print ($2 / $3) * 100}')"
	echo -e "$(getCommands access_uri_info)"
	echo "########"
done
