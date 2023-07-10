# frozen_string_literal: true

require 'spec_helper'

describe 'nextcloud' do
  let(:params) do
    {
      hostname: 'nextcloud.example.com',
      database_password: 'the super secret password used by postgresql',
      default_language: 'fr',
      default_phone_region: 'FR',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
