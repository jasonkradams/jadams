#!/usr/bin/python

from f5.bigip import ManagementRoot
import f5.bigip.shared.authz

import urllib3

urllib3.disable_warnings()

mgmt = ManagementRoot("10.154.162.2", "f5guest", "password")

pools = mgmt.tm.ltm.pools.get_collection()
for pool in pools:
    print("Pool: " + pool.name)
    for member in pool.members_s.get_collection():
        print("Member: " + member.name)
