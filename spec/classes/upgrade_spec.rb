require 'spec_helper'

describe 'nextcloud::upgrade' do
  let(:params) do
    {
      version: '20.0.9',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      context 'when nextcloud is not installed' do
        let(:facts) do
          os_facts
        end

        it { is_expected.not_to compile }
      end

      context 'when nextcloud is installed' do
        let(:facts) do
          os_facts.merge({
                           nextcloud: {
                             path: '/srv/www/nextcloud.example.com',
                             user: 'dummy',
                             group: 'dummy',
                             services_to_restart_after_upgrade: [ 'apache2', 'php7.3-fpm' ],
                           },
                         })
        end

        it { is_expected.to compile }
      end
    end
  end
end
