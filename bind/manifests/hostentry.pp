define bind::hostentry (
  $host_name,
  $domain_name,
  $fqdn,
  $ip_address,
  $order  = '20',
  $zone,
  $provider,
) {
  concat::fragment { "${host_name}.${zone}.${provider}":
    order   => 20,
    target  => '/var/named/',
    content => template('puppet:///modules/bind/hostentry.erb'),
  }
  #concat::fragment { "${host_name}.servers":
  #  order   => 20,
  #  target  => '/var/named/',
  #  content => template('puppet:///modules/bind/hostentry.erb'),
  #}
  concat::fragment { "${host_name}.servers":
    order   => 20,
    target  => '/var/named/',
    content => template('puppet:///modules/bind/reverseentry.erb'),
  }
  
}