# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nextcloud::database
class nextcloud::database {
  include nextcloud
  include postgresql::server

  assert_private()

  postgresql::server::db { $nextcloud::database_name:
    user     => $nextcloud::database_username,
    password => postgresql_password($nextcloud::database_username, $nextcloud::database_password),
  }
}
