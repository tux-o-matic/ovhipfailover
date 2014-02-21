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
# Sample Usage on serverA:
# ovhipfailover::failover { 'x.x.x.x':
#       destination_fqdn => "serverB.domain.com",
#       application_key => "",
#       application_secret => "",
#       consumer_key => "",
# }
#

define ovhipfailover::failover (
  $ip_to_move         = $name,
  $interface          = '',
  $destination_fqdn   = '',
  $application_key    = '',
  $application_secret = '',
  $consumer_key       = '') {
  file { "/usr/local/bin/ipfailover.py":
    source  => 'puppet:///modules/net/ovh_ip_failover.py',
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    require => Package["python"],
  }

  #
  #  file { "/usr/share/cluster/ipfailover.sh":
  #    content => template('net/ocf_ovh_ip_failover.sh.erb'),
  #    owner   => 'root',
  #    group   => 'root',
  #    mode    => '0700',
  #    require => File["/usr/share/cluster/ipfailover.py"],
  #  }

  file { "/etc/init.d/ipfailover":
    content => template('net/ipfailover.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    require => File["/usr/local/bin/ipfailover.py"],
  }

  package { "python": ensure => installed, }

  #That package alone should install python dep
  package { "python-requests":
    ensure  => installed,
    require => Package["python"]
  }
}