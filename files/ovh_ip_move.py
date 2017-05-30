#!/usr/bin/env python

#    Puppet module to manage network interface and IP failover.
#    Copyright (C) 2017  Benjamin Merot (ben@busyasabee.org)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
from __future__ import print_function
from logging.handlers import SysLogHandler
import argparse
import logging
import ovh


log = logging.getLogger(__name__)
log.setLevel(logging.INFO)
syslog = SysLogHandler(address='/dev/log')
formatter = logging.Formatter('%(name)s: %(levelname)s %(message)s')
syslog.setFormatter(formatter)
log.addHandler(syslog)


def move(api_endpoint, app_key, app_secret, con_key, ip_failover, ip_dest, to_service):
    client = ovh.Client(endpoint=api_endpoint, application_key=app_key, application_secret=app_secret,
                        consumer_key=con_key)

    result = client.post('/ip/' + ip_failover + '/move', nexthop=ip_dest, to=to_service)

    if 'taskId' in result and 'function' in result:
        log.info('Called OVH API function ' + result['function'] + ', returned taskId ' + str(result['taskId']))
    else:
        log.info('Called OVH API')


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Manage OVH IP failover routing')
    parser.add_argument('--app_key', dest='app_key', help='Application key for OVH API', required=True)
    parser.add_argument('--app_secret', dest='app_secret', help='Application Secret for OVH API', required=True)
    parser.add_argument('--consumer_key', dest='con_key', help='Consumer key for OVH API', required=True)
    parser.add_argument('--ip_failover', dest='ip_failover', help='IP failover to manage', required=True)
    parser.add_argument('--ip_destination', dest='ip_destination', help='Destination IP to route to (nexthop)')
    parser.add_argument('--to_service', dest='to_service', help='Destination service to route to', required=True)
    parser.add_argument('--api_endpoint', dest='api_endpoint', default='ovh-eu', help='OVH API endpoint')
    args = parser.parse_args()
    move(args.api_endpoint, args.app_key, args.app_secret, args.con_key, args.ip_failover, args.ip_destination,
         args.to_service)
