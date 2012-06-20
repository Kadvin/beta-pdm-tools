# @author Kadvin, Date: 12-1-5
require File.join(File.dirname(__FILE__), "../env")
require File.join(File.dirname(__FILE__), "../../models/log_record")
require File.join(File.dirname(__FILE__), "../../models/user_task")

describe "LogRecord" do
  before(:all) do
    establish!
  end

  before(:each) do
    @record = LogRecord.new do |record|
      record.thread_name = "http-bio-01"
      record.class_name = "WebController"
      record.method_name = "index"
      record.record_at = "12:00:00,123"
      record.level = "INFO"
      record.file = "ps_userpane.log"
      record.file_no = 1
      record.line_no = 123
      record.title = "Hello world"
      record.identifiers = %W{ruby on rails}
    end
  end

  it "output/input as CSV" do
    csv = @record.to_csv
    another = LogRecord.from_csv(csv)
    another.attributes.should == @record.attributes
  end
end