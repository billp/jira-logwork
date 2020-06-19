class WorklogManager
    # Edits worklog issues by applying the given command.
    #
    # @param workday_hours [Integer] The total hours of a workday, e.g. 8
    # @param issues [Array<WorklogIssue>] The array of worklog issues.
    # @param command [String] The command that will be applied to the issues parameter. The available commands are:
    #                         - move|m [pos1] [pos2] (e.g. 'm 2 1', it moves the issue from position 2 to position 1)
    #                         - duration|d [pos] [duration] (e.g. 'd 3 30m', it changes the duration of the issue at position 3 to 30 minutes). Pass 'auto' to automatically expand the duration to fill the required working hours.
    # @return [Array<WorklogIssue>] The updated array of work log issues.
    self.edit_worklog(workday_hours, issues, command)
        
    end
end