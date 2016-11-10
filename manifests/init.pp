# == Class: samanage
#
class samanage (
  Tea::Absolutepath $conf_dir    = $::samanage::params::conf_dir,
  Tea::Absolutepath $conf_file   = $::samanage::params::conf_file,
  Tea::Absolutepath $module_file = $::samanage::params::module_file,
  Tea::Absolutepath $basevardir  = $::samanage::params::basevardir,
  Boolean           $ssl         = true,
  Boolean           $debug       = false,
  Tea::HTTPUrl      $server      = 'https://inventory.samanage.com/ocsinventory',
  Tea::Absolutepath $ca_path     = $::samanage::params::ca_path,
  Tea::Absolutepath $logfile     = $::samanage::params::logfile,
  Array[String]     $packages    = $::samanage::params::packages,
  Boolean           $enable_cron = true,
  Boolean           $use_fqdn    = true,
  Tea::Absolutepath $fqdn_file   = $::samanage::params::fqdn_file,
  Optional[String]  $ocs_tag     = undef,
) inherits samanage::params {

  ensure_packages($packages)
  file {[$basevardir, $conf_dir]:
    ensure  => directory,
    require => Package[$packages],
  }
  file {$conf_file:
    ensure  => present,
    content => template('samanage/etc/ocsinventory-agent/ocsinventory-agent.cfg.erb'),
    require => Package[$packages],
  }
  file {$module_file:
    ensure  => present,
    content => template('samanage/etc/ocsinventory-agent/modules.conf.erb'),
    require => Package[$packages],
  }
  if $enable_cron {
    cron{ 'ocsinventory-agent run':
      command => 'ocsinventory-agent --lazy &> /dev/null',
      hour    => fqdn_rand(23),
      minute  => fqdn_rand(59),
      require => Package[$packages],
    }
  }
  if $use_fqdn {
    #This is a bit of a hack but i can't think of a better way
    file_line {'patch ociinventory to use the fqdn for NAME':
      path      => $fqdn_file,
      line      => '  #$hostname =~ s/\..*//; # keep just the hostname',
      match     => '.*keep just the hostname.*',
      subscribe => Package[$packages],
    }
  }
}
