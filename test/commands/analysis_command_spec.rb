# @author Kadvin, Date: 11-12-23
require File.join(File.dirname(__FILE__), "prepare")
require "actor/analyst"

describe "Analysis Command" do
  before(:each) do
    @mock = Actor::Analyst.new
    Actor::Analyst.stub(:new).and_return(@mock)
  end

  it "should analysis create_mo case" do
    @mock.should_receive(:create_mo).with(*%W[file1 file2])
    run(%Q{analysis create_mo file1 file2})
  end

end