# Class that handles the command execution
class CommandExecutor
  def self.execute_command(command: nil)
    bin_path = File.join(File.expand_path('../..', __dir__), 'bin')
    result = `#{bin_path}/jira-logwork #{command}`
    exitstatus = $CHILD_STATUS.exitstatus

    { output: result, exitstatus: exitstatus }
  end
end
