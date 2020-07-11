# frozen_string_literal: true

# Abstract class which represents a worklog command
#
class WorklogCommand
  def initialize(arguments, workday_hours)
    return if arguments.nil?
    raise ArgumentError, 'arguments should be a string' if arguments.class != String

    @args = arguments.strip.split(' ')
    @workday_hours = workday_hours
  end

  # @abstract
  def update_issues(*)
    raise 'Not implemented'
  end

  private

  # Check if pos parameter is in bounds of positions of arrys issues
  # @param issues [Array<WorklogIssue>]
  # @param pos [Integer] The position that should be in bounds
  # @raise ArgumentError , When the argument is out of bounds
  def check_out_of_bounds(issues, pos)
    raise ArgumentError, "Argument out of bounds #{pos}" if pos.negative? || pos >= issues.length
  end

  # Array of the parsed arguments of the command.
  @args = []
end

# Command for remove action
class RemoveWorklogCommand < WorklogCommand
  def initialize(arguments, _)
    super
    raise ArgumentError, "Wrong number of arguments #{@args}" if @args.size != 1

    @pos = Integer(@args[0])
  end

  def update_issues(issues, _)
    check_out_of_bounds(issues, @pos)

    issues.delete_at @pos
    issues
  end
end

# Command for insert action
class InsertWorklogCommand < WorklogCommand
  def initialize(arguments, workday_hours)
    super
    @position_to_insert = @args.empty? ? 0 : Integer(@args[0])
  end

  def update_issues(issues, issue_to_add)
    raise ArgumentError, 'Missing issue param' if issue_to_add.nil?

    issues = [] if issues.nil?

    @position_to_insert = issues.size if @position_to_insert > issues.size
    issues.insert(@position_to_insert, issue_to_add)
  end
end

# Command for move action
class MoveWorklogCommand < WorklogCommand
  def initialize(arguments, workday_hours)
    super(arguments, workday_hours)
    raise ArgumentError, "Wrong numberof arguments #{@args}" if @args.size != 2

    @pos1 = Integer(@args[0])
    @pos2 = Integer(@args[1])
  end

  def update_issues(issues, _)
    check_out_of_bounds(issues, @pos1)
    check_out_of_bounds(issues, @pos2)
    raise ArgumentError, "Pos 1 and pos 2 can not be equal #{@args}" if @pos1 == @pos2

    # swapping positions
    temp = issues[@pos1]
    issues[@pos1] = issues[@pos2]
    issues[@pos2] = temp

    issues
  end
end

# Command for duration action
class DurationWorklogCommand < WorklogCommand
  def initialize(arguments, workday_hours)
    super
    raise "Wrong numberof arguments #{@args}" if @args.size != 2

    @pos = Integer(@args[0])
    @duration = @args[1]
  end

  def update_issues(issues, _)
    check_out_of_bounds(issues, @pos)
    issues[@pos].duration = @duration
    issues
  end
end
