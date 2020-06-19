#!/usr/bin/env ruby

$LOAD_PATH << File.join(File.expand_path('.', __dir__), 'lib')

require 'slop'
require 'communicator'

# Parse command-line arguments
begin
  opts = Slop.parse do |o|
    o.bool '--login', 'Login with your JIRA credentials.'
    o.bool '--logout', 'Logout current user.'
  end
rescue Slop::Error => ex
  puts ex
  exit 1
end

communicator = Communicator.new
communicator.open()

if opts[:login] 
  communicator.login()
  return
elsif opts[:logout] 
  communicator.logout()
  return
end

print opts