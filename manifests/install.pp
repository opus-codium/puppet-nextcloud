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
    $archive_basename = "nextcloud-${initial_version}"
    $archive_name     = "${archive_basename}.tar.bz2"
    $archive_source   = "https://download.nextcloud.com/server/releases/${archive_name}"
    $source_dir       = "${nextcloud::base_dir}/src"
    $extract_dir      = "${$source_dir}/${archive_basename}"

    file { [$source_dir, $extract_dir]:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }

    archive { $archive_name:
      path            => "/tmp/${archive_name}",
      source          => $archive_source,
      extract         => true,
      extract_command => 'tar xfa %s --strip-components=1',
      extract_path    => $extract_dir,
      creates         => "${extract_dir}/index.php",
      cleanup         => true,
      require         => File[$extract_dir],
    }

    $current_version_dir = "${nextcloud::base_dir}/current"

    file { $current_version_dir:
      ensure  => link,
      target  => $extract_dir,
      require => Archive[$archive_name],
    }
    -> file {"${current_version_dir}/config/config.php":
      ensure => link,
      target => $nextcloud::config_main_file,
    }
    -> file { "${current_version_dir}/config":
      ensure => directory,
      owner  => $nextcloud::user,
      group  => $nextcloud::group,
      mode   => '0750',
    }

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

    exec { 'nextcloud-install':
      command => "/usr/bin/php ${current_version_dir}/occ maintenance:install ${install_params}",
      cwd     => $current_version_dir,
      user    => $nextcloud::user,
      group   => $nextcloud::group,
    }
  }
}
