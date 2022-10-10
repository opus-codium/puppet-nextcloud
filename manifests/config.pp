# @summary Create config files and setup sources directory
#
# This creates custom configuration files then setup current sources directory
#
# @example
#   include nextcloud::config
class nextcloud::config {
  include nextcloud

  assert_private()

  file { "${nextcloud::config_dir}/custom.config.php":
    ensure  => file,
    owner   => 'root',
    group   => $nextcloud::group,
    mode    => '0640',
    content => epp('nextcloud/custom.config.php.epp')
  }
  -> nextcloud::setup { $nextcloud::current_version_dir:
    config_main_file => $nextcloud::config_main_file,
    config_dir       => $nextcloud::config_dir,
    apps_dir         => $nextcloud::apps_dir,
  }
}
