require 'pdm/command'
require 'pdm/generic_option'

module Pdm
  module Commands
    class AcceptCommand < Pdm::Command
      include Pdm::GenericOption
      def initialize
        super 'accept', 'Run accept test cases',
              :case_api_delay => 1,
              :case_get_indicator_delay => 0,
              :case_probe_tolerance => false,
              :case_threshold_receive => false,
              :case_record_receiver => false
        add_option('-a','--case_api_delay NUMBER', Numeric, "how many workers test the API delay") do |total, options|
          options[:case_api_delay] = total
        end
        add_option('-g','--case_get_indicator_delay NUMBER', Numeric, "how many workers test the Get Indicator delay") do |total, options|
          options[:case_get_indicator_delay] = total
        end
        add_option('-p','--case_probe_tolerance [FLAG]', String, "Check the probe tolerance or not") do |flag, options|
          options[:case_probe_tolerance] = !("false" == flag)
        end
        add_option('-t','--case_threshold_receive [FLAG]', String, "Check the threshold event lost or not") do |flag, options|
          options[:case_threshold_receive] = !("false" == flag)
        end
        add_option('-r','--case_record_receive [FLAG]', String, "Check the record data lost or not") do |flag, options|
          options[:case_record_receive] = !("false" == flag)
        end

      end #end of the initialize

      def usage
        usages = <<-EOF
          #{program_name} IP
        EOF
        usages.gsub!(/^\s+/, '')
        usages.gsub!(/\n$/, '')
        usages
      end

      def arguments
        usages = <<-EOF
          IP        the test pdm server
        EOF
        usages.gsub(/^\s+/, '')
      end

      def defaults
        ""
      end

      def execute
        require "actor/acceptor"
        args = options.delete(:args)
        accept = Actor::Acceptor.new options
        accept.run(*args)
      end # end of execute

    end #end of the FactorCommand
  end
end
