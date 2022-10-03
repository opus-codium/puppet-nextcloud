class nextcloud::upgrade(
  String[1] $version,
) {
  $nextcloud_facts = $facts['nextcloud']

  if $nextcloud_facts == undef {
    fail('Nextcloud is not installed, abort!')
  }

  $base_dir            = $nextcloud_facts['path']
  $persistent_data_dir = "${base_dir}/persistent-data"
  $data_dir            = "${persistent_data_dir}/data"
  $config_dir          = "${persistent_data_dir}/config"
  $config_main_file    = "${config_dir}/main.php"
  $apps_dir            = "${persistent_data_dir}/apps"
  $current_version_dir = "${base_dir}/current"

  $user = $nextcloud_facts['user']
  $group = $nextcloud_facts['group']

  $source_next_dir = "${base_dir}/src/nextcloud-${version}"
  $source_current_dir = "${base_dir}/src/nextcloud-${facts['nextcloud_version']}"

  $services_to_restart_after_upgrade = $nextcloud_facts['services_to_restart_after_upgrade']

  exec { 'occ maintenance on':
    command     => "/usr/local/bin/occ maintenance:mode --on",
    cwd         => $current_version_dir,
    user        => 'root', # The wrapper relies on sudo to execute each parts.
    environment => [ 'OC_CONFIG_WRITABLE=1' ],
  }
  -> nextcloud::download { $version:
    path => $base_dir,
  }
  -> nextcloud::setup { $source_next_dir:
    config_main_file => $config_main_file,
    config_dir       => $config_dir,
    apps_dir         => $apps_dir,
  }
  -> file { $current_version_dir:
    ensure => link,
    target => $source_next_dir,
  }
  -> exec { 'occ upgrade':
    command     => "/usr/local/bin/occ upgrade",
    cwd         => $current_version_dir,
    user        => 'root', # The wrapper relies on sudo to execute each parts.
    environment => [ 'OC_CONFIG_WRITABLE=1' ],
  }
  -> class { 'nextcloud::facts::version':
    version => $version,
  }
  -> exec { 'occ maintenance off':
    command     => "/usr/local/bin/occ maintenance:mode --off",
    cwd         => $current_version_dir,
    user        => 'root', # The wrapper relies on sudo to execute each parts.
    environment => [ 'OC_CONFIG_WRITABLE=1' ],
  }
  -> nextcloud::htaccess { $current_version_dir: # Nextcloud 23+ wants maintenance mode to be turn off before running any `occ` command… Dumb isnt it?
    user  => $user,
    group => $group,
  }

  Exec['occ upgrade'] ~> Nextcloud::Htaccess[$current_version_dir]

  service { $services_to_restart_after_upgrade:
    ensure => 'running',
  }
  Exec['occ upgrade'] ~> Service[$services_to_restart_after_upgrade]
}
