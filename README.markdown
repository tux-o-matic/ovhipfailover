# OVH IP failover #

This module can manage two network elements
### Network interface via RedHat type network script
- General network interface, private/public
- Virtual interfaces, included the ones offered by OVH as part of their vRack solution
### A failover IP from OVH via an init script to control the routing destination of the IP
- Wraps underlying calls to the OVH API

-------

By using the failover init script in a cluster resource manager such as rgmanager or Pacemaker, a true HA solution can be implemented across multiple OVH datacenters.
No extra parameter is needed to call the script, nesting it under a VIP resource will ensure the proper migration of the resource chain.
