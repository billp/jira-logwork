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
