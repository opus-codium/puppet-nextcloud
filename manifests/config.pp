# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nextcloud::config
class nextcloud::config {
  include nextcloud

  file {"${nextcloud::current_version_dir}/config/config.php":
    ensure => link,
    target => $nextcloud::config_main_file,
  }

  file { "${nextcloud::config_dir}/custom.php":
    ensure  => file,
    owner   => 'root',
    group   => $nextcloud::group,
    mode    => '0640',
    content => epp('nextcloud/custom.config.php.epp')
  }
  -> file { "${nextcloud::current_version_dir}/config/custom.config.php":
    ensure => link,
    target => "${nextcloud::config_dir}/custom.php"
  }

  file { "${nextcloud::current_version_dir}/extra-apps":
    ensure => link,
    target => $nextcloud::apps_dir,
  }
}
