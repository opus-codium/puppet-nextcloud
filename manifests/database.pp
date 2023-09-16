# @summary Manage Nextcloud database
class nextcloud::database {
  include nextcloud
  include postgresql::server

  assert_private()

  postgresql::server::db { $nextcloud::database_name:
    user     => $nextcloud::database_username,
    password => postgresql::postgresql_password($nextcloud::database_username, $nextcloud::database_password),
  }
}
