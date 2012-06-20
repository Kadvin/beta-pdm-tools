require 'pdm/command'
require 'pdm/generic_option'

module Pdm
  module Commands
    class UserpaneCommand < Pdm::Command
      include Pdm::GenericOption

      def initialize
        super 'userpane', 'Call PDM userpane by RESTful API', :port => "8020"

        add_server_option("USERPANE_ADDRESS")
        add_port_option("USERPANE_PORT")
        add_option('-f', "--filter [KEY]", "Filter responded json result by key") do |key, options|
          options[:filter] = key
        end

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
          MODEL              userpane supported models, plural or single form, abbr is supported, such as: mo -> managed_object
          ARGUMENTS          other customized arguments recognized the sub command
        EOF
        usages.gsub(/^\s+/, '')
      end

      def defaults
        "--port 8020"
      end

      def execute
        require "actor/userpane"
        args = options.delete(:args)
        userpane = Actor::Userpane.new(options)
        sub_cmd = args.shift
        userpane.send(sub_cmd, *args)
      end # end of execute

    end #end of the UserpaneCommand
  end
end
