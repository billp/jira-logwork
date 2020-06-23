require 'pathname'
require 'yaml'
require 'external/hash'
require 'openssl'
require 'uri'
require 'exceptions'
require 'models/account_credentials'

class ConfigurationManager
    include Singleton

    CONFIGURATION_FILENAME = '.jira-logwork.yml'
    CREDENTIALS_KEY = 'kserw-gw?-vale kati -edw!@#!@!#@&!#@!'

    def initialize
        if configured?
            self.configuration_data = read_configuration
        else 
            self.configuration_data = {}
        end
    end

    # Read credentials from configuration file
    #
    # @return [AccountCredentials] An AccountCredentials instance with username, password and is_stored properties.
    def login_credentials
        if configuration_data[:credentials].nil? || 
            configuration_data[:credentials][:username].nil? || 
            configuration_data[:credentials][:password].nil?
            raise ConfigurationValueNotFound.new "Cannot read username/password from configuration file at '#{configuration_path}'."
        end

        decrypted_password = decrypt(configuration_data[:credentials][:password][:cipher], configuration_data[:credentials][:password][:iv])

        account_credentials = AccountCredentials.new(username: configuration_data[:credentials][:username], 
                                                     password: decrypted_password,
                                                     is_stored: true)

        return account_credentials
    end

    # Update login credentials in configuration file
    #
    # @param username [String] Jira username
    # @param password [String] Jira password
    def update_login_credentials(username, password)
        unless username.nil? && password.nil? 
            encrypted_password = encrypt(password)
            configuration_data[:credentials] = {
                username: username,
                password: encrypted_password
            }
        else
            configuration_data.delete(:credentials)
        end

        save_configuration
    end

    # Read JIRA server URL configuration file
    #
    # @return [String] The JIRA Server URL
    def jira_server_url
        if configuration_data[:jira_server_url].nil?
            raise ConfigurationValueNotFound.new "Cannot read JIRA server URL from configuration file at '#{configuration_path}'."
        end

        unless Utilities.valid_url?(configuration_data[:jira_server_url]) 
            raise InvalidURLException.new "Invalid JIRA Server URL in '#{configuration_path}'"
        end

        return configuration_data[:jira_server_url]
    end

    # Update login credentials in configuration file
    def update_jira_server_url(url)
        unless Utilities.valid_url?(url) 
            raise InvalidURLException.new "Invalid JIRA Server URL."
        end

        configuration_data[:jira_server_url] = url
        save_configuration
    end

    # Read worktime start.
    #
    # @return [String] The start work time value, e.g. '10:00'
    def worktime_start
        if configuration_data[:worktime].nil? || configuration_data[:worktime][:start].nil?
            raise ConfigurationValueNotFound.new "Cannot read work time start from configuration file at '#{configuration_path}'."
        end

        work_start = configuration_data[:worktime][:start]
        
        unless Utilities.valid_time?(work_start)
            raise InvalidTimeException.new "Invalid start time format in '#{configuration_path}'."
        end

        return configuration_data[:worktime][:start]
    end

    # Update work time start in configuration file.
    #
    # @param [String] The start work time value, e.g. '10:00'
    def update_worktime_start(worktime_start)
        unless Utilities.valid_time?(worktime_start)
            raise InvalidTimeException.new "Invalid start time format."
        end

        worktime = configuration_data[:worktime] || Hash.new
        worktime[:start] = worktime_start
        configuration_data[:worktime] = worktime
        save_configuration
    end

    # Read worktime end.
    #
    # @return [String] The end work time value, e.g. '18:00'
    def worktime_end
        if configuration_data[:worktime].nil? || configuration_data[:worktime][:end].nil?
            raise ConfigurationValueNotFound.new "Cannot read Work time from configuration file at '#{configuration_path}'."
        end

        work_end = configuration_data[:worktime][:end]
        
        unless Utilities.valid_time?(work_end)
            raise InvalidTimeException.new "Invalid end time formats in '#{configuration_path}'."
        end

        return configuration_data[:worktime][:end]
    end

    # Update work time end in configuration file.
    #
    # @param [String] The start work time value, e.g. '18:00'
    def update_worktime_end(worktime_end)
        unless Utilities.valid_time?(worktime_end)
            raise InvalidTimeException.new "Invalid end time format."
        end

        worktime = configuration_data[:worktime] || Hash.new
        worktime[:end] = worktime_end
        configuration_data[:worktime] = worktime
        save_configuration
    end

    # Worktime duration in hours.
    #
    # @return [Int] The duration in hours between worktime end and worktime start
    def worktime_duration
        duration = Utilities.time_diff_hours(worktime_start, worktime_end)

        if duration < 1 || duration > 24
            raise InvalidWorkHoursDurationException.new "Unable to calculate your work hours. Configuration values worktime_start and/or worktime_end are invalid."
        end

        return duration
    end

    def print_value(type)
        begin
            case type
            when :url
                jira_server_url
            when :worktime_start
                worktime_start
            when :worktime_end
                worktime_end
            end
        rescue ConfigurationValueNotFound
            "[not set]"
        end
    end

    private
        attr_accessor :configuration_data

        # Checks if initial configuration is completed.
        #
        # @return [Boolean] true if the initial configuration is completed, false otherwise.
        def configured?
            configuration_exists?
        end

        # Reads configuration
        #
        # @return [Hash] The hash representation of yml configuration file.
        def read_configuration
            if configuration_exists?
                data = YAML.load(File.read(configuration_path)).deep_symbolize_keys
                return data || {}
            else
                raise ConfigurationFileNotFoundException.new "Configuration cannot be read at '#{configuration_path}'"
            end
        end

        # Writes configuration to user's home folder.
        #
        # @param settings [Hash] The settings hash that will be saved in yml format.
        def save_configuration
            create_config_dir_if_needed

            if configuration_writable?
                File.write(configuration_path, configuration_data.deep_stringify_keys.to_yaml)
                configuration_data = read_configuration
            else
                raise ConfigurationFileNotFoundException.new "Configuration cannot be saved at '#{configuration_path}'"
            end
        end

        def home_dir
            Dir.home
        end
        
        def configuration_path
            File.join(home_dir, Constants::ROOT_FOLDER_NAME, CONFIGURATION_FILENAME)
        end

        def configuration_writable?
            Pathname.new(home_dir).writable?
        end

        def configuration_exists?
            File.file?(configuration_path)
        end

        def create_config_dir_if_needed
            if !configuration_exists?
                Dir.mkdir(File.dirname(configuration_path))
            end
        end

        def encrypt(password)
            cipher = OpenSSL::Cipher::AES256.new :CBC
            cipher.encrypt
            cipher.key = Digest::SHA256.digest(CREDENTIALS_KEY)
            iv = cipher.random_iv
            { cipher: cipher.update(password) + cipher.final, 
              iv: iv }
        end

        def decrypt(cipher, iv)
            decipher = OpenSSL::Cipher::AES256.new :CBC
            decipher.iv = iv
            decipher.decrypt
            decipher.key = Digest::SHA256.digest(CREDENTIALS_KEY)
            plain_text = decipher.update(cipher) + decipher.final
        end
end