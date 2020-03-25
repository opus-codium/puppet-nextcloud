# @summary This class sets nextcloud version fact only
#
# This class creates a YAML structured data fact file, re-used and overwritten by `upgrade` plan.
#
class nextcloud::facts::version (
  String[1] $version,
) {

  assert_private()

  $facts_file = '/etc/puppetlabs/facter/facts.d/nextcloud_version.yaml'

  $facts_hash = {
    'nextcloud_version' => $version,
  }

  file { $facts_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => $facts_hash.to_yaml,
  }
}
