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
  $version = "installed",
  $start_bind = true,
  $chroot = "/var/named/chroot",
  $domain = "tinyco.com"
) {
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
    subscribe => [File["named.conf"], Concat["${chroot}/var/named/${domain}", "${chroot}/var/named/10.in-addr.arpa"],],
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

  concat { "${chroot}/var/named/${domain}":
    owner   => root,
    group   => named,
    mode    => '0644',
    require => Package[$bind_package],
    notify  => Service[$bind_service],
  }

  concat { "${chroot}/var/named/10.in-addr.arpa":
    owner   => root,
    group   => named,
    mode    => '0644',
    require => Package[$bind_package],
    notify  => Service[$bind_service],
  }

  concat::fragment { "header.${domain}":
    target  => "${chroot}/var/named/${domain}",
    order   => '01',
    content => ";; This file managed by Puppet\n",
  }

  concat::fragment { "soa.${domain}":
    target  => "${chroot}/var/named/${domain}",
    order   => '10',
    content => template('bind/templates/soa.erb'),
  }

  concat::fragment { "header.10.in-addr.arpa":
    target  => "${chroot}/var/named/10.in-addr.arpa",
    order   => '01',
    content => ";; This file managed by Puppet\n",
  }

  concat::fragment { "soa.10.in-addr.arpa":
    target  => "${chroot}/var/named/10.in-addr.arpa",
    order   => '10',
    content => template('bind/templates/soa.erb'),
  }

  Bind::Hostentry <<| |>>

  # file { "$domain":
  #  owner   => root,
  #  group   => named,
  #  mode    => 0640,
  #  path    => "${chroot}/var/named/${domain}",
  #  content => template("puppet:///modules/bind/hostentry.erb"),
  #  require => Package[$bind_package],
  #}

  # file { "10.in-addr.arpa":
  #  owner   => "root",
  #  group   => "named",
  #  mode    => 640,
  #  path    => "${chroot}/var/named/10.in-addr.arpa",
  #  content => template("puppet:///modules/bind/reverseentry.erb")
  #}

  #  class dns::ips {
  #    Hostentry <<| |>> {
  #      notify => Service["named"]
  #    }
  #  }
}
