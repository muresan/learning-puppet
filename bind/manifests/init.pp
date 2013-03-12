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
  $domain_name = "tinyco.com"
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
    subscribe => [File["named.conf"], Concat["/var/named/${domain_name}", "/var/named/10.in-addr.arpa"],],
    require   => Package[$bind_package],
  }

  file { "named.conf":
    owner   => root,
    group   => named,
    mode    => '0640',
    path    => "/etc/named.conf",
    content => template('bind/named.conf.erb'),
    require => Package[$bind_package],
  }

  concat { "/var/named/${domain_name}":
    owner   => root,
    group   => named,
    mode    => '0644',
    require => Package[$bind_package],
    notify  => Service[$bind_service],
  }

  concat { "/var/named/10.in-addr.arpa":
    owner   => root,
    group   => named,
    mode    => '0644',
    require => Package[$bind_package],
    notify  => Service[$bind_service],
  }

  concat::fragment { "header.${domain_name}":
    target  => "/var/named/${domain_name}",
    order   => 10,
    content => ";; This file managed by Puppet\n",
  }

  concat::fragment { "soa.${domain_name}":
    target  => "/var/named/${domain_name}",
    order   => 20,
    content => template('bind/soa.erb'),
  }

  concat::fragment { "header.10.in-addr.arpa":
    target  => "/var/named/10.in-addr.arpa",
    order   => 10,
    content => ";; This file managed by Puppet\n",
  }

    concat::fragment { "soa.10.in-addr.arpa":
    target  => "/var/named/10.in-addr.arpa",
    order   => 20,
    content => template('bind/soa.erb'),
  }

  concat::fragment { "origin.10.in-addr.arpa":
    target  => "/var/named/10.in-addr.arpa",
    order   => 30,
    content => "\$ORIGIN in-addr.arpa.\n",
  }

  Bind::Hostentry <<| |>>

  # file { "$domain_name":
  #  owner   => root,
  #  group   => named,
  #  mode    => 0640,
  #  path    => "/var/named/${domain_name}",
  #  content => template("puppet:///modules/bind/hostentry.erb"),
  #  require => Package[$bind_package],
  #}

  # file { "10.in-addr.arpa":
  #  owner   => "root",
  #  group   => "named",
  #  mode    => 640,
  #  path    => "/var/named/10.in-addr.arpa",
  #  content => template("puppet:///modules/bind/reverseentry.erb")
  #}

  #  class dns::ips {
  #    Hostentry <<| |>> {
  #      notify => Service["named"]
  #    }
  #  }
}
