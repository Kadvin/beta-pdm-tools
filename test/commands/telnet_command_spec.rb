# @author Kadvin, Date: 11-12-23
require File.join(File.dirname(__FILE__), "prepare")
require "actor/telnet_server"

describe "Telnet Command" do

    it "should use telnet server to send command" do
      mock = Actor::TelnetServer.new(:port => "23")

      Actor::TelnetServer.stub(:new).and_return(mock)

      mock.should_receive(:execute).with(*%W[cmd1 cmd2])

      run(%Q{telnet cmd1 cmd2})
    end


end