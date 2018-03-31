#!/bin/python
from f5.bigip import ManagementRoot
import requests,base64

# This script replicates the "Lab 2.1" amd "Lab 2.2" steps from the Postman Collections
# in python. This leverages the F5 Python SDK to compare and contrast this to raw REST 
# calls as already seen via Postman exercises. It is good practice to check for existing 
# objects before creating an object while also verifying the create or update response 
# codes and messages, but this script doesn't do this in order to more closely replicate 
# the Postman exercise 
# 
# More on method mappings: 
# https://f5-sdk.readthedocs.io/en/latest/userguide/basics.html#methods-section
#

## Configuration variables
studentNumber = "1"    # Configure me
studentColor = "blue"     # Configure me

bipB_mgmt = {
  "address": "10.154.162.",   # Configure me
  "user": "admin",
  "pass": "admin",  # The initial password of the system to perform iCR auth
  "hostname": "BIG-IP-" + studentNumber + "B." + studentColor + ".Lab"
}

generalConfig = {
  "defaultGateway": "10.10." + studentNumber + ".254",
  # The following dict keys must match the BIG-IP attribute being updated
  "dns": { 
    "nameServers": [ "4.2.2.2", "8.8.8.8" ],
    "search": [ "localhost" ] # Search Domains
  },
  # The following dict keys must match the BIG-IP attribute being updated
  "ntp": {
    "servers": [ "192.168.11.168" ],
    "timezone": "America/Los_Angeles"
  },
  "desiredRootPass": "changeme",    # Configure me
  "desiredAdminPass": "changeme"    # Configure me
}

externalVlan = {
  "name": "External",
  "interface": "1.1",
  "selfAddress": "10.10." + studentNumber + ".32/16",
  "tag": "10"
}

internalVlan = {
  "name": "Internal",
  "interface": "1.2",
  "selfAddress": "172.16." + studentNumber + ".32/16",
  "tag": "20"
}

## Below are generator functions for the iControl REST HTTP Request Bodies. These are 
## very similar to the JSON payloads sent in the Postman Collection examples

# This is a JSON body generator to re-use code, but customize output for multiple VLANs
def generateVlanPayload(vlanObject):
  return {
    "name": vlanObject['name'],
    "partition": "Common",
    "autoLasthop": "default",
    "cmpHash": "default",
    "mtu": "1500",
    "interfaces": 
      [
        {
        "name": vlanObject['interface'],
        "tagged": False
      }
    ]
  }

# This is a JSON body generator to re-use code, but customize output for multiple selfIPs
def generateSelfipPayload(sipObject):
  return {
    "name": "Self-" + sipObject['name'],
    "partition": "Common",
    "address": sipObject['selfAddress'],
    "floating": "disabled",
    "trafficGroup": "/Common/traffic-group-local-only",
    "vlan": "/Common/" + sipObject['name'],
    "allowService": [
      "default"
    ]
  }

# This is a JSON body generator to re-use code, but customize output for a default gateway
def generateDefaultRoutePayload(gateway):
  return {
    "name": "Default",
    "partition": "Common",
    "gw": gateway,
    "mtu": 0,
    "network": "0.0.0.0/0"
  }

## Connect to the BIG-IP. Choose 1 authentication method
# Basic Auth
#bipB = ManagementRoot(bipB_mgmt['address'], bipB_mgmt['user'], bipB_mgmt['pass'])
# Token Auth
bipB = ManagementRoot(bipB_mgmt['address'], bipB_mgmt['user'], bipB_mgmt['pass'], token=True)

## Comment formatting for the following Python SDK calls are as follows:
## Task type to perform
## Equivalent REST Request type and endpoint

# Set System Global settings via PATCH (a partial update of specified attributes)
# PATCH https://{{bigip_b_mgmt}}/mgmt/tm/sys/global-settings
globalModify = bipB.tm.sys.global_settings.modify(guiSetup="disabled", hostname=bipB_mgmt['hostname'])


# Set System DNS settings via PATCH (a partial update of specified attributes)
# PATCH https://{{bigip_b_mgmt}}/mgmt/tm/sys/dns 
dnsModify = bipB.tm.sys.dns.modify(**generalConfig['dns'])


# Set Systen NTP settings
# PATCH https://{{bigip_b_mgmt}}/mgmt/tm/sys/ntp 
ntpModify = bipB.tm.sys.ntp.modify(**generalConfig['ntp'])


## The following examples update the same configuration components as above, but via PUT instead of PATCH
## Here, PUT performs a full "replace" of all attributes (that is, it sets all values of the endpoint explicitly)

# Set System Global settings
# # PUT https://{{bigip_b_mgmt}}/mgmt/tm/sys/global-settings
# globalsettings = bipB.tm.sys.global_settings       # Fetch the existing settings
# globalsettings.guiSetup = "disabled"               # Disable the GUI Setup
# globalsettings.hostname = bipB_mgmt['hostname']    # Change the hostname
# globalsettings.update()                            # Perform the actual iControl REST Update


# Set System DNS settings
# # PUT https://{{bigip_b_mgmt}}/mgmt/tm/sys/dns 
#dnssettings = bipB.tm.sys.dns                                     # Fetch the existing settings
#dnsSettings['nameServers'] = generalConfig['dns']['nameServers']  # Set the DNS name servers
#dnsSettings['search'] = generalConfig['dns']['searchDomains']     # Set the search domain
#dnssettings.update()                                              # Perform the actual iControl REST Update


# Set Systen NTP settings
# # PUT https://{{bigip_b_mgmt}}/mgmt/tm/sys/ntp 
# ntpsettings = bipB.tm.sys.ntp                       # Fetch the existing settings
# ntpsettings.servers = generalConfig['ntp']['ntpServers']   # Set the NTP servers
# ntpsettings.timezone = generalConfig['ntp']['timezone']    # Set the time zone
# ntpsettings.update()                                # Perform the actual iControl REST Update

# Create the Request header for the direct REST calls below
requestChangeHeaders = {
  'X-F5-Auth-Token': bipB.icrs.session.auth.token,
  'content-type': "application/json"
}

# Set root User Password via direct REST call
# POST https://{{bigip_b_mgmt}}/mgmt/shared/authn/root
# Not currently implemented in the SDK. Direct REST call workaround: 
rootChangeUrl = "https://" + bipB_mgmt['address'] + "/mgmt/shared/authn/root"
rootChangePayload = "{\"oldPassword\":\"default\",\"newPassword\":\"" + generalConfig['desiredRootPass'] + "\"}"
rootChangeResponse = requests.post(rootChangeUrl, data=rootChangePayload, headers=requestChangeHeaders, verify=False)


# Set admin User Password via direct REST call
# PATCH https://{{bigip_b_mgmt}}/mgmt/tm/auth/user/admin
adminChangeUrl = "https://" + bipB_mgmt['address'] + "/mgmt/tm/auth/user/admin"
adminChangePayload = "{\"password\":\"" + generalConfig['desiredAdminPass'] + "\"}"
adminChangeResponse = requests.patch(adminChangeUrl, data=adminChangePayload, headers=requestChangeHeaders, verify=False)


# Create VLANs 
# POST https://{{bigip_b_mgmt}}/mgmt/tm/net/vlan
vlanIntResponse = bipB.tm.net.vlans.vlan.create(**generateVlanPayload(internalVlan))
vlanExtResponse = bipB.tm.net.vlans.vlan.create(**generateVlanPayload(externalVlan))


# Create Self IPs
# POST https://{{bigip_b_mgmt}}/mgmt/tm/net/self
sipIntResponse = bipB.tm.net.selfips.selfip.create(**generateSelfipPayload(internalVlan))
sipExtResponse = bipB.tm.net.selfips.selfip.create(**generateSelfipPayload(externalVlan))


# Create the Default Gateway Route
# POST https://{{bigip_b_mgmt}}/mgmt/tm/net/route
dgwResponse = bipB.tm.net.routes.route.create(**generateDefaultRoutePayload(generalConfig['defaultGateway']))
