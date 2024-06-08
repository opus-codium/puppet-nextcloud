# @summary Manage Nextcloud dependencies
#
# @api private
class nextcloud::dependencies (
  String[1] $libmagickcore_extra_package_name,
) {
  assert_private()

  $php_packages = if versioncmp($nextcloud::php_version, '8.0') >= 0 {
    [
      "php${nextcloud::php_version}",
      "php${nextcloud::php_version}-bcmath",
      "php${nextcloud::php_version}-bz2",
      "php${nextcloud::php_version}-curl",
      "php${nextcloud::php_version}-gd",
      "php${nextcloud::php_version}-gmp",
      "php${nextcloud::php_version}-intl",
      "php${nextcloud::php_version}-mbstring",
      "php${nextcloud::php_version}-pgsql",
      "php${nextcloud::php_version}-xml",
      "php${nextcloud::php_version}-zip",
    ]
  } else {
    [
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
  }

  $requirements = [
    'bzip2',
    $libmagickcore_extra_package_name,
    'php-apcu',
    'php-imagick',
  ] + $php_packages

  package { $requirements:
    ensure => installed,
  }
}
