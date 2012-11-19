define httpd::defaultvhosts($port=$title) {
  @httpd::vhost{"${::fqdn}-${port}":
    servername=>$::fqdn,
    port      =>$port,
    includedir=>"default-${port}",
  }
}
