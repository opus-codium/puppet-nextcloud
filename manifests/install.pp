# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nextcloud::install
class nextcloud::install {
  include nextcloud
  include nextcloud::database

  assert_private()

  $nextcloud_facts = $facts['nextcloud']

  if $nextcloud_facts == undef {
    $base_name = fqdn_rand_string(10)
    $nextcloud_initial_admin_username = "admin-${fqdn_rand_string(5)}"
    $nextcloud_initial_admin_password = fqdn_rand_string(10)

    nextcloud::download { $nextcloud::initial_version:
      path => $nextcloud::base_dir,
    }

    $install_dir = "${nextcloud::base_dir}/src/nextcloud-${nextcloud::initial_version}"

    file { $nextcloud::current_version_dir:
      ensure  => link,
      target  => $install_dir,
      require => Nextcloud::Download[$nextcloud::initial_version],
    }

    File[$nextcloud::current_version_dir] -> Class['nextcloud::config']

    $install_configuration = {
      'database'      => 'pgsql',
      'database-name' => $nextcloud::database_name,
      'database-user' => $nextcloud::database_username,
      'database-pass' => $nextcloud::database_password,
      'admin-user'    => $nextcloud_initial_admin_username,
      'admin-pass'    => $nextcloud_initial_admin_password,
      'data-dir'      => $nextcloud::data_dir,
    }

    $install_params = $install_configuration.map |$option, $value| { "--${option} ${value.shell_escape()}" }.join(' ')

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

    nextcloud::occ::exec { 'delete-admin':
      args  => "user:delete ${nextcloud_initial_admin_username}",
      path  => $nextcloud::current_version_dir,
      user  => $nextcloud::user,
      group => $nextcloud::group,
    }
    Nextcloud::Occ::Exec['nextcloud-install'] -> Nextcloud::Occ::Exec['delete-admin']

    class { 'nextcloud::facts::version':
      version => $nextcloud::initial_version
    }
    Nextcloud::Occ::Exec['nextcloud-install'] -> Class['nextcloud::facts::version']
  } else {
    file { "${nextcloud::current_version_dir}/config/CAN_INSTALL":
      ensure => absent,
    }
  }
}
