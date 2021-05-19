plan nextcloud::upgrade (
  TargetSpec $targets,
  String[1] $version,
) {
  # Install the puppet-agent package if Puppet is not detected.
  # Copy over custom facts from the Bolt modulepath.
  # Run the `facter` command line tool to gather node information.
  $targets.apply_prep
  $results = apply($targets) {
    class { 'nextcloud::upgrade':
      version => $version,
    }
  }
  $results.each |$result| {
    $report = $result.report

    unless $report == undef {
      out::message("Host: ${result.report['host']}")
      $result.report['logs'].each |$log| {
        out::message("  ${log['time']} [${log['level']}] ${log['source']}: ${log['message']}")
      }
    } else {
      # During PDK tests, 'report' is not filled (ie. set to undef)
      out::message("You should not see this message outside tests")
    }
  }
}
