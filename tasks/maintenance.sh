#!/bin/sh

error () {
  echo $1 >&2
  exit 1
}

nextcloud_path=$(/opt/puppetlabs/bin/facter nextcloud.path)

[ -z $nextcloud_path ] && error 'Nextcloud is not installed on this node.'

nextcloud_user=$(/usr/bin/stat -c '%U' "${nextcloud_path}/current/.htaccess")

occ_maintenance_option=''
[ -n $PT_mode ] && occ_maintenance_option="--${PT_mode}"

cd $nextcloud_path/current && sudo -u $nextcloud_user /usr/bin/php occ maintenance:mode $occ_maintenance_option
