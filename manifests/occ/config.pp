# @summary Run Nextcloud CLI tool to set config:system key
#
# This defined type sets config:system key through `occ` tool.
# Note: `occ` will alter its main `config.php` file according to provided key:values
#
# @example
#   nextcloud::occ::config { 'enable read only mode':
#     key   => 'config_is_read_only',
#     value => true,
#     path  => '/srv/www/nextcloud.example.com',
#     user  => 'nextcloud',
#     group => 'nextcloud',
#   }
define nextcloud::occ::config (
  Variant[String, Array[String]] $key,
  Variant[String, Boolean] $value,
  String $path,
  String $user,
  String $group = $user,
) {
  $type = $value ? {
    Boolean => 'boolean',
    String  => 'string',
    default => fail('Undefined type')
  }
  $key_as_arg = [$key].flatten.map |$name| { "'${name}'" }.join(' ')
  exec { "occ_config-${title}":
    command => "/usr/bin/php ${path}/occ config:system:set ${key_as_arg} --value='${value}' --type='${type}'",
    cwd     => $path,
    user    => $user,
    group   => $group,
    unless  => "/usr/bin/test \"$(/usr/bin/php ${path}/occ config:system:get ${key_as_arg})\" = \"${value}\"",
  }
}
