#!/bin/bash

curl -sk https://10.154.162.1/mgmt/tm/ltm/pool -H "X-F5-Auth-Token: $(cat ./token)" | json_pp
