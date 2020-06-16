#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path('.', __dir__)

require 'slop'
require 'communicator'

# Parse command-line arguments
begin
  opts = Slop.parse do |o|
    o.bool '--login', 'Login with your JIRA Omnia credentials.'
    o.bool '--logout', 'Logout current user.'
    o.string '-i', '--issue', 'JIRA Issue ID'
    o.string '-s', '--start-time', 'Start time, e.g. 10:00 AM'
    o.string '-e', '--end-time', 'End time, e.g. 10:30 AM'
    o.string '-d', '--date', 'Date in DD/MM/YYYY format, e.g. 10/03/2019'
    o.bool '-f', '--full-day', 'Full day log (10:15 AM - 06:00 PM)'
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

unless communicator.login()
  exit 1
end

log('Logging work...', { newline: false })
res = log_work({
  issue_id: opts[:issue],
  start_time: opts[:start_time],
  end_time: opts[:end_time],
  date: opts[:date],
  full_day: opts.full_day?
})

if res[:error]
  Utilities.log(res[:error], { type: :error })
else
  Utilities.log("success.", { type: :success })
end
