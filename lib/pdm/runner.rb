
require "pdm/commander_manager"
require "pdm/config_file"

module Pdm
  class Runner
    def initialize(options = {})
      @command_manager_class = options[:command_manager] || Pdm::CommandManager
      @config_file_class = options[:config_file] || Pdm::ConfigFile
    end

    def run(args = [])
      start_time = Time.now

      do_configuration args
      manager = @command_manager_class.instance

      manager.command_names.each do |command_name|
        config_args = Pdm.configuration[command_name]
        config_args = case config_args
                      when String
                        config_args.split ' '
                      else
                        Array(config_args)
                      end
        Pdm::Command.add_specific_extra_args command_name, config_args
      end

      manager.run Pdm.configuration.args
      end_time = Time.now

      if Pdm.configuration.benchmark then
        $stderr.printf "\nExecution time: %0.2f seconds.\n", end_time - start_time
        #puts "Press Enter to finish"
        #STDIN.gets
      end
    end

    private

    def do_configuration(args)
      Pdm.configuration = @config_file_class.new(args)
      Pdm::Command.extra_args = Pdm.configuration[:pdm]
    end
  end
end
