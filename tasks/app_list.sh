#!/bin/sh

error () {
  echo $1 >&2
  exit 1
}

[ -x /usr/local/bin/occ ] || error 'Nextcloud is not installed on this node.'

/usr/local/bin/occ app:list --shipped=${PT_shipped}
