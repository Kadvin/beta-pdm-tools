# @author Kadvin, Date: 11-12-23
require File.join(File.dirname(__FILE__), "prepare")
require "actor/template"

describe "Template Command" do
  before(:each) do
    @mock = Actor::Template.new
    Actor::Template.stub(:new).and_return(@mock)
  end

  it "should generate create_mo according input file" do
    @mock.should_receive(:create_mo).with(*%W[path/to/json])
    run(%Q{template create_mo path/to/json})
  end

  it "should generate delete_mo according input file" do
    @mock.should_receive(:delete_mo).with(*%W[path/to/json])
    run(%Q{template delete_mo path/to/json})
  end

  it "should generate sample_mo according input file" do
    @mock.should_receive(:sample_mo).with(*%W[path/to/json])
    run(%Q{template sample_mo path/to/json})
  end

end