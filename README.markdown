# OVH IP failover #

This Puppet module is meant to ease the implementation of multiple network interfaces on a server and leverage special network solutions offered by the hosting company OVH.
#### Network interface via RedHat type network script
- General network interface, private/public.
- Virtual interfaces, included the ones offered by OVH as part of their vRack solution.

#### Manage a failover IP from OVH via an init script
- Wraps underlying calls to the OVH API to control the routing destination of the IP (works between different data centers).
- Can control virtual interface state regardless of subnet which isn't possible with OCF scripts such as RedHat's rgmanager.

-------

#### Example 
You can manage in a single definition a virtual interface with failover capability provided by OVH.
Apply the definition on serverB by just changing the destination_fqdn to "serverA" and device name if differently mapped.
```
 class { 'ovhipfailover':
       ipaddress => "x.x.x.x",
       device => "ethX:X",
       destination_fqdn => "serverB.domain.com",
       application_key => "",
       application_secret => "",
       consumer_key => "",
 }
```

To obtain a consumer key to use on the OVH API after creating an application key and secret, use the embedded Python script.
Calling the script will return a consumer key and a link to the validation url, you should choose an "illimited" time validity for your consumer key.
```
./ovh_ip_failover.py POST /auth/credential <APPLICATION_KEY> <APPLICATION_SECRET>
```

-------

By using the failover init script in a cluster resource manager such as rgmanager or Pacemaker, a true HA solution can be implemented across multiple OVH datacenters.
No extra parameter is needed to call the script as a standard init script resource.

