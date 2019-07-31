require 'spec_helper'

describe 'nextcloud::setup' do
  let(:title) { '/srv/www/nextcloud.example.com' }
  let(:params) do
    {
      config_main_file: '/config-main',
      config_dir: '/config',
      apps_dir: '/apps',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
