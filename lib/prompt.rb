require "utilities"
require "io/console"
require "logwork_exception"

# Class for prompting in terminal
class Prompt
  def ask(message, options = {})
    print "#{message} "
    input = $stdin.gets.chomp

    # Print input if running under specs
    Utilities.rspec_running? && (puts input)

    # Check for required input
    check_input(options, input)

    input
  end

  def mask(message, options = {})
    # Use simple output for specs
    Utilities.rspec_running? && (ask(message, options) && return)

    print "#{message} "
    return unless $stdin.class.method_defined?(:noecho)

    pass = $stdin.noecho(&:gets).chomp

    # Check for required input
    check_input(options, pass)

    puts
    pass
  end

  private

  # validations
  def check_input(options, value)
    required?(options) && value.empty? && (raise LogworkException::InputIsRequired.new, "Input is required.")
  end

  def required?(options)
    options.key?(:required) && options[:required]
  end
end
