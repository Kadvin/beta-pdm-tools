# @author Kadvin, Date: 11-12-23
require File.join(File.dirname(__FILE__), "prepare")
require "actor/database"

describe "Database Command" do
  before(:each) do
    @mock = Actor::Database.new
    Actor::Database.stub(:new).and_return(@mock)
  end

  it "should migrate database " do
    @mock.should_receive(:migrate).with(*%W[up STEP1 STEP2])
    run(%Q{database migrate up STEP1 STEP2})
  end

  it "should import files" do
    @mock.should_receive(:import).with(*%W[file1 file2])
    run(%Q{database import file1 file2})
  end

  it "should validate tables" do
    @mock.should_receive(:validate).with(*%W[target_table])
    run(%Q{database validate target_table})
  end

end