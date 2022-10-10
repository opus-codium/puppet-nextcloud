# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nextcloud::base
class nextcloud::base {
  include nextcloud

  assert_private()

  user { $nextcloud::user:
    ensure     => present,
    home       => $nextcloud::base_dir,
    system     => true,
    managehome => true,
  }

  file { $nextcloud::data_dir:
    ensure => directory,
    owner  => $nextcloud::user,
    group  => $nextcloud::group,
    mode   => '0750',
  }
}
