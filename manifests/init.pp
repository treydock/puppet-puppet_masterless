#
class puppet_masterless (
  # Puppet config
  $base_dir                = '/opt/puppet',
  $conf_dir                = undef,
  $environment_path        = undef,
  # PuppetDB config
  $puppetdb_version        = 'present',
  $puppetdb_server         = "puppetdb.${::domain}",

  $papply_path             = '/usr/sbin/papply',
  $papply_early_tags       = ['no_such_tag'],
  $papply_wait_for_mounts  = [],
  #$fact_refresh_path       = '/usr/libexec/mcollective/refresh-mcollective-metadata',
  $foreman_url             = "foreman.${::domain}",
) {

  #$_foreman_masterless_path = pick($foreman_masterless_path, "${::rubysitedir}/puppet/reports/foreman_masterless.rb")
  $_foreman_masterless_path = "${::rubysitedir}/puppet/reports/foreman_masterless.rb"
  $_conf_dir = pick($conf_dir, "${base_dir}/conf")
  $_sbin_dir = "${base_dir}/sbin"
  $_environment_path = pick($environment_path, "${base_dir}/environments")
  $_puppet_conf = "${_conf_dir}/puppet.conf"
  $_puppetdb_conf = "${_conf_dir}/puppetdb.conf"
  $_hiera_config = "${_conf_dir}/hiera.yaml"

  file { $base_dir:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
  }
  file { $_conf_dir:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  file { $_environment_path:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  file { $_sbin_dir:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  #file { "${_conf_dir}/node.rb":
  #  ensure => 'file',
  #  owner  => 'root',
  #  group  => 'root',
  #  mode   => '0755',
  #  source => 'puppet:///modules/puppet_masterless/node.rb',
  #}
  #file { "${_conf_dir}/routes.yaml":
  #  ensure => 'file',
  #  owner  => 'root',
  #  group  => 'root',
  #  mode   => '0644',
  #  source => 'puppet:///modules/puppet_masterless/routes.yaml',
  #}

  #$_puppetdb_conf_defaults = { 'path' => $_puppetdb_conf, 'require' => File[$_conf_dir] }
  #$_puppetdb_config = {
  #  'main' => {
  #    'port' => '8081',
  #    'soft_write_failure' => 'false',
  #    'server' => $puppetdb_server,
  #  }
  #}
  #create_ini_settings($_puppetdb_config, $_puppetdb_conf_defaults)
  #$_puppet_conf_defaults = { 'path' => $_puppet_conf, 'require' => File[$_conf_dir] }
  #$_puppet_config = {
  #  'main' => {
  #    'logdir'                => '/var/log/puppetlabs',
  #    'rundir'                => '/var/run/puppetlabs',
  #    'ssldir'                => '$vardir/ssl',
  #    'environmentpath'       => $_environment_path,
  #    'hiera_config'          => $_hiera_config,
  #    'show_diff'             => 'false',
  #    'report'                => 'false',
  #    #'reports'               => 'foreman_masterless',
  #    'storeconfigs'          => 'false',
  #    #'storeconfigs_backend'  => 'puppetdb',
  #    'parser'                => 'future',
  #  }
  #}
  #create_ini_settings($_puppet_config, $_puppet_conf_defaults)

  #file { $_puppetdb_conf:
  #  ensure  => 'file',
  #  owner   => 'root',
  #  group   => 'root',
  #  mode    => '0644',
  #  content => template('puppet_masterless/puppetdb.conf.erb'),
  #}

  file { $_puppet_conf:
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('puppet_masterless/puppet.conf.erb'),
  }

  #package { 'puppetdb-termini':
  #  ensure  => $puppetdb_version,
  #}

  file { $papply_path:
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('puppet_masterless/papply.sh.erb'),
  }

  file { "${_sbin_dir}/papply-service":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('puppet_masterless/service-scripts/papply.sh.erb'),
  }

  if $::service_provider == 'systemd' {
    systemd::unit_file { 'papply-fstab.service':
      ensure  => 'absent',
    }
    systemd::unit_file { 'papply-early.service':
      content => template('puppet_masterless/systemd/papply-early.service.erb'),
      before  => Service['papply-early'],
    }
    systemd::unit_file { 'papply.service':
      content => template('puppet_masterless/systemd/papply.service.erb'),
      before  => Service['papply'],
    }
  } else {
    #
  }

  service { 'papply-early':
    ensure => undef,
    enable => true,
  }
  service { 'papply':
    ensure => undef,
    enable => true,
  }

  file { '/etc/puppetlabs/puppet/foreman.yaml':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('puppet_masterless/foreman.yaml.erb'),
  }

}
