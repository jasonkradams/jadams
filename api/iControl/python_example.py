#!/usr/bin/python
import requests
import json

username = "f5test"
password = "password"
hostname = "10.232.134.3"

# setup up a requests session
icr_session = requests.session()
icr_session.auth = (username, password)

# not going to validate the HTTPS certifcation of the iControl REST service
icr_session.verify = False

# we'll use JSON in our request body and expect it back in the responses
icr_session.headers.update({'Content-Type': 'application/json'})

# this is the base URI for iControl REST
icr_url = 'https://%s/mgmt/tm' % hostname

# Simple example - get all LTM pool attributes
folder = "Common"
pool_name = "G_HTTP_POO"

# add the module URI parts
request_url = icr_url + '/ltm/pool/'

# here is an example of calling an object explicitly.
request_url += '~' + folder + '~' + pool_name

# call the get method on your requests session
response = icr_session.get(request_url)

# look at the response
if response.status_code < 400:
    response_obj = json.loads(response.text)
    print("response %s" % response_obj)

print(response.status_code)
