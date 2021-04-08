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
  Variant[String[1], Array[String[1]]] $key,
  Variant[String[1], Boolean] $value,
  Stdlib::Absolutepath $path,
  String[1] $user,
  String[1] $group = $user,
) {
  $type = $value ? {
    Boolean => 'boolean',
    String  => 'string',
    default => fail('Undefined type')
  }
  $key_as_arg = [$key].flatten.map |$name| { "${name.shell_escape()}" }.join(' ')
  nextcloud::occ::exec { "config ${title}":
    args   => "config:system:set ${key_as_arg} --value=${value.shell_escape()} --type=${type.shell_escape()}",
    path   => $path,
    user   => $user,
    group  => $group,
    unless => "/usr/bin/test \"$(/usr/bin/php ${path}/occ config:system:get ${key_as_arg})\" = ${value.shell_escape()}",
  }
}
