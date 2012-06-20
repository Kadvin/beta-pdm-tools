require 'pdm/command'
require 'pdm/generic_option'

module Pdm
  module Commands
    class TelnetCommand < Pdm::Command
      include Pdm::GenericOption

      def initialize
        super 'telnet', 'Use telnet to execute remote command', :p => "23"

        add_server_option("TELNET_SERVER")
        add_port_option("TELNET_PORT")
        add_user_option("TELNET_USER")
        add_passwd_option("TELNET_PASSWD")

      end #end of the initialize

      def usage
        usages = <<-EOF
          #{program_name} \"remote command to be executed\" [options]
          Or:    #{program_name} < PATH/TO/SCRIPT
        EOF
        usages.gsub!(/^\s+/, '')
        usages.gsub!(/\n$/, '')
        usages
      end

      def arguments
        usages = <<-EOF
          "REMOTE_CMD"           quoted commands to be executed, multiple line should be separated by "\\n"
          or
          PATH/TO/SCRIPT         script file to be executed by the target server
        EOF
        usages.gsub(/^\s+/, '')
      end

      def defaults
        "--port 23"
      end

      def execute
        require "actor/telnet_server"
        args = options.delete(:args)
        telnet = Actor::TelnetServer.new options
        telnet.execute(*args)
      end # end of execute

    end #end of the TelnetCommand
  end
end
