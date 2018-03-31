#!/usr/bin/python
import requests
import json
from urllib3 import disable_warnings as dw

dw()

username = "f5guest"
password = "password"
hostname = "10.154.162.2"

# setup up a requests session
s = requests.session()

# not going to validate the HTTPS certifcation of the iControl REST service
s.verify = False

# we'll use JSON in our request body and expect it back in the responses
s.headers.update({'Content-Type': 'application/json'}) 

# this is the base URI for iControl REST
icr_url = 'https://%s' % hostname

# add the module URI parts
t_url = icr_url + '/mgmt/shared/authn/login'
v_url = icr_url + '/mgmt/shared/authz/tokens/'

payload = {'username': username,'password': password,'loginProviderName': 'tmos'}

# call the get method on your requests session
r = s.post(t_url, data=json.dumps(payload))

# look at the response
if r.status_code < 400:
    r_obj = json.loads(r.text)
    print(json.dumps(r_obj, indent=3, sort_keys=True))
    token = r_obj["token"]["token"]

#print(token)

headers = {'X-F5-Auth-Token': token}

r = s.get(v_url + token, headers=headers)

if r.status_code >= 400:
    r_obj = json.loads(r.text)
    print(json.dumps(r_obj, indent=3, sort_keys=True))

#print('*' * 60)
#print(json.dumps(json.loads(r.text), indent=3, sort_keys=True))
