# frozen_string_literal: true

require 'configuration/configuration_manager'

# Root class for Configuration
class Configuration
  attr_accessor :manager, :data

  def initialize
    self.manager = ConfigurationManager.instance
    self.data = manager.configuration_data
  end
end
