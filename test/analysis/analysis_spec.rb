require File.join(File.dirname(__FILE__), "prepare")

describe "Engine Analysis" do

  before(:each) do
    @engine = Analysis::Engine.new
  end

  it "should process files by configured order " do
    @engine.configure do
      log_should_like(/general-log-ptn/)
      if_file_like("ps_hub.log")
      if_file_like(/ps_userpane\.log(?:\.(\d+))?/)
      if_file_like(/se_sampling\.log(?:\.(\d+))?/)
      if_file_like(/se_commander\.log(?:\.(\d+))?/)
    end
    files = %W{
     /path/to/se_commander.log
     /path/to/se_commander.log.1
     /path/to/se_commander.log.2
     /path/to/se_sampling.log
     /path/to/se_sampling.log.1
     /path/to/ps_userpane.log
     /path/to/ps_userpane.log.1
     /path/to/ps_userpane.log.2
    }
    %W{
    /path/to/ps_userpane.log.1
    /path/to/ps_userpane.log.2
    /path/to/ps_userpane.log
    /path/to/se_sampling.log.1
    /path/to/se_sampling.log
    /path/to/se_commander.log.1
    /path/to/se_commander.log.2
    /path/to/se_commander.log
    }.each { |file| @engine.should_receive(:process).with(file, anything, anything).ordered }

    @engine.analysis(files)
  end

end
