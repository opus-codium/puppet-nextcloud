# @summary Manage Nextcloud dependencies
class nextcloud::dependencies {
  assert_private()

  $requirements = [
    'bzip2',
    'libmagickcore-6.q16-6-extra',
    'php-apcu',
    'php-imagick',
    "php${nextcloud::php_version}",
    "php${nextcloud::php_version}-bcmath",
    "php${nextcloud::php_version}-bz2",
    "php${nextcloud::php_version}-curl",
    "php${nextcloud::php_version}-gd",
    "php${nextcloud::php_version}-gmp",
    "php${nextcloud::php_version}-intl",
    "php${nextcloud::php_version}-json",
    "php${nextcloud::php_version}-mbstring",
    "php${nextcloud::php_version}-pgsql",
    "php${nextcloud::php_version}-xml",
    "php${nextcloud::php_version}-zip",
  ]
  package { $requirements:
    ensure => installed,
  }
}
