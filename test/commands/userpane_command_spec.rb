# @author Kadvin, Date: 11-12-23
require File.join(File.dirname(__FILE__), "prepare")
require "actor/userpane"

describe "Userpane Command" do
  before(:each) do
    @mock = Actor::Userpane.new(:port => "8020")
    Actor::Userpane.stub(:new).and_return(@mock)
  end

  it "should use userpane to list models" do
    @mock.should_receive(:list).with(*%W[mos])
    run(%Q{userpane list mos})
  end

  it "should use userpane to delete model by key" do
    @mock.should_receive(:delete).with(*%W[mos key])
    run(%Q{userpane delete mos key})
  end

  it "should use userpane to clear models" do
    @mock.should_receive(:clear).with(*%W[mos])
    run(%Q{userpane clear mos})
  end


end