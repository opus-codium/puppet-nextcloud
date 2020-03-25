# @summary This class sets nextcloud-related facts, except version
#
# This class creates a YAML structured data facts file, mainly re-used by `upgrade` plan.
#
# Important: We can not use the same file as nextcloud::facts::version due to the need of idempotency.
# 'version' is initially sets by installation, when overwritten through `upgrade` plan.
# BTW, other facts must be rewritten when relevant, for example:
# services that needs to be restarted must be updated after an OS upgrade: php7.0-fpm (stretch) to php7.2-fpm (buster)
#
# Addtionally, we can not use the same 'nextcloud' hash fact due to `facter` behaviour: it do not merge hash from multiple files.
#
class nextcloud::facts {

  assert_private()

  $facts_file = '/etc/puppetlabs/facter/facts.d/nextcloud.yaml'

  $facts_hash = {
    'nextcloud' => {
      'path'                              => $nextcloud::base_dir,
      'user'                              => $nextcloud::user,
      'group'                             => $nextcloud::group,
      'services_to_restart_after_upgrade' => $nextcloud::services_to_restart_after_upgrade,
    }
  }

  file { $facts_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => $facts_hash.to_yaml
  }
}
