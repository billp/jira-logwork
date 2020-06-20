require 'pathname'
require 'yaml'
require 'external/hash'
require 'openssl'

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

    # Read credentials form configuration file
    #
    # @return [Hash] A hash with :username, :password keys
    def login_credentials
        if configuration_data[:credentials].nil? || 
            configuration_data[:credentials][:username].nil? || 
            configuration_data[:credentials][:password].nil?
            throw StandardError.new "Cannot read username/password from configuration file at '#{configuration_path}'"
        end

        decrypted_password = decrypt(configuration_data[:credentials][:password][:cipher], configuration_data[:credentials][:password][:iv])

        return { username: configuration_data[:credentials][:username], 
                 password: decrypted_password }
    end

    # Update login credentials in configuration file
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
                data = YAML.load(File.read(configuration_path)).deep_symbolize_keys!
                return data || {}
            else
                throw StandardError.new "Configuration cannot be read at '#{configuration_path}'"
            end
        end

        # Writes configuration to user's home folder.
        #
        # @param settings [Hash] The settings hash that will be saved in yml format.
        def save_configuration
            create_config_dir_if_needed

            if configuration_writable?
                File.write(configuration_path, configuration_data.deep_stringify_keys!.to_yaml)
                configuration_data = read_configuration
            else
                throw StandardError.new "Configuration cannot be saved at '#{configuration_path}'"
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