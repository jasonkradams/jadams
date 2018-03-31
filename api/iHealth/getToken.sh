#!/bin/bash

echo "Enter your AskF5.com username (email): "
read username

echo "Enter your AskF5.com password: "
read -s PASS

curl -H"Content-type: application/json" --user-agent "MyGreatiHealthClient" --cookie-jar cookiefile -o - --data-ascii "{\"user_id\": \"${username}\", \"user_secret\": \"${PASS}\"}" -X POST https://api.f5.com/auth/pub/sso/login/ihealth-api
