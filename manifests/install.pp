# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nextcloud::install
class nextcloud::install (
  String[1] $initial_admin_password,
  String[1] $initial_admin_username = 'admin',
  String[1] $initial_version        = '13.0.4'
) {
  include nextcloud
  include nextcloud::database

  $nextcloud_facts = $facts['nextcloud']

  if $nextcloud_facts == undef {
    nextcloud::download { $initial_version:
      path => $nextcloud::base_dir,
    }

    $install_dir = "${nextcloud::base_dir}/src/nextcloud-${initial_version}"

    file { $nextcloud::current_version_dir:
      ensure  => link,
      target  => $install_dir,
      require => Nextcloud::Download[$initial_version],
    }

    File[$nextcloud::current_version_dir] -> Class['nextcloud::config']

    $install_configuration = {
      'database'      => 'pgsql',
      'database-name' => $nextcloud::database::database,
      'database-user' => $nextcloud::database::user,
      'database-pass' => $nextcloud::database::password,
      'admin-user'    => $initial_admin_username,
      'admin-pass'    => $initial_admin_password,
      'data-dir'      => $nextcloud::data_dir,
    }

    $install_params = $install_configuration.map |$option, $value| { "--${option} '${value}'" }.join(' ')

    nextcloud::occ::exec { 'nextcloud-install':
      args  => "maintenance:install ${install_params}",
      path  => $nextcloud::current_version_dir,
      user  => $nextcloud::user,
      group => $nextcloud::group,
    }
    Class['nextcloud::config'] -> Nextcloud::Occ::Exec['nextcloud-install']

    nextcloud::htaccess { $nextcloud::current_version_dir:
      user  => $nextcloud::user,
      group => $nextcloud::group,
    }
    Nextcloud::Occ::Exec['nextcloud-install'] ~> Nextcloud::Htaccess[$nextcloud::current_version_dir]

    nextcloud::facts { 'set nextcloud facts':
      version => $initial_version,
      path    => $nextcloud::base_dir,
      user    => $nextcloud::user,
      group   => $nextcloud::group,
    }
    Nextcloud::Occ::Exec['nextcloud-install'] -> Nextcloud::Facts['set nextcloud facts']
  }
}
