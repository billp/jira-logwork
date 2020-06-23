require 'faraday'
require 'json'
require 'tty-prompt'
require 'utilities'
require 'configuration_manager'

class Communicator
  include Singleton

  JIRA_REST_API_VERSION = '2'
  JIRA_AUTH_VERSION = '1'
  public
    def initialize
      open
    end
    
    # Makes a GET request.
    # 
    # @param path [String] The path of the request.
    def get(path, relogin_if_needed = true)
      res = conn.get(path) { |req| add_cookie_if_needed(req) }
      handle_response(res) do |body|
        if block_given?
          yield(body, res)
        end
      end
    end
    
    # Makes a POST request.
    #
    # @param path [String] The path of the request.
    # @params params [Hash] The params of post request.
    def post(path, params = {})
      res = conn.post(path) do |req|
        add_cookie_if_needed(req)
        req.body = params.to_json
      end
      
      handle_response(res) do |body|
        if block_given?
          yield(body, res)
        end
      end
    end

    def delete(path)
      res = conn.delete(path) { |req| add_cookie_if_needed(req) }
      handle_response(res) do |body|
        if block_given?
          yield(body, res)
        end
      end
    end
    
    # Parses the given body as JSON.
    def parseJSON(body) 
      JSON.parse(body, { symbolize_names: true })
    end
    
    # Adds a cookie to request if it's found in connection's header.
    #
    # @param req The request object from Faraday lib.
    def add_cookie_if_needed(req)
      unless conn.headers["Cookie"].nil?
        req.headers = { "Cookie" => conn.headers["Cookie"] }
      end
    end

    # Logs in a user or prompts with login credentials if it's not logged in.
    #
    # @param [AccountCredentials] an accound credentials instance.
    def login(account_credentials)
      if logged_in?
        raise UserAlreadyLoggedInException.new "You are already logged in."
        return
      end

      params = {
        'username' => account_credentials.username,
        'password' => account_credentials.password
      }

      post("/rest/auth/#{JIRA_AUTH_VERSION}/session", params) do |body, res|
        if res.status == 200
          unless account_credentials.is_stored
            #store credentials
            ConfigurationManager.instance.update_login_credentials(account_credentials.username, account_credentials.password)
          end
      
          cookie = body[:session][:name] + "=" + body[:session][:value]
          conn.headers["Cookie"] = cookie
          Utilities.store_cookie(cookie)
          info = get_myself()
          Utilities.log("Success (#{info[:full_name]}).", { type: :success })
          true
        elsif res.status == 401
          raise InvalidCredentialsException.new "Login failed! Please check your credentials."
        else
          raise StandardError.new "Unknown error"
        end
      end
    end

    # Log out the currently logged in user.
    def logout
      unless logged_in?
        raise UserNotLoggedInException.new "You are not logged in."
      end

      delete("/rest/auth/#{JIRA_AUTH_VERSION}/session") do |body, res|
        Utilities.remove_cookie()
        ConfigurationManager.instance.update_login_credentials(nil, nil)
      end
    end

    # Returns if the iser is logged in.
    #
    # @return [Boolean] True if user is logged in, false otherwise.
    def logged_in?
      begin
        return Utilities.cookie_exists? && !ConfigurationManager.instance.login_credentials.nil?
      rescue
        return false
      end
    end

    # Returns information about the logged in user.
    # 
    # @return [Hash] User info.
    def get_myself()
      get("/rest/api/#{JIRA_REST_API_VERSION}/myself") do |body, res| 
        { full_name: body[:displayName]}
      end
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
      
      res = post("/rest/api/#{JIRA_REST_API_VERSION}/issue/#{issue_id}/worklog", params)
    
      if res.status != 200
        return { error: "Something went wrong! (#{res.status})" }
      else
        return { success: true }
      end
    end
  private
    attr_accessor :conn
    attr_accessor :relogin_performed

    # Opens a connection.
    def open
      headers = { 'Content-Type': 'application/json' }
      stored_cookie = Utilities.retrieve_cookie()
      if !stored_cookie.nil?
        headers['Cookie'] = stored_cookie
      end

      self.conn = Faraday.new(
        url: ConfigurationManager.instance.jira_server_url,
        headers: headers
      )
    end

    def valid_json?(json)
      JSON.parse(json)
        return true
      rescue JSON::ParserError => e
        return false
    end

    # Handles response by checking http status codes.
    # 
    # @param res The request object from Faraday lib.
    def handle_response(res)
      if res.status == 401 && !relogin_performed && !res.env.url.to_s.include?("/rest/auth/")
        login()
        relogin_performed = true
      end
      if block_given?
        json_body = valid_json?(res.body) ? parseJSON(res.body) : '{}'
        yield(json_body)
      end
    end
end
