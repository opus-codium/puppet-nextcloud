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
files_dir="$(dirname $0)/../files"

# Target file in Nextcloud to overwrite current config
config_overwrite_file="${nextcloud_path}/current/config/z-overwrite.config.php"

# Copy it from module to Nextcloud sources
cat "${files_dir}/enable-appstore.config.php" | sudo tee $config_overwrite_file > /dev/null

# The output
/usr/local/bin/occ app:update --showonly --all

# Clean the config overwrite
sudo rm $config_overwrite_file
