# @summary Manage Nextcloud configuration
#
# @api private
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
    content => epp('nextcloud/custom.config.php.epp'),
  }
}
