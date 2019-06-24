# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   nextcloud::facts { 'namevar': }
define nextcloud::facts (
  String[1] $version,
  Stdlib::Absolutepath $path,
  String[1] $user,
  String[1] $group,
) {
  $facts_file = '/etc/puppetlabs/facter/facts.d/nextcloud.yaml'
  file { $facts_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => epp('nextcloud/facts.yaml.epp', {
      version => $version,
      path    => $path,
      user    => $user,
      group   => $group,
    })
  }
}
