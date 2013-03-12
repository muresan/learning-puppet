#
#  @@hostentry { "${::fqdn}":
#    host_name   => $::hostname,
#    domain_name => $::domain,
#    fqdn        => $::fqdn,
#    ip_address  => $::ipaddress,
#    zone        => $::ec2_placement_availability_zone,
#    provider    => "aws",
#  }

define bind::hostentry (
  $host_name,
  $domain_name,
  $fqdn,
  $ip_address,
  $zone,
  $provider
) {
  
  $reverse_ip_address = inline_template('<%= ipaddress.split(".").reverse.join(".") %>')
  
  concat::fragment { "${host_name}.${zone}.${provider}.${domain_name}":
    order   => 90,
    target  => "/var/named/${domain_name}",
    content => template('bind/hostentry.erb'),
  }
  
  ## added both entries at the same time in $domain_name zone
  #concat::fragment { "${host_name}.servers.${domain_name}":
  #  order   => 20,
  #  target  => "/var/named/servers.${domain_name}",
  #  content => template('puppet:///modules/bind/hostentry.erb'),
  #}
  
  concat::fragment { "${host_name}.10.in-addr.arpa":
    order   => 90,
    target  => "/var/named/10.in-addr.arpa",
    content => template('bind/reverseentry.erb'),
  }
}
