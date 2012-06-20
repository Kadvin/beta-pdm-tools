require 'pdm/command'
require 'pdm/generic_option'

module Pdm
  module Commands
    class AdminpaneCommand < Pdm::Command
      include Pdm::GenericOption

      def initialize
        super 'adminpane', 'Call PDM adminpane', :port => "8010"

        add_server_option("USERPANE_ADDRESS")
        add_port_option("USERPANE_PORT")

      end #end of the initialize

      def usage
        usages = <<-EOF
          #{program_name} list probe_packages [options] > OUTPUT/FILE
          Or:    #{program_name} create mo < INPUT/JSON/FILE  > OUTPUT/FILE
        EOF
        usages.gsub!(/^\s+/, '')
        usages.gsub!(/\n$/, '')
        usages
      end

      def arguments
        usages = <<-EOF
          VERB               standard REST verbs(list|show|create|update|delete) or customized verbs(activate|deactivate...)
          MODEL              adminpane supported models, plural or single form, abbr is supported, such as: mo -> managed_object
          ARGUMENTS          other customized arguments recognized the sub command
        EOF
        usages.gsub(/^\s+/, '')
      end

      def defaults
        "--port 8010"
      end

      def execute
        require "actor/adminpane"
        args = options.delete(:args)
        adminpane = Actor::Adminpane.new(options)
        sub_cmd = args.shift
        adminpane.send(sub_cmd, *args)
      end # end of execute

    end #end of the AdminpaneCommand
  end
end
