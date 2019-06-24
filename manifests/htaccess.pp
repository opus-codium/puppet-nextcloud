# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   nextcloud::htaccess { 'namevar': }
define nextcloud::htaccess (
  String[1] $user,
  String[1] $group,
  Stdlib::Absolutepath $path = $name,
) {
  $htaccess_file = "${path}/.htaccess"
  file { $htaccess_file:
    ensure => file,
    owner  => $user,
    group  => $group,
    mode   => '0644',
  }

  nextcloud::occ::exec { 'maintenance:update:htaccess':
    path        => $path,
    user        => $user,
    group       => $group,
    refreshonly => true,
  }
  File[$htaccess_file] -> Nextcloud::Occ::Exec['maintenance:update:htaccess']
}
