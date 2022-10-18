# @summary Create config files and setup sources directory
#
# This creates custom configuration files then setup current sources directory
#
# @example
#   include nextcloud::config
class nextcloud::config {
  include nextcloud

  assert_private()

  file { $nextcloud::config_dir:
    ensure => directory,
    owner  => $nextcloud::user,
    group  => $nextcloud::group,
    mode   => '0750',
  }

  file { "${nextcloud::config_dir}/custom.config.php":
    ensure  => file,
    owner   => $nextcloud::user,
    group   => $nextcloud::group,
    mode    => '0640',
    content => epp('nextcloud/custom.config.php.epp')
  }
}
