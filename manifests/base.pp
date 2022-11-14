# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nextcloud::base
class nextcloud::base {
  include nextcloud

  assert_private()

  user { $nextcloud::user:
    ensure     => present,
    home       => $nextcloud::base_dir,
    system     => true,
    managehome => true,
  }

  file { $nextcloud::persistent_data_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0751',
  }
  -> file { $nextcloud::data_dir:
    ensure => directory,
    owner  => $nextcloud::user,
    group  => $nextcloud::group,
    mode   => '0750',
  }

  cron { 'nextcloud-cron':
    command => "/usr/bin/php -f ${nextcloud::current_version_dir}/cron.php",
    user    => $nextcloud::user,
    minute  => '*/15',
  }

  application::kind { 'nextcloud':
    before_deploy_content => @(SH),
      #!/bin/sh

      set -e

      occ() {
        if [ -f ../current/occ ]; then
          sudo -u ${USER_MAPPING_user} OC_CONFIG_WRITABLE=1 php ../current/occ "$@"
        fi
      }

      cat > .mtree << END
      /set type=dir uname=root gname=root mode=0755
      .               nochange
          config      uname=user gname=user mode=0750
          ..
          extra-apps  uname=user gname=user
          ..
      ..
      END
      if [ -f '../persistent-data/config/config.php' ]; then
        occ maintenance:mode --on
      else
        echo "Installation mode."
      fi
      | SH
    after_deploy_content  => inline_epp(@(EPP)),
      #!/bin/sh

      set -e

      occ() {
        sudo -u ${USER_MAPPING_user} OC_CONFIG_WRITABLE=1 php ./occ "$@"
      }

      # Nextcloud checks files for integry, and considers additional files as corrupted.
      rm .mtree

      if [ -f '../persistent-data/config/config.php' ]; then
        occ upgrade
      else
        nextcloud_initial_admin_username="admin-${$}"
        nextcloud_initial_admin_password="secret-${$}"

        occ maintenance:install \
          --database pgsql \
          --database-name <%= $nextcloud::database_name %> \
          --database-user <%= $nextcloud::database_username %> \
          --database-pass <%= $nextcloud::database_password %> \
          --admin-user $nextcloud_initial_admin_username \
          --admin-pass $nextcloud_initial_admin_password \
          --data-dir <%= $nextcloud::data_dir %>

        occ user:delete $nextcloud_initial_admin_username
      fi

      occ maintenance:mode --off

      chown ${USER_MAPPING_user}:${GROUP_MAPPING_user} .htaccess
      occ maintenance:update:htaccess
      chown root:root .htaccess

      systemctl restart <%= $nextcloud::services_to_restart_after_upgrade.join(' ') %>
      | EPP
  }

  application { "nextcloud-${nextcloud::hostname}":
    application   => 'nextcloud',
    kind          => 'nextcloud',
    environment   => 'production',
    path          => $nextcloud::base_dir,
    user_mapping  => {
      user   => $nextcloud::user,
    },
    group_mapping => {
      user   => $nextcloud::group,
    },
  }
}
