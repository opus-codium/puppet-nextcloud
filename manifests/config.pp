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
}
