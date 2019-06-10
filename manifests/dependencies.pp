# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nextcloud::dependencies
class nextcloud::dependencies {
  $requirements = [
    'libmagickcore-6.q16-3-extra',
    'php-apcu',
    'php-imagick',
    'php7.0',
    'php7.0-bz2',
    'php7.0-curl',
    'php7.0-gd',
    'php7.0-intl',
    'php7.0-json',
    'php7.0-mbstring',
    'php7.0-mcrypt',
    'php7.0-pgsql',
    'php7.0-xml',
    'php7.0-zip',
  ]
  package { $requirements:
    ensure => installed,
  }
}
