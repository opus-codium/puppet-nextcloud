#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper'
require 'json'
require 'securerandom'
require 'open3'

# Invite a user through bolt task
class UserInviteTask < TaskHelper
  def task(username: nil, email: nil, group: nil, display_name: nil, **_kwargs)
    unless File.executable? '/usr/local/bin/occ'
      raise TaskHelper::Error.new('Nextcloud is not installed on this node.',
                                  'user-invite-task/not-installed-error',
                                  'Nextcloud must be installed on the target node before using this task.')
    end

    # Create user with a random password
    command = ['/usr/local/bin/occ', 'user:add', '--password-from-env']
    command += ['--display-name', display_name.to_s] unless display_name.nil?
    command += ['--group', group.to_s] unless group.nil?
    command += ['--', username.to_s]

    password = SecureRandom.base64(20)

    stdout_and_stderr, status = Open3.capture2e({ 'OC_PASS' => password }, *command)

    unless status.success?
      raise TaskHelper::Error.new("Error: `occ` fails with: #{stdout_and_stderr}",
                                  'user-invite-task/occ-execution-error',
                                  'OCC Error')
    end

    # Set email to created user
    command = ['/usr/local/bin/occ', 'user:setting', '--', username.to_s, 'settings', 'email', email.to_s]
    stdout_and_stderr, status = Open3.capture2e(*command)

    unless status.success?
      raise TaskHelper::Error.new("Error: `occ` fails with: #{stdout_and_stderr}",
                                  'user-invite-task/occ-execution-error',
                                  'OCC Error')
    end

    # Send a reset password request
    command = ['/usr/local/bin/occ', 'config:system:get', 'overwrite.cli.url']
    stdout_and_stderr, status = Open3.capture2e({ 'OC_PASS' => password }, *command)

    unless status.success?
      raise TaskHelper::Error.new("Error: `occ` fails with: #{stdout_and_stderr}",
                                  'user-invite-task/occ-execution-error',
                                  'OCC Error')
    end

    url = stdout_and_stderr.chomp
    response = simulate_lost_password_request url, username

    unless response.body == '{"status":"success"}'
      raise TaskHelper::Error.new("Error while requesting a new password reset: #{response.body}",
                                  'user-invite-task/password-reset-request-error',
                                  'Net::HTTP error')
    end
    nil
  end

  def simulate_lost_password_request(url, user)
    require 'net/http'
    require 'json'

    uri = URI("#{url}/login")

    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Get.new uri
      response = http.request(request)

      res = response.body.match(%r{data-requesttoken="(?<token>[^"]+)"})

      cookies = response.get_fields('Set-Cookie').map { |x| x.split('; ')[0] }.join('; ')

      uri = URI("#{url}/lostpassword/email")
      request = Net::HTTP::Post.new uri
      request['requesttoken'] = res['token']
      request['Cookie'] = cookies

      request['Content-Type'] = 'application/json;charset=utf-8'

      request.body = {
        user: user
      }.to_json

      response = http.request(request)

      response
    end
  end
end

UserInviteTask.run if __FILE__ == $PROGRAM_NAME
