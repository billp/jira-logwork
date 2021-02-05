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

# frozen_string_literal: true

# Menu main class
class Menu
  # Initialize a new menu
  #
  # @param [Slop:Result] A slop menu instance.
  # @param [Hash] A hash that includes the command line arguments.
  # @param [Hash] A hash that includes procs that will be executed for each command.
  def initialize(menu, input_map = {}, procs_map = {})
    self.menu = menu

    run_selected_command(create_input_map.merge(input_map),
                         create_procs_map.merge(procs_map))
  end

  def create_procs_map; end

  def create_input_map; end

  # Run user's selected command
  def run_selected_command(input, procs)
    selected_key = input.keys.select { |key| input[key] }.first
    if selected_key.nil?
      run_default
      return
    end

    procs[selected_key].call
  end

  # Print help
  def run_default
    puts menu
  end

  private

  attr_accessor :menu, :procs, :input
end
