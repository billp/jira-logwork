require 'minitest/autorun'
require 'helpers/execute_command_helpers'
require 'English'

# rubocop:disable Metrics/AbcSize

# Tests jira-worklog commands
class TestWorklogCommands < Minitest::Test
  def test_main_program
    result = CommandExecutor.execute_command
    assert result[:output].include? 'setup'
    assert result[:output].include? 'login'
    assert result[:output].include? 'logout'
    assert result[:output].include? 'config'
    assert result[:output].include? 'version'
    assert result[:exitstatus].zero?
  end
end

# rubocop:enable Metrics/AbcSize
