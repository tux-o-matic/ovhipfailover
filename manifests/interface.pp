#    Puppet module to manage network interface and IP failover.
#    Copyright (C) 2014  Benjamin Merot (tux_o_matic@yahoo.com)
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
define ovhipfailover::interface (
  $ipaddress       = '',
  $device          = $name,
  $onboot          = 'yes',
  $network         = '172.16.0.0/12',
  $netmask         = '255.240.0.0',
  $broadcast       = '172.31.255.255',
  $gateway         = false,
  $networkname     = '',
  $manage_firewall = true,
  $start           = true,
  $ovh_vrack       = false) {
  if $ipaddress != '' {
    file { "/etc/sysconfig/network-scripts/ifcfg-${device}":
      content => template('interface/ifcfg.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }

    if $manage_firewall {
#      firewall { "100 allow all traffic on ${networkname} to ${device}":
#        state   => ['NEW'],
#        proto   => 'all',
#        source  => "${network}",
#        iniface => "${device}",
#        action  => 'accept',
#      }
    }

    if $start {
      exec { "ifup-${device}":
        refreshonly => true,
        command     => "ifup ${device}",
      }
    }

    if $ovh_vrack {
      # Needed for OVH vRack 1.5
      exec { "arping-${device}":
        refreshonly => true,
        command     => "arping -I ${device} 1.1.1.1",
      }
    }
  }

}