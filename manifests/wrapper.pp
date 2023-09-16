# @summary Manage Nextcloup wrapper
#
# This creates a wrapper script to allow system administrator to run
# `occ` command without specifying nextcloud's user and path.
class nextcloud::wrapper {
  include nextcloud

  assert_private()

  file { '/usr/local/bin/occ':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => epp('nextcloud/occ.epp'),
  }
}
