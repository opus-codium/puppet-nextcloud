# @summary It setups a nextcloud sources directory
#
# This create links from nextcloud sources directory for config files and apps.
#
# @example
#   nextcloud::setup { '/srv/www/nextcloud.example.com/src/nextcloud-13.0.12':
#     config_main_file => '/srv/www/nextcloud.example.com/persistent-data/config/main.php',
#     config_dir       => '/srv/www/nextcloud.example.com/persistent-data/config',
#     apps_dir         => '/srv/www/nextcloud.example.com/persistent-data/apps',
#   }
define nextcloud::setup (
  Stdlib::Absolutepath $config_main_file,
  Stdlib::Absolutepath $config_dir,
  Stdlib::Absolutepath $apps_dir,
) {
  $source_dir = $title

  file {"${source_dir}/config/config.php":
    ensure => link,
    target => $config_main_file,
  }

  file { "${source_dir}/config/custom.config.php":
    ensure => link,
    target => "${config_dir}/custom.php"
  }

  file { "${source_dir}/extra-apps":
    ensure => link,
    target => $apps_dir,
  }
}
