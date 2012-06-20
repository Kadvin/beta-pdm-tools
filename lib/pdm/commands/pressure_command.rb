require 'pdm/command'
require 'pdm/generic_option'

module Pdm
  module Commands
    class PressureCommand < Pdm::Command
      include Pdm::GenericOption

      def initialize
        super 'pressure', 'Pressure test related operations', :port => 8020

        add_server_option
        add_port_option

      end #end of the initialize

      def usage
        usages = <<-EOF
          #{program_name} httperf|ab PATH/TO/PRESSURE/FILE -s SERVER_IP -p SERVER_PORT
        EOF
        usages.gsub!(/^\s+/, '')
        usages.gsub!(/\n$/, '')
        usages
      end

      def arguments
        usages = <<-EOF
          TOOL        THE/PRESSURE/TOOL/NAME, such as httperf, ab ...
          PATH        PATH/TO/PRESSURE/FILE
        EOF
        usages.gsub(/^\s+/, '')
      end

      def defaults
        "--port 8020"
      end

      def execute
        require "actor/pressure"
        args = options.delete(:args)
        sub_cmd = args.shift
        worker = Actor::Pressure.new options
        worker.send(sub_cmd, *args)
      end # end of execute

    end #end of the PressureCommand
  end
end
