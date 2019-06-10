# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nextcloud
class nextcloud (
  String[1] $hostname,
){
  $base_dir            = "/srv/www/${hostname}"
  $persistent_data_dir = "${base_dir}/persistent-data"
  $data_dir            = "${persistent_data_dir}/data"
  $config_dir          = "${persistent_data_dir}/config"

  contain nextcloud::database
}
