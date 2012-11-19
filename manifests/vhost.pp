define httpd::vhost(
  $port,
  $servername=$title,
  $ssl=false,
  $includedir=nil,
) {
  if $includedir {
    file{"/etc/httpd/conf.d/${includedir}.d":
      ensure=>directory,
      mode  =>'0750',
    }
  }

  if $ssl or $port == 443 or $port == '443' {
    $ssl_certificate_file=hiera('ssl_certificate_file')
    $ssl_certificate_key_file=hiera('ssl_certificate_key_file')
    $ssl_certificate_chain_file=hiera('ssl_certificate_chain_file')
    $ssl_ca_certificate_file=hiera('ssl_ca_certificate_file')
  }

  httpd::conf{"${servername}-${port}":
    content=>template('httpd/vhost.conf.erb'),
  }
}
