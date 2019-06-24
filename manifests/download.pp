# @summary Download specified nextcloud version
#
# It downloads a specified version into "${path}/src/nextcloud-${version}".
#
# @example
#   nextcloud::download { '13.0.12':
#     path => '/srv/www/nextcloud.example.com',
#   }
define nextcloud::download (
  Stdlib::Absolutepath $path,
) {
  $version = $title

  $archive_basename = "nextcloud-${version}"
  $archive_name     = "${archive_basename}.tar.bz2"
  $archive_source   = "https://download.nextcloud.com/server/releases/${archive_name}"
  $source_dir       = "${path}/src"
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
}
