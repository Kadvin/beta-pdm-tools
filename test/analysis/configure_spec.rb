# @author Kadvin, Date: 11-12-27
require File.join(File.dirname(__FILE__), "prepare")

describe "Engine Configure" do

  before(:each) do
    @engine = Analysis::Engine.new
  end

  it "should get same effect when call on static method" do
    Analysis::Engine.configure do
      if_file_like(/my-file-pattern/) do
        log_should_like(/file-log-ptn/)
      end
    end
    Analysis::Engine.instance.file_rules.should include(/my-file-pattern/)
  end

  it "should blame for incomplete rule set(miss log_pattern)" do
    lambda do
      @engine.configure do
        if_file_like(/file-ptn/)
      end
    end.should raise_error
  end

  it "should add a rule set for a named file pattern" do
    @engine.configure do
      if_file_like(/file-ptn/) do
        log_should_like(/log-ptn/)
      end
    end
    @engine.rule_set(/file-ptn/).should_not be_nil
  end

  it "should support create multiple different rule in one rule set" do
    @engine.configure do
      log_should_like(/general-log-ptn/)
      if_file_like(/file-ptn/) do # context in RuleSet
        if_content_like(/content-ptn/).identified_by('identifier-exp').title_will_be('title-exp')
        if_content_like(/content-ptn/).identified_by('identifier-exp').title_will_be('title-exp')
      end
    end
    @engine.rule_set(/file-ptn/).should include("rule-1")
    @engine.rule_set(/file-ptn/).should include("rule-2")
  end

  it "should inherit global log pattern for rule set" do
    @engine.configure do
      log_should_like(/log-ptn/){|file, file_no, line_no, md| LogRecord.new(:file_no => file_no, :line_no => line_no, :content=>md[6])}
      if_file_like(/file-ptn/)
    end
    @engine.global_log_pattern.should_not be_nil
    @engine.global_record_proc.should_not be_nil
    @engine.rule_set(/file-ptn/).log_ptn.should_not be_nil
    @engine.rule_set(/file-ptn/).record_proc.should_not be_nil
  end

  it "should refer the pre-defined patterns" do
    @engine.configure do
      define_pattern :mo, /mo-ptn/
      define_pattern :task, /task-ptn/
      log_should_like(task_ptn)
      log_should_like(mo_pattern)
    end
    @engine.global_log_pattern.should == /mo-ptn/
  end


end