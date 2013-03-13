# Class: bind
#
# This module manages bind
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class bind (
  $version     = "installed",
  $start_bind  = true,
  $ns_domain   = "example.com",
  $ip_domain   = $::ipaddress
) {
  include concat::setup

  $utime_serial = inline_template("<%= Time.now.to_i %>")

  $bind_package = $::operatingsystem ? {
    "CentOS" => 'bind',
    "RedHat" => 'bind',
    "Ubuntu" => 'bind9',
    default  => 'bind',
  }

  $bind_service = $::operatingsystem ? {
    "CentOS" => 'named',
    "RedHat" => 'named',
    "Ubuntu" => 'bind9',
    default  => 'named',
  }
  
  $bind_owner = $::operatingsystem ? {
    "CentOS" => 'named',
    "RedHat" => 'named',
    "Ubuntu" => 'bind',
    default  => 'named',
  }

  package { $bind_package: ensure => $version, }

  service { $bind_service:
    ensure    => running,
    subscribe => Concat["/etc/named.conf"],
    require   => Package[$bind_package],
  }

  concat { "/etc/named.conf":
    owner   => root,
    group   => $bind_owner,
    mode    => '0644',
    require => Package[$bind_package],
    notify  => Service[$bind_service],
  }

  concat::fragment { "header.named.conf":
    order   => 10,
    target  => "/etc/named.conf",
    content => template('bind/named.conf.erb'),
  }

}
