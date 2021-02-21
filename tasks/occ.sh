#!/bin/sh

error () {
  echo $1 >&2
  exit 1
}

[ -x /usr/local/bin/occ ] || error 'Nextcloud is not installed on this node.'

occ_command="${PT_command}"

/usr/local/bin/occ $occ_command
