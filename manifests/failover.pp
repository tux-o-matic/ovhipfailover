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
#
# Parameters:
# destination_fqdn: The Fully Qualified Domain Name of the server meant to receive this IP if the local service is stopped.
# application_key: Use the following form to create a key https://eu.api.ovh.com/createApp/
# application_secret: Use the following form to create a key https://eu.api.ovh.com/createApp/
# consumer_key: Must be obtained before the script can make calls to the API. The provided Python script can be used to help you
# generate it.
#
# Sample Usage on serverA:
# ovhipfailover::failover { 'x.x.x.x':
#       destination_fqdn => "serverB.domain.com",
#       application_key => "",
#       application_secret => "",
#       consumer_key => "",
#}
# Apply the definition on serverB by just changing the destination_fqdn
#

define ovhipfailover::failover (
  $ip_to_move         = $name,
  $device             = '',
  $destination_fqdn   = '',
  $application_key    = '',
  $application_secret = '',
  $consumer_key       = '',
  $start              = false) {
  file { "/usr/local/bin/ipfailover.py":
    source  => 'puppet:///modules/ovhipfailover/ovh_ip_failover.py',
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    require => Package["python-requests"],
  }

  file { "/etc/init.d/ipfailover":
    content => template('ovhipfailover/ipfailover.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    require => File["/usr/local/bin/ipfailover.py"],
  }

  package { "python-requests": ensure => installed, }
}
