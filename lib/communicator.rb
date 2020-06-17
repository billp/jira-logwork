require 'faraday'
require 'nokogiri'
require 'json'
require 'date'
require 'keychain'
require 'byebug'
require 'tty-prompt'
require 'utilities'

class Communicator
  JIRA_BASE_URL = 'https://jira.afse.eu'
  JIRA_REST_API_VERSION = '2'
  JIRA_AUTH_VERSION = '1'

  private
    attr_accessor :conn
  public
    # Opens a connection.
    def open
      headers = { 'Content-Type': 'application/json' }
      stored_cookie = Utilities.retrieve_cookie()
      if !stored_cookie.nil?
        headers['Cookie'] = stored_cookie
      end

      self.conn = Faraday.new(
        url: JIRA_BASE_URL,
        headers: headers
      )
    end
    
    # Makes a GET request.
    # 
    # @param path [String] The path of the request.
    def get(path)
      conn.get(path) { |req| add_cookie_if_needed(req) }
    end
    
    # Makes a POST request.
    #
    # @param path [String] The path of the request.
    # @params params [Hash] The params of post request.
    def post(path, params = {})
      conn.post(path) do |req|
        add_cookie_if_needed(req)
        req.body = params.to_json
      end
    end

    def delete(path)
      conn.delete(path) { |req| add_cookie_if_needed(req) }
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
    def login()
      keychain_account = Utilities.retrieve_credentials()
      account = { username: nil, password: nil, store_credentials: false }
    
      if keychain_account.nil?
        Utilities.log("Please enter your credentials:")
        prompt = TTY::Prompt.new
        account[:username] = prompt.ask("Username:")
        account[:password] = prompt.mask("Password:")
        account[:store_credentials] = true
        Utilities.log("Trying to login...")
      else 
        account[:username] = keychain_account.account
        account[:password] = keychain_account.password
        Utilities.log("Trying to login...")
      end
    
      res = post("/rest/auth/#{JIRA_AUTH_VERSION}/session", {
        'username' => account[:username],
        'password' => account[:password]
      })
    
      if res.status == 200
        if account[:store_credentials]
          #store credentials
          Utilities.store_credentials(account[:username], account[:password])
        end
    
        json = JSON.parse(res.body)
        cookie = json["session"]["name"] + "=" + json["session"]["value"]
        conn.headers["Cookie"] = cookie
        Utilities.store_cookie(cookie)
        info = get_myself()
        Utilities.log("Success (#{info[:full_name]}).", { type: :success })
        true
      else
        Utilities.log("Login failed! Please check your credentials.", { type: :error })
        false
      end
    end

    # Log out the currently logged in user.
    def logout()
      Utilities.log('Logging out...')
      res = delete("/rest/auth/#{JIRA_AUTH_VERSION}/session")
      if res.status == 204
        Utilities.log('Success.', { type: :success })
      elsif res.status == 401
        Utilities.log("You are not logged in.", { type: :error })
        Utilities.remove_credentials()
        Utilities.remove_cookie()
      end
    end

    # Returns information about the logged in user.
    # 
    # @return [Hash] User info.
    def get_myself()
      res = get("/rest/api/#{JIRA_REST_API_VERSION}/myself")
      json = parseJSON(res.body)
      { full_name: json[:displayName]}
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
end
