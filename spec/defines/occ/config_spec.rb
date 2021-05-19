require 'spec_helper'

describe 'nextcloud::occ::config' do
  let(:title) { 'namevar' }
  let(:params) do
    {
      key: 'key',
      value: 'value',
      path: '/srv/www/nextcloud.example.com',
      user: 'user',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it {
        is_expected.to contain_nextcloud__occ__exec('config namevar')
          .with(
            'args' => 'config:system:set key --value=value --type=string',
            'user' => 'user',
            'group' => 'user',
            'unless' => '/usr/bin/test "$(/usr/bin/php /srv/www/nextcloud.example.com/occ config:system:get key)" = value',
          )
      }
    end
  end
end
