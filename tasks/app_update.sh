#!/bin/sh

set -xe

error () {
  echo $1 >&2
  exit 1
}

[ -x /usr/local/bin/occ ] || error 'Nextcloud is not installed on this node.'

# Grab user and path used by Nextcloud
nextcloud_path=$(sudo /opt/puppetlabs/bin/facter nextcloud.path)

# Module files location
files_dir="${PT__installdir}/nextcloud/files"

# Target file in Nextcloud to overwrite current config
config_overwrite_file="${nextcloud_path}/current/config/z-overwrite.config.php"

# Copy it from module to Nextcloud sources
sudo tee $config_overwrite_file < "${files_dir}/enable-appstore.config.php" > /dev/null

# The output
/usr/local/bin/occ app:update --all

# Clean the config overwrite
sudo rm $config_overwrite_file
