plan nextcloud::upgrade(
  TargetSpec $nodes,
  String[1] $version,
) {
  # Install the puppet-agent package if Puppet is not detected.
  # Copy over custom facts from the Bolt modulepath.
  # Run the `facter` command line tool to gather node information.
  $nodes.apply_prep
  $results = apply($nodes) {
    $nextcloud_facts = $facts['nextcloud']

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

    nextcloud::occ::exec { 'enable maintenance mode':
      args  => 'maintenance:mode --on',
      path  => $source_current_dir,
      user  => $user,
      group => $group,
    }
    -> nextcloud::occ::config { 'disable read only mode':
      key   => 'config_is_read_only',
      value => false,
      path  => $source_current_dir,
      user  => $user,
      group => $group,
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
    -> nextcloud::occ::exec { 'upgrade':
      args  => 'upgrade',
      path  => $current_version_dir,
      user  => $user,
      group => $group,
    }
    -> nextcloud::htaccess { $current_version_dir:
      user  => $user,
      group => $group,
    }
    -> class { 'nextcloud::facts::version':
      version => $version,
    }
    -> nextcloud::occ::config { 'enable read only mode':
      key   => 'config_is_read_only',
      value => true,
      path  => $current_version_dir,
      user  => $user,
      group => $group,
    }
    -> nextcloud::occ::exec { 'disable maintenance mode':
      args  => 'maintenance:mode --off',
      path  => $current_version_dir,
      user  => $user,
      group => $group,
    }

    Nextcloud::Occ::Exec['upgrade'] ~> Nextcloud::Htaccess[$current_version_dir]

    service { $services_to_restart_after_upgrade:
      ensure => 'running',
    }
    Nextcloud::Occ::Exec['upgrade'] ~> Service[$services_to_restart_after_upgrade]
  }
  $results.each |$result| {
    notice("Host: ${result.report['host']}")
    $result.report['logs'].each |$log| {
      notice("  ${log['time']} [${log['level']}] ${log['source']}: ${log['message']}")
    }
  }
}
