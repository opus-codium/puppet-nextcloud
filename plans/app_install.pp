plan nextcloud::app_install(
  TargetSpec $nodes,
  String[1] $application,
) {
  # Install the puppet-agent package if Puppet is not detected.
  # Copy over custom facts from the Bolt modulepath.
  # Run the `facter` command line tool to gather node information.
  $nodes.apply_prep
  $results = apply($nodes) {
    $nextcloud_facts = $facts['nextcloud']

    $current_version_dir = "${nextcloud_facts['path']}/current"

    $user = $nextcloud_facts['user']
    $group = $nextcloud_facts['group']

    nextcloud::occ::config { 'enable app store':
      key   => 'appstoreenabled',
      value => true,
      path  => $current_version_dir,
      user  => $user,
      group => $group,
    }
    -> nextcloud::occ::exec { "install ${application}":
      args  => "app:install ${application}",
      path  => $current_version_dir,
      user  => $user,
      group => $group,
    }
    -> nextcloud::occ::config { 'disable app store':
      key   => 'appstoreenabled',
      value => false,
      path  => $current_version_dir,
      user  => $user,
      group => $group,
    }
  }
  $results.each |$result| {
    out::message("Host: ${result.report['host']}")
    $result.report['logs'].each |$log| {
      out::message("  ${log['time']} [${log['level']}] ${log['source']}: ${log['message']}")
    }
  }
}
