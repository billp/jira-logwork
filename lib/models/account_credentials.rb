require 'models/hashable_init'

class AccountCredentials
    include HashableInit

    attr_accessor :username
    attr_accessor :password
    attr_accessor :is_stored
end