# frozen_string_literal: true

require 'test/unit'
require 'exceptions'
require 'worklog_manager'
require 'models/worklog_issue'
require 'database'
require 'utilities'
require 'configuration/configuration'
require 'mocha/test_unit'
require 'test_helpers'

# Test WorkLogManager
class TestWorklogDurations < Test::Unit::TestCase
  def setup
    TestHelpers.setup_test
  end

  def test_duration_adjust_command
    manager = WorklogManager.new(TestHelpers.create_sample_issues)
    manager.update_worklog('i', issue_to_add: 'ABC-DEF132')
    issues = manager.update_worklog('i', issue_to_add: 'ABC-DEF133')
    issues.last.duration = '15m'
    manager.adjust

    assert durations_valid?(issues)
  end

  def durations_valid?(issues)
    issues.reduce(0) { |res, issue| res + issue.converted_duration } == 60 * 60 * 8
  end
end
