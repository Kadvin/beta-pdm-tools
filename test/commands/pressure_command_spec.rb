# @author Kadvin, Date: 11-12-23
require File.join(File.dirname(__FILE__), "prepare")
require "actor/pressure"

describe "Pressure Command" do
  before(:each) do
    @mock = Actor::Pressure.new
    Actor::Pressure.stub(:new).and_return(@mock)
  end

  it "should use httperf to test target server" do
    @mock.should_receive(:httperf).with(*%W[path/to/pressure/file])
    run(%Q{pressure httperf path/to/pressure/file -s 20.0.9.111 -p 8020})
  end

  it "should use ab to test target server" do
    @mock.should_receive(:ab).with(*%W[path/to/pressure/file])
    run(%Q{pressure ab path/to/pressure/file -s 20.0.9.111 -p 8020})
  end


end