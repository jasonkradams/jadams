#!/bin/bash

curl -sk https://10.154.162.1/mgmt/shared/authn/login -d@tokenauth  | tee ./.token | python -c 'import sys, json; print(json.load(sys.stdin)["token"]["token"])' > ./token
cat ./.token | json_pp
