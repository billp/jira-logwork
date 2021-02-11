require "menu/generator"
require "menu/main"
require "menu/config"
require "menu/scheduled"

module Menu
  # Parse user input
  class Parser
    # Parse command-line arguments for main menu
    def self.parse_main_arguments
      menu = Menu::Generator.make_main_menu
      extra_input = {
        config: menu[:config],
        scheduled: menu[:scheduled]
      }
      extra_procs = {
        config: proc { parse_config_arguments },
        scheduled: proc { parse_scheduled_arguments }
      }
      Menu::Main.new(menu, extra_input, extra_procs)
    end

    def self.parse_config_arguments
      Menu::Config.new(Menu::Generator.make_config_menu)
    end

    def self.parse_scheduled_arguments
      Menu::Scheduled.new(Menu::Generator.make_scheduled_menu)
    end
  end
end
