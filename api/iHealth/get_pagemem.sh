#!/bin/bash
get_pagemem () {

  curl -H"Accept: application/vnd.f5.ihealth.api" --user-agent "MyGreatiHealthClient" --cookie cookiefile --cookie-jar cookiefile -o - https://ihealth-api.f5.com/qkview-analyzer/api/qkviews/${i}/commands/ec763272f520d0d2973ce7f371f89f0f7b1a2c05 2>/dev/null |
  grep -oPm1 "(?<=<output>)[^<]+"  |
  base64 --decode 2>/dev/null |
  grep '^pagemem'

}


for i in $(cat qkviews)
do
  get_pagemem
done
