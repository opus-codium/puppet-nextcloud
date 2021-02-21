#!/bin/sh

error () {
  echo $1 >&2
  exit 1
}

[ -x /usr/local/bin/occ ] || error 'Nextcloud is not installed on this node.'

occ_maintenance_option=''
[ -n $PT_mode ] && occ_maintenance_option="--${PT_mode}"

/usr/local/bin/occ maintenance:mode $occ_maintenance_option
