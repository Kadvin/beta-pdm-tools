# @author Kadvin, Date: 11-12-23
require File.join(File.dirname(__FILE__), "prepare")
require "actor/factor"

describe "Factor Command" do
  before(:each) do
    @mock = Actor::Factor.new
    Actor::Factor.stub(:new).and_return(@mock)
  end

  it "should generate ip addresses" do
    @mock.should_receive(:ip).with(*%W[100])
    run(%Q{factor ip 100 --start 192.168.0.10})
  end

  it "should generate repeat values" do
    @mock.should_receive(:repeat).with(*%W[100 10])
    run(%Q{factor repeat 100 10})
  end

  it "should generate increase values" do
    @mock.should_receive(:increase).with(*%W[100 10])
    run(%Q{factor increase 100 10 --step 2})
  end


end