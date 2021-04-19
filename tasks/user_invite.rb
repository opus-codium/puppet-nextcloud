#!/usr/bin/env ruby

require_relative "../../ruby_task_helper/files/task_helper.rb"
require 'json'
require 'securerandom'
require 'open3'

class UserInviteTask < TaskHelper
  def task(username: nil, email: nil, group: nil, display_name: nil, **kwargs)
    raise TaskHelper::Error.new('Nextcloud is not installed on this node.',
                                'user-invite-task/not-installed-error',
                                'Nextcloud must be installed on the target node before using this task.'
                               )unless File.executable? '/usr/local/bin/occ'

    # Create user with a random password
    command = %w[/usr/local/bin/occ user:add --password-from-env]
    command += %W[--display-name #{display_name}] unless display_name.nil?
    command += %W[--group #{group}] unless group.nil?
    command += %W[-- #{username}]

    password = SecureRandom.base64(20)

    stdout_and_stderr, status = Open3.capture2e({'OC_PASS' => password}, *command)

    raise TaskHelper::Error.new("Error: `occ` fails with: #{stdout_and_stderr}",
                                'user-invite-task/occ-execution-error',
                                'OCC Error'
                               ) unless status.success?

    # Set email to created user
    command = %W[/usr/local/bin/occ user:setting -- #{username} settings email #{email}]
    stdout_and_stderr, status = Open3.capture2e(*command)

    raise TaskHelper::Error.new("Error: `occ` fails with: #{stdout_and_stderr}",
                                'user-invite-task/occ-execution-error',
                                'OCC Error'
                               ) unless status.success?

    # Send a reset password request
    command = %w[/usr/local/bin/occ config:system:get overwrite.cli.url]
    stdout_and_stderr, status = Open3.capture2e({'OC_PASS' => password}, *command)

    raise TaskHelper::Error.new("Error: `occ` fails with: #{stdout_and_stderr}",
                                'user-invite-task/occ-execution-error',
                                'OCC Error'
                               ) unless status.success?

    url = stdout_and_stderr.chomp
    response = simulate_lost_password_request url, username

    raise TaskHelper::Error.new("Error while requesting a new password reset: #{response.body}",
                                'user-invite-task/password-reset-request-error',
                                'Net::HTTP error'
                               ) unless response.body = '{"status":"success"}'
    return
  end

  def simulate_lost_password_request(url, user)
    require 'net/http'
    require 'json'

    uri = URI("#{url}/login")

    Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
      request = Net::HTTP::Get.new uri
      response = http.request(request)

      res = response.body.match(/data-requesttoken="(?<token>[^"]+)"/)

      cookies = response.get_fields('Set-Cookie').map { |x| x.split('; ')[0] }.join('; ')

      uri = URI("#{url}/lostpassword/email")
      request = Net::HTTP::Post.new uri
      request['requesttoken'] = res['token']
      request['Cookie'] = cookies

      request['Content-Type'] = 'application/json;charset=utf-8'

      request.body = {
        'user': user
      }.to_json

      response = http.request(request)

      response
    end
  end
end

if __FILE__ == $0
  UserInviteTask.run
end
