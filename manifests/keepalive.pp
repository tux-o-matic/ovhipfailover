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
define ovhipfailover::keepalive (
  $auth_pass            = '',
  $auth_type            = 'PASS',
  $interface            = 'eth0',
  $notify_script_master = undef,
  $priority             = '100',
  $state                = 'BACKUP',
  $track_interface      = ['eth0'],
  $track_script         = undef,
  $virtual_ipaddress    = [],
  $virtual_router_id    = '50',
) {

  include keepalived

  if $track_script {
    $vrrp_scripts = {
      "chk_${name}" => {
        scripts => $track_script,
      }
    }

    create_resources(keepalived::vrrp::script, $vrrp_scripts)
  }

  $instances = {
    $name => {
      auth_pass            => $auth_pass,
      auth_type            => $auth_type,
      interface            => $interface,
      notify_script_master => $notify_script_master,
      priority             => $priority,
      state                => $state,
      track_interface      => $track_interface,
      track_script         => $track_script,
      virtual_ipaddress    => $virtual_ipaddress,
      virtual_router_id    => $virtual_router_id,
    }
  }

  create_resources(keepalived::vrrp::instance, $instances)

}
