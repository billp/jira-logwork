# frozen_string_literal: true

require 'pathname'
require 'yaml'
require 'external/hash'
require 'openssl'
require 'uri'
require 'exceptions'
require 'models/account_credentials'

# Configuration manager
class ConfigurationManager
  include Singleton

  CONFIGURATION_FILENAME = '.jira-logwork.yml'

  attr_accessor :configuration_data

  def initialize
    self.configuration_data = configured? ? read_configuration : {}
  end

  # Read JIRA server URL configuration file
  #
  # @return [String] The JIRA Server URL
  def jira_server_url
    if configuration_data[:jira_server_url].nil?
      raise ConfigurationJiraURLNotFound.new,
            "Cannot read JIRA server URL from configuration file at '#{configuration_path}'."
    end

    unless Utilities.valid_url?(configuration_data[:jira_server_url])
      raise InvalidURLException.new, "Invalid JIRA Server URL in '#{configuration_path}'"
    end

    configuration_data[:jira_server_url]
  end

  # Update login credentials in configuration file
  def update_jira_server_url(url)
    raise InvalidURLException.new, 'Invalid JIRA Server URL.' unless Utilities.valid_url?(url)

    configuration_data[:jira_server_url] = url
    save_configuration
  end

  # Writes configuration to user's home folder.
  #
  # @param settings [Hash] The settings hash that will be saved in yml format.
  def save_configuration
    create_config_dir_if_needed
    unless configuration_writable?
      raise ConfigurationFileNotFoundException.new? "Configuration cannot be saved at '#{configuration_path}'"
    end

    File.write(configuration_path, configuration_data.deep_stringify_keys.to_yaml)
    read_configuration
  end

  # The configuration path
  #
  # @return [String] The absolute configuration path.
  def configuration_path
    File.join(home_dir, Constants::ROOT_FOLDER_NAME, CONFIGURATION_FILENAME)
  end

  private

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
    unless configuration_exists?
      raise ConfigurationFileNotFoundException.new,
            "Configuration cannot be read at '#{configuration_path}'"
    end

    YAML.safe_load(File.read(configuration_path)).deep_symbolize_keys || {}
  end

  def home_dir
    Dir.home
  end

  def configuration_writable?
    Pathname.new(home_dir).writable?
  end

  def configuration_exists?
    File.file?(configuration_path)
  end

  def create_config_dir_if_needed
    Dir.mkdir(File.dirname(configuration_path)) unless configuration_exists?
  end
end