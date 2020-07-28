# Copyright © 2020-2021. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in the
# Software without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies
# or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FIESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
# FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# frozen_string_literal: true

require 'fileutils'
require 'constants'
require 'time'
require 'date'

# Utilities
class Utilities
  LOG_SYMBOLS = {
    info: '￫ ',
    success: '🎉',
    error: '😓',
    none: ''
  }.freeze

  ENCRYPTED_STORE_KEY = 'JIRA-LOGWORK'
  TEMP_FOLDER_NAME = 'tmp'
  COOKIE_FILE_NAME = '.cookie'

  # Logs a message to console.
  #
  # @param message [String] The message to log.
  # @param type [Symbol] Log type, `:info`, `:success`, `:error` or `:none`.
  def self.log(message, options = {})
    type = options[:type] || :info
    newline = options[:newline] || true

    print "#{LOG_SYMBOLS[type] ? ' ' + LOG_SYMBOLS[type] + ' ' : ''}#{message}" + (newline ? "\n" : '')
  end

  # Parses the given body as JSON.
  def self.parse_json(body)
    JSON.parse(body, { symbolize_names: true })
  end

  # Stores session cookie in tmp folder.
  #
  # @param cookie [String] The cookie string value.
  def self.store_cookie(cookie)
    FileUtils.mkdir_p(temp_folder_path) unless File.directory?(temp_folder_path)
    File.write(cookie_file_path, cookie)
  end

  # Removes the stored cookie if exists.
  def self.remove_cookie
    File.delete(cookie_file_path) if File.file?(cookie_file_path)
  end

  # Retrieves session cookie if available.
  #
  # @return [String] Cookie value or nil
  def self.retrieve_cookie
    File.read(cookie_file_path) if cookie_exists?
  end

  # Check if cookie file exist
  #
  # @return [Boolean] True if cookie file exists, false otherwise.
  def self.cookie_exists?
    File.file?(cookie_file_path)
  end

  # Validates a URL string
  #
  # @return [Boolean] True if URL is valid, false otherwise.
  def self.valid_url?(url)
    uri = URI.parse(url)
    !uri.nil? && !uri.host.nil?
  rescue URI::InvalidURIError
    false
  end

  # Validates a JSON String
  #
  # @param [String] A JSON String.
  def self.valid_json?(json)
    JSON.parse(json)
    true
  rescue JSON::ParserError
    false
  end

  # Validates a time string, e.g. 10:00
  #
  # @return [Boolean] True if time is valid, false otherwise.
  def self.valid_time?(time)
    return false unless time =~ /[0-2][0-9]:[0-6][0-6]/

    Time.parse(time)
    true
  rescue StandardError
    false
  end

  # Validates a String to see if it's an Integer
  #
  # @return [Boolean] True if String isan Integer, false otherwise.
  def self.number?(str)
    !(!Integer(str))
  rescue ArgumentError, TypeError
    false
  end

  # Validates a Date string with a specific format
  #
  # @return [Boolean] True if String isan Integer, false otherwise.
  def self.valid_date?(str)
    Date.strptime(str, '%m/%d/%Y')
  rescue ArgumentError, TypeError
    false
  end

  def self.seconds_to_duration(secs)
    components = [[60, :s], [60, :m], [24, :h], [Float::INFINITY, :d]]
    res = components.map do |count, name|
      if secs.positive?
        secs, n = secs.divmod(count)
        "#{n.to_i}#{name}" unless n.to_i.zero?
      end
    end
    res.compact.reverse.join(' ')
  end

  # Return the total hour duration between two time strings.
  #
  # @param start_time The start time in 24h format, e.g. 10:00.
  # @param end_time The end time in 24h format, e.g. 18:00.
  # @return [Int] Duration in hours.
  def self.time_diff_hours(start_time, end_time)
    (Time.parse(end_time) - Time.parse(start_time)).to_i / 3600
  end

  # Return the total hour duration between two time strings.
  #
  # @param start_time The start time in 24h format, e.g. 10:00.
  # @param end_time The end time in 24h format, e.g. 18:00.
  # @return [Int] Duration in hours.
  def self.time_diff_seconds(start_time, end_time)
    (Time.parse(end_time) - Time.parse(start_time)).to_i
  end

  # Adds test stubs to faraday
  def self.add_faraday_test_stub(builder)
    builder.adapter :test do |stub|
      stub.get('/rest/api/2/issue/ABC-DEF132') do
        [200, { 'Content-Type': 'application/json' }, File.read('./tests/mock_data/issue.json')]
      end
      stub.get('/rest/api/2/issue/ABC-DEF133') do
        [200, { 'Content-Type': 'application/json' }, File.read('./tests/mock_data/issue2.json')]
      end
    end
  end

  private_class_method def self.temp_folder_path
    File.expand_path(File.join(Dir.home, Constants::ROOT_FOLDER_NAME, TEMP_FOLDER_NAME))
  end

  private_class_method def self.cookie_file_path
    File.join(temp_folder_path, COOKIE_FILE_NAME)
  end
end
