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
    issues.last.adjustment_mode = 'fixed'
    manager.adjust

    assert durations_valid?(issues)
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def test_duration_adjust_with_start_time
    manager = WorklogManager.new(TestHelpers.create_sample_issues)
    manager.update_worklog('i', issue_to_add: 'ABC-DEF132')
    issues = manager.update_worklog('i', issue_to_add: 'ABC-DEF133')

    static_issue1 = issues.last
    static_issue1.duration = '15m'
    static_issue1.start_time = '10:00'
    static_issue1.adjustment_mode = 'fixed'

    static_issue2 = issues[issues.count - 2]
    static_issue2.duration = '1h23m'
    static_issue2.start_time = '16:00'
    static_issue2.adjustment_mode = 'fixed'

    manager.adjust

    assert durations_valid?(issues)
    assert_equal issues.first, issue
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  def durations_valid?(issues)
    issues.reduce(0) { |res, issue| res + issue.converted_duration } == 60 * 60 * 8
  end
end
