require 'spec_helper'

describe 'nextcloud::facts' do
  let(:title) { 'namevar' }
  let(:params) do
    {
      version: 'version',
      path: '/srv/www/nextcloud.example.com',
      user: 'user',
      group: 'group',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
