# frozen_string_literal: true

require 'spec_helper'

describe 'nextcloud::occ::exec' do
  let(:title) { 'namevar' }
  let(:params) do
    {
      path: '/srv/www/nextcloud.example.com',
      user: 'user',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
