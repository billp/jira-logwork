require "minitest/autorun"
require "logwork_exception"
require "logwork_manager"
require "models/logwork_issue"
require "mocha/minitest"
require "database"

# Test LogworkManager
class TestLogworkManager < Minitest::Test
  def setup
    Database.prepare_database
  end

  def test_wrong_command
    exception = false
    random_command = "f 45" # will throw exception
    begin
      LogworkManager.new.update_worklog(random_command)
    rescue LogworkException::InvalidCommand
      exception = true
    end

    assert exception
  end

  def test_move_command
    issues = create_sample_issues
    new_issues = LogworkManager.new.update_worklog("m 2 1", issues)

    assert_equal new_issues[1].id, 2
    assert_equal new_issues[2].id, 1
  end

  def test_move_command_errors
    # should throw out of bounds
    exception = false
    begin
      LogworkManager.new.update_worklog("m 2 10", create_sample_issues)
    rescue LogworkException::ArgumentError
      exception = true
    end

    assert exception
  end

  def test_move_command_same_argument
    # should throw out of bounds
    exception = false
    begin
      LogworkManager.new.update_worklog("m 2 2", create_sample_issues)
    rescue LogworkException::ArgumentError
      exception = true
    end

    assert exception
  end

  def test_insert_command_with_nil_issue
    exception = false
    begin
      LogworkManager.new.update_worklog("i", nil, issue_to_add: nil)
    rescue LogworkException::ArgumentError
      exception = true
    end
    assert exception
  end

  def test_insert_command_on_empty_array
    issue = LogworkIssue.new(id: 200)
    new_issues = LogworkManager.new.update_worklog("i", nil, issue_to_add: issue)
    assert !new_issues.nil?
    assert_equal new_issues.class, Array
    assert_equal new_issues[0].id, issue.id
  end

  def test_insert_command
    issue = LogworkIssue.new(id: 200)
    new_issues = LogworkManager.new.update_worklog("i 3", create_sample_issues, issue_to_add: issue)

    assert_equal new_issues[3].id, issue.id
  end

  def test_insert_command_on_last_position
    issue = LogworkIssue.new(id: 200)
    new_issues = LogworkManager.new.update_worklog("i 5", create_sample_issues, issue_to_add: issue)

    assert_equal new_issues[5].id, issue.id
  end

  def test_insert_command_on_out_of_bounds
    issue = LogworkIssue.new(id: 200)
    new_issues = LogworkManager.new.update_worklog("i 15", create_sample_issues, issue_to_add: issue)

    assert_equal new_issues[5].id, issue.id
  end

  def test_remove_command
    new_issues = LogworkManager.new.update_worklog("r 3", create_sample_issues)
    assert_equal new_issues[3].id, 4
  end

  def test_remove_command_out_of_bounds
    exception = false
    begin
      LogworkManager.new.update_worklog("r 31", create_sample_issues)
    rescue LogworkException::ArgumentError
      exception = true
    end

    assert exception
  end

  def test_duration_command
    new_issues = LogworkManager.new.update_worklog("d 3 30m", create_sample_issues)
    assert_equal new_issues[3].duration, "30m"
  end

  def create_sample_issues
    [
      LogworkIssue.new(id: 0),
      LogworkIssue.new(id: 1),
      LogworkIssue.new(id: 2),
      LogworkIssue.new(id: 3),
      LogworkIssue.new(id: 4)
    ]
  end
end
