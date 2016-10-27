#
#
class samanage::params {
  $conf_dir    = $::kernel ? {
    'FreeBSD' => '/usr/local/etc/ocsinventory',
    default   => '/etc/ocsinventory',
  }
  $conf_file   = $::kernel ? {
    'FreeBSD' => "${conf_dir}/ocsinventory-agent.cfg",
    default   => "${conf_dir}/ocsinventory-agent.cfg",
  }
  $module_file = $::kernel ? {
    'FreeBSD' => "${conf_dir}/modules.conf",
    default   => "${conf_dir}/modules.conf",
  }
  $basevardir  = $::kernel ? {
    'FreeBSD' => '/var/ocsinventory-agent',
    default   => '/var/lib/ocsinventory-agent',
  }
  $ca_path     = $::kernel ? {
    'FreeBSD' => '/usr/local/share/certs/ca-root-nss.crt',
    default   => '/etc/ssl/certs/',
  }
  $logfile     = $::kernel ? {
    'FreeBSD' => '/var/log/ocsinventory.log',
    default   => '/var/log/ocsinventory-client/ocsinventory.log',
  }
  $packages    = $::kernel ? {
    'FreeBSD' => ['p5-XML-Simple', 'p5-libwww', 'p5-Net-IP',
      'p5-Proc-Daemon', 'net-mgmt/ocsinventory-agent'],
    default   => ['libxml-simple-perl','libnet-snmp-perl',
      'libnet-ip-perl', 'ocsinventory-agent'],
  }
  $fqdn_file   = $::kernel ? {
    'FreeBSD' => '/usr/local/lib/perl5/site_perl/Ocsinventory/Agent/Backend/OS/Generic/Hostname.pm',
    default   => '/usr/share/perl5/Ocsinventory/Agent/Backend/OS/Generic/Hostname.pm',
  }
}
