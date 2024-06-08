# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'nextcloud class' do
  it 'works idempotently with no errors' do
    pp = <<~MANIFEST
      # FIXME: Some distro don't have this directory.  Change it to something more stable?
      file { '/srv/www':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }

      class { 'nextcloud':
        hostname          => 'nextcloud.example.com',
        database_password => 'the super secret password used by postgresql',
      }
    MANIFEST

    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end
end
