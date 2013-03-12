# Create “/tmp/testfile” if it doesn’t exist.


class test_class {
    file { "/tmp/testfile":
       ensure => present,
       mode   => 644,
       owner  => root,
       group  => root
    }

file {'/tmp/test1':
      ensure  => present,
      content => "Hi.",
    }

    file {'/tmp/test2':
      ensure => directory,
      mode   => 644,
    }

    file {'/tmp/test3':
      ensure => link,
      target => '/tmp/test1',
    }

    notify {"I'm notifying you.":}
    notify {"So am I!":}

file { "/etc/named.conf":
          content => template("named/named.conf.erb"),
          owner => root,
          group => named,
          mode => 0640,
}

$utime_serial = inline_template("<%= Time.now.to_i %>")

file { "/var/named/chroot/var/named/$domain.hosts":
          content => template("named/domain.hosts.erb"),
          owner => root,
          group => named,
          mode => 0640,
}

class dns::host {
  @@host_entry { "${fqdn}":
     host_name          => $hostname,
     domain_name        => $domainname,
     fqdn               => $fqdn,
     ip_address         => $ipaddress,

}


class dns::ips {
Host_entry <<| |>> { notify => Service["named"] }
     }
  }
}

class bind {
  case $operatingsystem {
    CentOS: {
      package { 'bind':
        ensure  => present,
      }
    }
    Ubuntu: {
      package { 'bind9':
        ensure  => present,
      }
    }
  }
}

node puppetag {

    include test_class
    include bind


}


