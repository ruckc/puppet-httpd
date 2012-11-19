define httpd::conf(
  $content,
  $filename="/etc/httpd/conf.d/${title}.conf",
) {
  file{$filename:
    ensure =>file,
    owner  =>root,
    group  =>apache,
    mode   =>'0440',
    content=>$content,
    notify =>Service['httpd'],
  }
}
