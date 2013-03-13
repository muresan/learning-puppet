#
#  @@bind::hostentry { "${::fqdn}":
#    host_name   => $::hostname,
#    domain_name => $::domain,
#    fqdn        => $::fqdn,
#    ip_address  => $::ipaddress,
#    zone        => $::ec2_ami_id ? { /^ami-........$/ => $::ec2_placement_availability_zone, /^$/ => "1" },
#    provider    => $::ec2_ami_id ? { /^ami-........$/ => "aws", /^$/ => "rackspace", },
#  }
#

define bind::hostentry (
  $host_name,
  $domain_name,
  $fqdn,
  $ip_address,
  $zone,
  $provider
) {
  
  $reverse_ip_address = inline_template('<%= ip_address.split(".").reverse.join(".") %>')
  
  concat::fragment { "${host_name}.${zone}.${provider}.${domain_name}":
    order   => 90,
    target  => "/var/named/${domain_name}",
    content => template('bind/hostentry.erb'),
  }
  
  concat::fragment { "${host_name}.10.in-addr.arpa":
    order   => 90,
    target  => "/var/named/10.in-addr.arpa",
    content => template('bind/reverseentry.erb'),
  }
}
