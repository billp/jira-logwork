# frozen_string_literal: true

require 'models/modules/hashable_init'

# AccountCredentials model
class AccountCredentials
  include HashableInit

  attr_accessor :username
  attr_accessor :password
  attr_accessor :is_stored
end
