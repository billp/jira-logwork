require_relative 'worklog_manager/worklog_command.rb'

class WorklogManager
  # Construct
  # @param workday_hours [Integer] The total hours of a workday, e.g. 8
  def initialize(workday_hours = nil)
    @workday_hours = workday_hours
  end

  # Updates the daily worklog table by applying the given command.
  #
  # @param command [String] The command that will be applied to the issues parameter. The available commands are:
  #                         - move | m [pos1] [pos2] (e.g. 'm 2 1', it moves the issue from position 1 to position 2 (swipes
  #                                 issues)
  #                         - duration | d [pos] [duration] (e.g. 'd 3 30m', it changes the duration of the issue
  #                                  at position 3 to 30 minutes).
  #                                 Pass 'auto' to automatically expand the duration to fill the required working hours.
  #                         - remove | r [pos] (e.g 'r 3', remove from the position 3)
  #                         - insert | i [pos] (e.g 'i 3', insert into position 3. Pos parameter can be omitted and  the new
  #                                 issue will be inserted at the end )
  # @param issues [Array<WorklogIssue>] The array of worklog issues.
  #
  # @return [Array<WorklogIssue>] The updated array of work log issues.
  # @raise InvalidCommandException
  # @raise ArgumentError
  def update_worklog(command, issues = nil, issue_to_add: nil)
    command_found = get_command(command.strip)
    raise InvalidCommandException, 'Wrong command' if command.nil? || command.empty? || command_found.nil?

    command_found.update_issues(issues, issue_to_add)
  end


  private

  # Represent command and class name
  COMMANDS = {
    m: 'MoveWorklogCommand',
    d: 'DurationWorklogCommand',
    i: 'InsertWorklogCommand',
    r: 'RemoveWorklogCommand'
  }.freeze


  # Return the command executor object
  # @param [String] total_command Should be stripped from spaces
  def get_command(total_command)
    return if total_command.empty?

    command_code = total_command[0].to_sym
    arguments = total_command[1, total_command.size - 1] || ' '

    class_name = COMMANDS[command_code]
    # puts "Got classname #{class_name} for command #{command_code}"
    Object.const_get(class_name).new(arguments, @workday_hours) unless class_name.nil?
  end

end

