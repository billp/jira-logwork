# Copyright © 2020-2021. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in the
# Software without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies
# or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FIESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
# FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
