# @summary Run Nextcloud CLI tool
#
# @example
#   nextcloud::occ::exec { 'enable maintenance mode':
#     args  => 'maintenance:mode --on',
#     path  => '/srv/www/nextcloud.example.com',
#     user  => 'nextcloud',
#     group => 'nextcloud',
#   }
define nextcloud::occ::exec (
  Stdlib::Absolutepath $path,
  String[1] $user,
  String[1] $group = $user,
  String[1] $args = $title,
  Boolean $refreshonly = false,
  Optional[String[1]] $unless = undef,
) {
  exec { "nextcloud::occ::exec ${title}":
    command     => "/usr/bin/php ${path}/occ ${args}",
    cwd         => $path,
    user        => $user,
    group       => $group,
    unless      => $unless,
    refreshonly => $refreshonly,
  }
}
