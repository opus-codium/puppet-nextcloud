# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nextcloud::base
class nextcloud::base {
  include nextcloud

  user { $nextcloud::user:
    ensure     => present,
    home       => $nextcloud::base_dir,
    system     => true,
    managehome => true,
  }

  file { $nextcloud::base_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  -> file { $nextcloud::persistent_data_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0751',
  }
  -> file { $nextcloud::data_dir:
    ensure => directory,
    owner  => $nextcloud::user,
    group  => $nextcloud::group,
    mode   => '0750',
  }
  -> file { $nextcloud::config_dir:
    ensure => directory,
    owner  => $nextcloud::user,
    group  => $nextcloud::group,
    mode   => '0750',
  }
  -> file { $nextcloud::config_main_file:
    ensure => file,
    owner  => $nextcloud::user,
    group  => $nextcloud::group,
    mode   => '0640',
  }
  -> file { $nextcloud::apps_dir:
    ensure => directory,
    owner  => $nextcloud::user,
    group  => $nextcloud::group,
    mode   => '0750',
  }
}
