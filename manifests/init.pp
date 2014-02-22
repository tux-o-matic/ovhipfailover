#    Puppet module to manage network interface and IP failover.
#    Copyright (C) 2014  Benjamin Merot (ben@busyasabee.org)
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
#
#
# Sample Usage on serverA:
# class { 'ovhipfailover':
#       ipaddress => "x.x.x.x",
#       device => "ethX:X",
#       destination_fqdn => "serverB.domain.com",
#       application_key => "",
#       application_secret => "",
#       consumer_key => "",
# }
# Apply the definition on serverB by just changing the destination_fqdn and device if different
#
class ovhipfailover (
  $ipaddress          = '',
  $device             = '',
  $onboot             = 'yes',
  $network            = false,
  $netmask            = '255.255.255.255',
  $broadcast          = '255.255.255.255',
  $gateway            = false,
  $start              = true,
  $ovh_vrack          = false,
  $destination_fqdn   = '',
  $application_key    = '',
  $application_secret = '',
  $consumer_key       = '') {

  ovhipfailover::interface{ "${device}":
    network => $network,
    netmask => $netmask,
    broadcast => $broadcast,
    gateway => $gateway,
    onboot => $onboot,
  }
  
  ovhipfailover::failover{ "${ipaddress}":
    destination_fqdn => $destination_fqdn,
    application_key => $application_key,
    application_secret => $application_secret,
    consumer_key => $consumer_key,
  }

}
