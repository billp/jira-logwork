# frozen_string_literal: true

require 'test/unit'
require 'exceptions'
require 'worklog_manager'
require 'models/worklog_issue'
require 'database'
require 'utilities'

# Test WorkLogManager
class TestWorklogManager < Test::Unit::TestCase
  def setup
    Database.prepare_test_database
  end

  def test_wrong_command
    exception = false
    random_command = 'f 45' # will throw exception
    begin
      WorklogManager.new.update_worklog(random_command)
    rescue InvalidCommandException
      exception = true
    end

    assert_true exception
  end

  def test_move_command
    old_issues = create_sample_issues
    new_issues = WorklogManager.new.update_worklog('m 2 1', create_sample_issues)
    assert_equal new_issues[1], old_issues[2]
    assert_equal new_issues[2], old_issues[1]
  end

  def test_move_command_errors
    # should throw out of bounds
    exception = false
    begin
      WorklogManager.new.update_worklog('m 2 10', create_sample_issues)
    rescue ArgumentError
      exception = true
    end

    assert_true exception
  end

  def test_move_command_same_argument
    # should throw out of bounds
    exception = false
    begin
      WorklogManager.new.update_worklog('m 2 2', create_sample_issues)
    rescue ArgumentError
      exception = true
    end

    assert_true exception
  end

  def test_insert_command_with_nil_issue
    exception = false
    begin
      WorklogManager.new.update_worklog('i', nil, issue_to_add: nil)
    rescue ArgumentError
      exception = true
    end
    assert_true exception
  end

  def test_insert_command_on_empty_array
    new_issues = WorklogManager.new.update_worklog('i', nil, issue_to_add: 'ABC-DEF132')
    assert_not_nil new_issues
    assert_equal new_issues.class, Array
    assert_equal new_issues[0], mocked_issue
  end

  def test_insert_command
    new_issues = WorklogManager.new.update_worklog('i 3', create_sample_issues, issue_to_add: 'ABC-DEF132')

    assert_equal new_issues[3], mocked_issue
  end

  def test_insert_command_on_last_position
    new_issues = WorklogManager.new.update_worklog('i 5', create_sample_issues, issue_to_add: 'ABC-DEF132')

    assert_equal new_issues[5], mocked_issue
  end

  def test_insert_command_on_out_of_bounds
    new_issues = WorklogManager.new.update_worklog('i 15', create_sample_issues, issue_to_add: 'ABC-DEF132')

    assert_equal new_issues[5], mocked_issue
  end

  def test_remove_command
    new_issues = WorklogManager.new.update_worklog('r 3', create_sample_issues)
    assert_equal new_issues[3], create_sample_issues[4]
  end

  def test_remove_command_out_of_bounds
    exception = false
    begin
      WorklogManager.new.update_worklog('r 31', create_sample_issues)
    rescue ArgumentError
      exception = true
    end

    assert_true exception
  end

  def test_duration_command
    new_issues = WorklogManager.new.update_worklog('d 3 30m', create_sample_issues)
    assert_equal new_issues[3].duration, '30m'
  end

  def test_update_start_time_command
    new_issues = WorklogManager.new.update_worklog('s 3 10:15', create_sample_issues)
    assert_equal new_issues[3].start_time, '10:15'
  end

  # rubocop:disable Metrics/MethodLength
  def create_sample_issues
    [
      WorklogIssue.new(jira_id: 'ABC-1234', description: 'Bug #1',
                       adjustment_mode: :auto, duration: nil, start_time: '10:00', date: '10/10/2020', repeat: 5),
      WorklogIssue.new(jira_id: 'ASDC-2131', description: 'Bug #2',
                       adjustment_mode: :fixed, duration: '20m', repeat: 3),
      WorklogIssue.new(jira_id: 'AXA-385', description: 'Bug #3',
                       adjustment_mode: :auto, duration: '60m', repeat: 0),
      WorklogIssue.new(jira_id: 'BAX-994', description: 'Bug #4',
                       adjustment_mode: :fixed, duration: nil, date: nil, repeat: 2),
      WorklogIssue.new(jira_id: 'XAS-511', description: 'Bug #5',
                       adjustment_mode: :auto, duration: nil, date: nil, repeat: 1)
    ]
  end
  # rubocop:enable Metrics/MethodLength

  def mocked_issue
    parsed = Utilities.parse_json(File.read('./tests/mock_data/issue.json'))
    WorklogIssue.new(jira_id: parsed[:key], description: parsed[:fields][:summary])
  end
end
