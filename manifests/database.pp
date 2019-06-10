# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nextcloud::database
class nextcloud::database (
  String $password,
  String $user     = 'nextcloud',
  String $database = 'nextcloud',
) {
  include postgresql::server

  postgresql::server::db { $database:
    user     => $user,
    password => postgresql_password($user, $password),
  }
}
