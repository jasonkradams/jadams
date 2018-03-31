#!/bin/bash

curl -sk https://10.154.162.1/mgmt/shared/authz/users/admin -H "X-F5-Auth-Token: $(cat ./token)" | json_pp
