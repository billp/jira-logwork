require 'faraday'
require 'faraday_middleware'
require 'nokogiri'
require 'json'
require 'date'
require 'keychain'
require 'byebug'
require 'tty-prompt'
require 'utilities'

class Communicator
  AFSE_JIRA_BASE_URL = 'https://jira.afse.eu'

  private
    attr_accessor :conn
  public
    def open
      self.conn = Faraday.new(
        url: AFSE_JIRA_BASE_URL,
        headers: { 'Content-Type': 'application/json' }
      )
    end
    
    def get(path)
      conn.get(path) { |req| add_cookie_if_needed(req) }
    end
    
    def post(path, params = {})
      conn.post(path) do |req|
        add_cookie_if_needed(req)
        req.body = params.to_json
      end
    end

    def delete(path) 
      conn.delete(path) { |req| add_cookie_if_needed(req) }
    end
    
    def parseJSON(body) 
      JSON.parse(body, { symbolize_names: true })
    end
    
    def add_cookie_if_needed(req)
      unless conn.headers["Cookie"].nil?
        req.headers = { "Cookie" => conn.headers["Cookie"] }
      end
    end

    def login()
      keychain_account = Keychain.generic_passwords.where(:service => KEYCHAIN_KEY).first
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
    
      res = post('/rest/auth/1/session', {
        'username' => account[:username],
        'password' => account[:password]
      })
    
      if res.status == 200
        if account[:store_credentials]
          #store credentials
          Keychain.generic_passwords.create(service: KEYCHAIN_KEY, password: account[:password], account: account[:username])
        end
    
        json = JSON.parse(res.body)
        cookie = json["session"]["name"] + "=" + json["session"]["value"]
        conn.headers["Cookie"] = cookie
        info = get_myself()
        Utilities.log("Success (#{info[:full_name]}).", { type: :success })
        true
      else
        Utilities.log("Login failed! Please check your credentials. #{ENV['JIRA_OMNIA_USERNAME']}", { type: :error })
        false
      end
    end

    def logout()
      Utilities.log('Logging out...')
    
      res = delete('/rest/auth/1/session')
      if res.status == 200 
        account = Keychain.generic_passwords.where(:service => KEYCHAIN_KEY).first
        unless account.nil?
          account.delete
        end
      elsif res.status == 401
        byebug
        log("You are not logged in.", { type: :error })
      end
    end

    def get_myself()
      res = get('/rest/api/2/myself')
      json = parseJSON(res.body)
      { full_name: json[:displayName]}
    end

    def log_work(params)
      issue_id = params[:issue_id]
      date = params[:date].nil? ? Time.now.to_i * 1000 : Date.strptime(params[:date], '%d/%m/%Y').to_time.to_i * 1000
      start_time = params[:full_day] ? '10:15 AM' : params[:start_time]
      end_time = params[:full_day] ? '06:00 PM' : params[:end_time]
    
      client = Faraday.new do |f|
        f.request :json
        f.adapter Faraday.default_adapter
      end
    
      req_body = {
        "date": date,
        "worklogValues": {
          "startTime": start_time,
          "endTime": end_time,
          "issueKey": [issue_id],
          "remainingEstimateType": "AUTO"
        }
      }
    
      res = client.post("#{AFSE_JIRA_BASE_URL}/rest/jttp-rest/latest/timetracker-resource/save", req_body) do |req|
        req.headers['cookie'] = $cookie
      end
    
      if res.status != 200
        return { error: "Something went wrong, sorry bro! (#{res.status})" }
      else
        return { success: true }
      end
    end
end
