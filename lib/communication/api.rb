# frozen_string_literal: true

require 'communication/communicator'
require 'exceptions'

# Defines API calls
class API
  # Returns information about the given issue.
  #
  # @return [WorklogIssue] User info.
  def self.get_issue(issue_id)
    Communicator.instance.get("#{Communicator.base_api_url}/issue/#{issue_id}") do |body, _|
      issue = WorklogIssue.new(jira_id: body[:key], description: body[:fields][:summary])
      yield(issue) if block_given?
    end
  end
end
