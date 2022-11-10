# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nextcloud
class nextcloud (
  Stdlib::Fqdn $hostname,
  String[20] $database_password,
  String[3,3] $php_version,
  String[1] $database_username = 'nextcloud',
  String[1] $database_name = 'nextcloud',
  String[1] $user = 'nextcloud',
  String[1] $group = $user,
  Integer[0, 4] $log_level = 2,
  String[1] $trashbin_retention = 'auto',
  Array[String[1]] $services_to_restart_after_upgrade = [],
  Optional[Nextcloud::Iso639_1] $default_language = undef,
  Optional[Nextcloud::Iso3166_1_alpha_2] $default_phone_region = undef,
) {
  $base_dir            = "/srv/www/${hostname}"
  $persistent_data_dir = "${base_dir}/persistent-data"
  $data_dir            = "${persistent_data_dir}/data"
  $config_dir          = "${persistent_data_dir}/config"
  $apps_dir            = "${persistent_data_dir}/extra-apps"
  $current_version_dir = "${base_dir}/current"

  contain nextcloud::database
  contain nextcloud::dependencies
  contain nextcloud::base
  include nextcloud::config
  contain nextcloud::wrapper

  Class['nextcloud::dependencies']
  -> Class['nextcloud::database']
  -> Class['nextcloud::base']

  Class['nextcloud::base']
  -> Class['nextcloud::config']
  -> Class['nextcloud::wrapper']
}
