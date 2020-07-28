# frozen_string_literal: true

require 'models/worklog_issue'
require 'configuration/shift_configuration'

# Test Helpers.
class TestHelpers
  # rubocop:disable Metrics/MethodLength
  def self.create_sample_issues
    [
      WorklogIssue.new(jira_id: 'ABC-1234', description: 'Bug #1',
                       duration: nil, start_time: '10:00', date: '10/10/2020', repeat: 5),
      WorklogIssue.new(jira_id: 'ASDC-2131', description: 'Bug #2',
                       duration: '20m', repeat: 3),
      WorklogIssue.new(jira_id: 'AXA-385', description: 'Bug #3',
                       duration: '60m', repeat: 0),
      WorklogIssue.new(jira_id: 'BAX-994', description: 'Bug #4',
                       duration: nil, date: nil, repeat: 2),
      WorklogIssue.new(jira_id: 'XAS-511', description: 'Bug #5',
                       duration: nil, date: nil, repeat: 1)
    ]
  end
  # rubocop:enable Metrics/MethodLength

  def self.setup_test
    Database.prepare_test_database
    ConfigurationManager.instance.expects(:jira_server_url).at_least(0).with(nil).returns('http://www.google.com')
    ShiftConfiguration.any_instance.expects(:shift_start).at_least(0).with(nil).returns('10:00')
  end

  def self.mocked_issue
    parsed = Utilities.parse_json(File.read('./tests/mock_data/issue.json'))
    WorklogIssue.new(jira_id: parsed[:key], description: parsed[:fields][:summary])
  end
end
