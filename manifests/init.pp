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
class ovhipfailover (
  $manage_pip         = true,
  $use_keepalive      = true,
) {

  if $use_keepalive {

    if $manage_pip {
      package { 'python2-pip':
        ensure => 'installed',
        nofity => Package['ovh'],
      }
    }

    if $manage_python_deps and $::osfamily == 'RedHat' and versioncmp($::operatingsystemmajrelease, '6') == 0 {
      package {'python-argparse':
        ensure => 'present',
      }
    }

    package { 'ovh':
      ensure   => 'installer',
      provider => 'pip',
    }

    file { 'ovh_ip_move':
      group   => 'root',
      mode    => '0700',
      owner   => 'root',
      path    => '/usr/local/bin/ovh_ip_move.py',
      require => Package['ovh'],
      source  => 'puppet:///modules/ovhipfailover/ovh_ip_move.py',
    }

  }

}
