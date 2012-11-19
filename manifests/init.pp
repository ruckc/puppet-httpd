class httpd {
  $ports=hiera_array('httpd_ports',['80','443'])
  $modules=hiera_array('httpd_modules')
  $servername=hiera('httpd_servername',$::fqdn)
  $servertokens=hiera('httpd_servertokens','OS')
  $timeout=hiera('httpd_timeout',60)
  $keepalive=hiera('httpd_keepalive','On')
  $maxkeepaliverequests=hiera('httpd_maxkeepaliverequests',100)
  $keepalivetimeout=hiera('httpd_keepalivetimeout',15)
  $prefork_startservers=hiera('httpd_prefork_startservers',8)
  $prefork_minspareservers=hiera('httpd_prefork_minspareservers',5)
  $prefork_maxspareservers=hiera('httpd_prefork_maxspareservers',20)
  $prefork_serverlimit=hiera('httpd_prefork_serverlimit',256)
  $prefork_maxclients=hiera('httpd_prefork_maxclients',256)
  $prefork_maxrequestsperchild=hiera('httpd_prefork_maxrequestsperchild',4000)
  $serveradmin=hiera('httpd_serveradmin','root@localhost')
  $usecanonicalname=hiera('httpd_usecanonicalname','Off')
  $hostnamelookups=hiera('httpd_hostnamelookups','Off')
  $loglevel=hiera('httpd_loglevel','warn')
  $serversignature=hiera('httpd_serversignature','Off')
  $adddefaultcharset=hiera('httpd_adddefaultcharset','UTF-8')

  if defined('serverfirewall') {
    firewall{'011 allow httpd incoming':
      chain   => 'INPUT',
      action  => 'accept',
      proto   => 'tcp',
      state   => 'NEW',
      dport   => $ports,
      notify  => Exec['persist-firewall'],
    }
  }

  package{['httpd']:
    ensure=>latest,
    notify=>Service['httpd'],
  }

  if member($modules,'ssl') {
    package{'mod_ssl':
      ensure =>latest,
      require=>Package['httpd'],
      notify =>Service['httpd'],
    }
  }

  if member($modules,'passenger') {
    package{'mod_passenger':
      ensure =>latest,
      require=>Package['httpd'],
      notify =>Service['httpd'],
    }

    httpd::conf{'_setup_passenger':
      content=>template('httpd/setup_passenger.conf.erb'),
      notify =>Service['httpd'],
    }
  }

  if member($modules,'proxy') {
    selboolean{'httpd_can_network_connect':
      value     =>on,
      persistent=>true,
    }
  } else {
    selboolean{'httpd_can_network_connect':
      value     =>on,
      persistent=>false,
    }
  }

  file{'/etc/httpd/conf/httpd.conf':
    ensure =>file,
    content=>template('httpd/httpd.conf.erb'),
    owner  =>root,
    group  =>apache,
    mode   =>'0440',
    notify =>Service['httpd'],
  } ->

  file{'/etc/httpd/conf.d':
    ensure =>directory,
    owner  =>root,
    group  =>apache,
    mode   =>'0550',
    purge  =>true,
    recurse=>true,
    force  =>true,
    notify =>Service['httpd'],
  } ->

  service{'httpd':
    ensure=>running,
    enable=>true,
  }

  httpd::defaultvhosts{$ports:}
}
