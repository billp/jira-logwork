# frozen_string_literal: true

require 'test/unit'
require 'exceptions'
require 'worklog_manager'
require 'models/worklog_issue'
require 'database'
require 'utilities'
require 'test_helpers'

# Test WorkLogManager
class TestWorklogManager < Test::Unit::TestCase
  def setup
    TestHelpers.setup_test
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
    old_issues = TestHelpers.create_sample_issues
    new_issues = WorklogManager.new(TestHelpers.create_sample_issues).update_worklog('m 2 1')
    assert_equal new_issues[1], old_issues[2]
    assert_equal new_issues[2], old_issues[1]
  end

  def test_move_command_errors
    # should throw out of bounds
    exception = false
    begin
      WorklogManager.new(TestHelpers.create_sample_issues).update_worklog('m 2 10')
    rescue ArgumentError
      exception = true
    end

    assert_true exception
  end

  def test_move_command_same_argument
    # should throw out of bounds
    exception = false
    begin
      WorklogManager.new(TestHelpers.create_sample_issues).update_worklog('m 2 2')
    rescue ArgumentError
      exception = true
    end

    assert_true exception
  end

  def test_insert_command_with_nil_issue
    exception = false
    begin
      WorklogManager.new.update_worklog('i', issue_to_add: nil)
    rescue ArgumentError
      exception = true
    end
    assert_true exception
  end

  def test_insert_command_on_empty_array
    new_issues = WorklogManager.new.update_worklog('i', issue_to_add: 'ABC-DEF132')
    assert_not_nil new_issues
    assert_equal new_issues.class, Array
    assert_equal new_issues[0], TestHelpers.mocked_issue
  end

  def test_insert_command
    new_issues = WorklogManager.new(TestHelpers.create_sample_issues).update_worklog('i 3', issue_to_add: 'ABC-DEF132')

    assert_equal new_issues[3], TestHelpers.mocked_issue
  end

  def test_insert_command_on_last_position
    new_issues = WorklogManager.new(TestHelpers.create_sample_issues).update_worklog('i 5', issue_to_add: 'ABC-DEF132')

    assert_equal new_issues[5], TestHelpers.mocked_issue
  end

  def test_insert_command_on_out_of_bounds
    new_issues = WorklogManager.new(TestHelpers.create_sample_issues).update_worklog('i 15', issue_to_add: 'ABC-DEF132')

    assert_equal new_issues[5], TestHelpers.mocked_issue
  end

  def test_remove_command
    new_issues = WorklogManager.new(TestHelpers.create_sample_issues).update_worklog('r 3')
    assert_equal new_issues[3], TestHelpers.create_sample_issues[4]
  end

  def test_remove_command_out_of_bounds
    exception = false
    begin
      WorklogManager.new(TestHelpers.create_sample_issues).update_worklog('r 31')
    rescue ArgumentError
      exception = true
    end

    assert_true exception
  end

  def test_duration_command
    new_issues = WorklogManager.new(TestHelpers.create_sample_issues).update_worklog('d 3 30m')
    assert_equal new_issues[3].duration, '30m'
  end

  def test_update_start_time_command
    new_issues = WorklogManager.new(TestHelpers.create_sample_issues).update_worklog('s 3 10:15')
    assert_equal new_issues[3].start_time, '10:15'
  end
end
