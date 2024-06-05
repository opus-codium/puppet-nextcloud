# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'nextcloud class' do
  it 'works idempotently with no errors' do
    pp = <<~MANIFEST
      class { 'nextcloud':
        hostname          => 'nextcloud.example.com',
        database_password => 'the super secret password used by postgresql',
      }
    MANIFEST

    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end
end
