# @author Kadvin, Date: 11-12-21

require "pdm/command"
require 'rubygems/user_interaction'

module Pdm
  #
  # = The commander manager of pdm tool set
  #
  class CommandManager
    include Gem::UserInteraction
    ##
    # Return the authoritative instance of the command manager.
    #
    def self.instance
      @command_manager ||= new
    end

    def initialize
      require 'timeout' #ruby core lib
      @commands = {}
      register_command :ftp            # use ftp to get/put release,logs
      register_command :telnet         # use telnet to control remote system(start/stop system, etc)
      register_command :userpane       # use userpane to get exist data
      register_command :adminpane      # use adminpane to get exist data
      register_command :factor         # use factor to generate all kinds of input data for template to use
      register_command :template       # use template to generate pressure file
      register_command :pressure       # use pressure to perform pressure test against target server
      register_command :analysis       # use analysis to analysis the logs
      register_command :database       # use database to save analysed result
      register_command :accept         # display accept
      register_command :help           # display help information
    end

    ##
    # Register the Symbol +command+ as a pdm command.
    #
    def register_command(command)
      @commands[command] = false
    end

    ##
    # Return the registered command from the command name.
    #
    def [](command_name)
      command_name = command_name.intern
      return nil if @commands[command_name].nil?
      @commands[command_name] ||= load_and_instantiate(command_name)
    end

    ##
    # Return a sorted list of all command names (as strings).
    #
    def command_names
      @commands.keys.collect { |key| key.to_s }.sort
    end

    ##
    # Run the config specified by +args+.
    #
    def run(args)
      process_args(args)
    rescue StandardError, Timeout::Error => ex
      alert_error "While executing pdm ... (#{ex.class})\n    #{ex.to_s}\n#{ex.backtrace.join("\n")}"
      ui.errs.puts "\t#{ex.backtrace.join "\n\t"}" if Pdm.configuration.backtrace
      terminate_interaction(1)
    rescue Interrupt
      alert_error "Interrupted"
      terminate_interaction(1)
    end

    def process_args(args)
      args = args.to_str.split(/\s+/) if args.respond_to?(:to_str)
      if args.empty?
        say Pdm::Command::HELP
        terminate_interaction(1)
      end
      case args[0]
        when '-h', '--help'
          say Pdm::Command::HELP
          terminate_interaction(0)
        when '-v', '--version'
          say Pdm::VERSION
          terminate_interaction(0)
        when /^-/
          alert_error "Invalid option: #{args[0]}.  See 'pdm --help'."
          terminate_interaction(1)
        else
          cmd_name = args.shift.downcase
          cmd = find_command(cmd_name)
          cmd.invoke(*args)
      end
    end

    def find_command(cmd_name)
      possibilities = find_command_possibilities cmd_name
      if possibilities.size > 1 then
        raise "Ambiguous command #{cmd_name} matches [#{possibilities.join(', ')}]"
      elsif possibilities.size < 1 then
        raise "Unknown command #{cmd_name}"
      end

      self[possibilities.first]
    end

    def find_command_possibilities(cmd_name)
      len = cmd_name.length

      command_names.select { |n| cmd_name == n[0, len] }
    end

    private

    def load_and_instantiate(command_name)
      command_name = command_name.to_s
      const_name = command_name.capitalize.gsub(/_(.)/) { $1.upcase } << "Command"
      commands = Pdm::Commands
      retried = false

      begin
        commands.const_get const_name
      rescue NameError
        raise if retried

        retried = true
        begin
          require "pdm/commands/#{command_name}_command"
        rescue Exception => e
          alert_error "Loading command: #{command_name} (#{e.class})\n    #{e}"
          ui.errs.puts "\t#{e.backtrace.join "\n\t"}" if Pdm.configuration.backtrace
        end
        retry
      end.new
    end

  end
end
