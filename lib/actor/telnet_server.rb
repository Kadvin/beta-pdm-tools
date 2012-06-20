# @author Kadvin, Date: 11-12-20

require "actor"
require "net/telnet"
require "active_support/core_ext/hash"
#
# = The Ftp server
#
module Actor

  class TelnetServer < Base

    def initialize(options = {} )
      super
      # convert pdm options to net/telnet options
      @options[:Host] = options.delete(:server)
      @options[:Port] = options.delete(:port)
      @options[:Name] = options.delete(:user)
      @options[:Password] = options.delete(:passwd)
      @options.stringify_keys!
    end

    def execute(*commands)
      connect! do |server|
        commands.each{|cmd|server.cmd(cmd)}
      end
    end

    private
      def connect!
        begin
          server = Net::Telnet.new options
          server.login options
          yield(server)
        ensure
          server.close rescue nil
        end
      end
  end
end