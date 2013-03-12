#class dns::hostentry {
#  @@hostentry { "${::fqdn}":
#    host_name   => $::hostname,
#    domain_name => $::domainname,
#    fqdn        => $::fqdn,
#    ip_address  => $::ipaddress,
#    zone        => $::ec2_placement_availability_zone
#    provider    => "aws",
#  }

define bind::hostentry (
  $host_name,
  $domain_name,
  $fqdn,
  $ip_address,
  $order  = '20',
  $zone,
  $provider,
  $domain,
) {
  concat::fragment { "${host_name}.${zone}.${provider}.${domain}":
    order   => 20,
    target  => "${chroot}/var/named/${domain}",
    content => template('puppet:///modules/bind/hostentry.erb'),
  }
  
  ## added both entries at the same time in $domain zone
  #concat::fragment { "${host_name}.servers.${domain}":
  #  order   => 20,
  #  target  => "${chroot}/var/named/servers.${domain}",
  #  content => template('puppet:///modules/bind/hostentry.erb'),
  #}
  
  concat::fragment { "${host_name}.10.in-addr.arpa":
    order   => 20,
    target  => "${chroot}/var/named/10.in-addr.arpa",
    content => template('puppet:///modules/bind/reverseentry.erb'),
  }
}
