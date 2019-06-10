# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nextcloud
class nextcloud (
  String[1] $hostname,
  String[1] $user      = 'nextcloud',
  String[1] $group     = $user,
){
  $base_dir            = "/srv/www/${hostname}"
  $persistent_data_dir = "${base_dir}/persistent-data"
  $data_dir            = "${persistent_data_dir}/data"
  $config_dir          = "${persistent_data_dir}/config"
  $config_main_file    = "${config_dir}/main.php"

  contain nextcloud::database
  contain nextcloud::dependencies
  contain nextcloud::base
  contain nextcloud::install

  Class['nextcloud::dependencies']
  -> Class['nextcloud::database']
  -> Class['nextcloud::base']
  -> Class['nextcloud::install']
}
