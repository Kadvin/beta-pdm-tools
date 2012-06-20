require 'pdm/command'
require 'pdm/generic_option'

module Pdm
  module Commands
    class FactorCommand < Pdm::Command
      include Pdm::GenericOption

      def initialize
        super 'factor', 'Generate pressure factors'

        add_option('--start IP', String,
                   "Start ip address") do |ip, options|
          options[:start] = ip
        end
        add_option('--step STEP', Integer, "Step value between increased values") do |step, options|
          options[:step] = step
        end

      end #end of the initialize

      def usage
        usages = <<-EOF
          #{program_name} ip 500 --start 192.168.0.10 > OUTPUT/FILE
          Or:    #{program_name} repeat some-value repeat-times > OUTPUT/FILE
          Or:    #{program_name} increase some-value increase-times --step x > OUTPUT/FILE
        EOF
        usages.gsub!(/^\s+/, '')
        usages.gsub!(/\n$/, '')
        usages
      end

      def arguments
        usages = <<-EOF
          SUB_COMMAND        factor algorithm such as: ip, repeat, increase
          ARGUMENTS          other customized arguments recognized the sub command
        EOF
        usages.gsub(/^\s+/, '')
      end

      def defaults
        ""
      end

      def execute
        require "actor/factor"
        args = options.delete(:args)
        sub_cmd = args.shift
        httperf = Actor::Factor.new options
        httperf.send(sub_cmd, *args)
      end # end of execute

    end #end of the FactorCommand
  end
end
