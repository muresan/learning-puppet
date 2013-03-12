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
  $version    = "installed",
  $start_bind = true,
) {
  
  $utime_serial = inline_template("<%= Time.now.to_i %>")
  $bind_package = $::operatingsystem ? {
      "CentOS" => 'bind',
      "RedHat" => 'bind',
      "Ubuntu" => 'bind9',
      default =>  'bind',
    }  
  
  package { $bind_package: 
    ensure  => $version,
  }

  file { "/etc/named.conf":
    owner   => root,
    group   => named,
    mode    => 0640,
    content => template("named/named.conf.erb"),
    require => Package[$bind_package],
  }

  file { "/var/named/chroot/var/named/$domain.hosts":
    owner   => root,
    group   => named,
    mode    => 0640,
    content => template("named/domain.hosts.erb"),
    require => Package[$bind_package],
  }

  class dns::host {
    @@host_entry { "${::fqdn}":
      host_name   => $::hostname,
      domain_name => $::domainname,
      fqdn        => $::fqdn,
      ip_address  => $::ipaddress,
    }

    class dns::ips {
      Host_entry <<| |>> {
        notify => Service["named"]
      }
    }

  }

}
