#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper'
require_relative '../../application/tasks/utils/application_factory'

# Upgrade a nextcloud instance
class NextcloudUpgradeTask < TaskHelper
  def task(version:, **_kwargs)
    application = 'nextcloud'
    environment = 'production'
    url = "https://download.nextcloud.com/server/releases/nextcloud-#{version}.tar.bz2"

    ApplicationFactory.find(application, environment).each do |app|
      headers = {}
      app.deploy(url, version, headers)
    end

    nil
  end
end

NextcloudUpgradeTask.run if $PROGRAM_NAME == __FILE__
