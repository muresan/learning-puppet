# Class: bind::domain
#
# This module manages bind domains
#
# Parameters: reverse true|false if the domain is a reverse domain, so we will add the $ORIGIN entry
#
# Actions: creates the /var/named/$name domain entries
#
# Requires: see Modulefile
#
# Sample Usage:
#
define bind::domain (  
  $reverse = false 
) {

  include bind
  
  concat { "/var/named/${name}":
    owner   => root,
    group   => named,
    mode    => '0644',
    require => Package[$bind::bind_package],
    notify  => Service[$bind::bind_service],
  }

  concat::fragment { "header.${name}":
    target  => "/var/named/${name}",
    order   => 10,
    content => ";; This file managed by Puppet\n",
  }

  concat::fragment { "soa.${name}":
    target  => "/var/named/${name}",
    order   => 20,
    content => template('bind/soa.erb'),
  }

  if ( $reverse == true ){
	  concat::fragment { "origin.${name}":
	    target  => "/var/named/${name}",
	    order   => 30,
	    content => "\$ORIGIN in-addr.arpa.\n",
	  }
  }

  concat::fragment { "named.conf.${name}":
    target  => "/etc/named.conf",
    order   => 20,
    content => template("bind/zone.named.conf.erb"), 
  }

  Bind::Hostentry <<| domain_name == $name |>>

}

