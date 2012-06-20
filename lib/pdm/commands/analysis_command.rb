require 'pdm/command'
require 'pdm/generic_option'

module Pdm
  module Commands
    class AnalysisCommand < Pdm::Command
      include Pdm::GenericOption

      def initialize
        super 'analysis', 'Process logs to analysis the pressure test result',
        :adapter => "mysql", :encoding => "utf8"

        add_db_options
        add_option('-t','--timestamp TIME', String, "The log records older than this timestamp won't be analysed") do |timestamp, options|
          options[:timestamp] = timestamp
        end

      end #end of the initialize

      def usage
        "#{program_name} CASE  [LOG FILES...]"
      end

      def arguments
        args = <<-EOF
          PRESSURE_CASE           Pressure test case
          FILE1 FILE2             Log Files to be analysed
        EOF
        args.gsub(/^\s+/, '')
      end

      def defaults
        "--adapter mysql --encoding utf8"
      end

      def execute
        require "actor/analyst"
        args = options.delete(:args)
        analyst = Actor::Analyst.new(options)
        sub_cmd = args.shift
        analyst.send(sub_cmd, *args)
      end # end of execute

    end #end of the FtpCommand
  end
end
