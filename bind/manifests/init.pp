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
  $domain_name = "$::domain"
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

  package { $bind_package: ensure => $version, }

  service { $bind_service:
    ensure    => running,
    subscribe => File["named.conf"],
    require   => Package[$bind_package],
  }

  #file { "named.conf":
  #  owner   => root,
  #  group   => named,
  #  mode    => '0640',
  #  path    => "/etc/named.conf",
  #  content => template('bind/named.conf.erb'),
  #  require => Package[$bind_package],
  #}
  
  concat { "/etc/named.conf":
    owner   => root,
    group   => named,
    mode    => '0644',
    require => Package[$bind_package],
    notify  => Service[$bind_service],
  }

  concat::fragment { "header.named.conf":
    order   => 10,
    content => template('bind/named.conf.erb'),
  }

}
