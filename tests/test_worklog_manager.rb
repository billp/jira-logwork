# frozen_string_literal: true

require 'test/unit'
require 'exceptions'
require 'worklog_manager'
require 'models/worklog_issue'
require 'database'

# Test WorkLogManager
class TestWorklogManager < Test::Unit::TestCase
  def setup
    Database.prepare_database
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
    issues = create_sample_issues
    new_issues = WorklogManager.new.update_worklog('m 2 1', issues)

    assert_equal new_issues[1].id, 2
    assert_equal new_issues[2].id, 1
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
    issue = WorklogIssue.new(id: 200)
    new_issues = WorklogManager.new.update_worklog('i', nil, issue_to_add: issue)
    assert_not_nil new_issues
    assert_equal new_issues.class, Array
    assert_equal new_issues[0].id, issue.id
  end

  def test_insert_command
    issue = WorklogIssue.new(id: 200)
    new_issues = WorklogManager.new.update_worklog('i 3', create_sample_issues, issue_to_add: issue)

    assert_equal new_issues[3].id, issue.id
  end

  def test_insert_command_on_last_position
    issue = WorklogIssue.new(id: 200)
    new_issues = WorklogManager.new.update_worklog('i 5', create_sample_issues, issue_to_add: issue)

    assert_equal new_issues[5].id, issue.id
  end

  def test_insert_command_on_out_of_bounds
    issue = WorklogIssue.new(id: 200)
    new_issues = WorklogManager.new.update_worklog('i 15', create_sample_issues, issue_to_add: issue)

    assert_equal new_issues[5].id, issue.id
  end

  def test_remove_command
    new_issues = WorklogManager.new.update_worklog('r 3', create_sample_issues)
    assert_equal new_issues[3].id, 4
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

  def create_sample_issues
    [
      WorklogIssue.new(id: 0),
      WorklogIssue.new(id: 1),
      WorklogIssue.new(id: 2),
      WorklogIssue.new(id: 3),
      WorklogIssue.new(id: 4)
    ]
  end
end
