# frozen_string_literal: true

require 'faraday'
require 'json'
require 'tty-prompt'
require 'utilities'
require 'configuration/configuration_manager'
require 'communication/modules/communicator_helpers'
require 'models/worklog_issue'

# Communication
class Communicator
  include Singleton
  include CommunicatorHelpers

  attr_accessor :last_call
  attr_accessor :last_proc

  def initialize
    open
  end

  # Makes a GET request.
  #
  # @param path [String] The path of the request.
  def get(path, &block)
    run_call(path, block) do |yield_block|
      res = conn.get(path) { |req| add_cookie_if_needed(req) }
      handle_response(res) do |body|
        yield_block.call(body, res)
      end
    end
  end

  # Makes a POST request.
  #
  # @param path [String] The path of the request.
  # @params params [Hash] The params of post request.
  def post(path, params = {}, &block)
    run_call(path, block) do |yield_block|
      res = conn.post(path) do |req|
        add_cookie_if_needed(req)
        req.body = params.to_json
      end
      handle_response(res) { |body| yield_block.call(body, res) }
    end
  end

  def delete(path, &block)
    run_call(path, block) do |yield_block|
      res = conn.delete(path) { |req| add_cookie_if_needed(req) }
      handle_response(res) { |body| yield_block.call(body, res) }
    end
  end

  # Chaches and starts a request
  #
  # @param input [Proc] The proc with the request handling body.
  # @param yield_block [Proc] The proc that will be executed upon success response.
  def run_call(path, yield_block, &input)
    if auth_call?(path)
      input.call(yield_block)
      return
    end

    self.last_call = proc do |yield_proc|
      input.call(yield_proc)
    end
    return if yield_block.nil?

    self.last_proc = yield_block
    last_call.call(last_proc)
  end

  # Parses the given body as JSON.
  def parse_json(body)
    JSON.parse(body, { symbolize_names: true })
  end

  # Adds a cookie to request if it's found in connection's header.
  #
  # @param req The request object from Faraday lib.
  def add_cookie_if_needed(req)
    req.headers = { 'Cookie' => conn.headers['Cookie'] } unless conn.headers['Cookie'].nil?
  end

  # Adds a new worklog entry for the logged in user
  #
  # @param issue_id [String] The Jira issue id.
  # @param started [String] The started date in ISO 8601 format (e.g. 2020-06-16T18:15:05.920+0000)
  # @param seconds_spent [Integer] The number of seconds spend on this issue
  # @return [Hash] An object with an error message specified by 'error' key, or a { success: true }
  def log_work(issue_id, started, seconds_spent)
    params = {
      "started": started,
      "timeSpentSeconds": seconds_spent
    }

    res = post("#{Communicator.base_api_url}/issue/#{issue_id}/worklog", params)

    if res.status != 200
      { error: "Something went wrong! (#{res.status})" }
    else
      { success: true }
    end
  end

  def store_cookie(cookie)
    # Store cookie
    conn.headers['Cookie'] = cookie
    Utilities.store_cookie(cookie)
  end

  # Returns the base JIRA API URL.
  #
  # @return [String] returns the base JIRA API URL.
  def self.base_api_url
    "/rest/api/#{Constants::JIRA_REST_API_VERSION}"
  end

  # Handles response by checking http status codes.
  #
  # @param res The request object from Faraday lib.
  def handle_response(res)
    # relogin if needed
    return relogin if should_relogin(res)

    check_unauthorized(res.status, res.env.url.to_s)
    check_not_found(res.status)
    check_not_success(res.status)
    handle_success(res.body) do |json_body|
      yield(json_body) if block_given?
    end
  end

  private

  attr_accessor :conn
  attr_accessor :relogin_performed

  # Opens a connection.
  def open
    headers = { "Content-Type": 'application/json' }
    stored_cookie = Utilities.retrieve_cookie
    headers['Cookie'] = stored_cookie unless stored_cookie.nil?

    self.conn = Faraday.new(
      url: ConfigurationManager.instance.jira_server_url,
      headers: headers
    )
  end
end
