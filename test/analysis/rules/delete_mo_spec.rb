# @author Kadvin, Date: 12-1-5
require File.join(File.dirname(__FILE__), "../", "prepare")
require "analysis/engine"
require "analysis/initializer"
require "analysis/rules/delete_mo"

describe "Analysis the log of delete mo" do

  before(:each) do
    @files = %W{ps_userpane.log se_commander.log se_sampling.log}
    contents = {}
    File.stub(:open) do |file|
      contents[file].split("\n").map(&:strip)
    end
    contents["ps_userpane.log"] = <<-LOG
      14:37:03,593 INFO  [http-bio-/0.0.0.0-8020-exec-8] PsManagedObjectsController#delete ~ Deleting MO(moKey : "2f4e0b44-cbd4-4db5-ab4f-b38784f688fc")
      14:37:03,609 INFO  [http-bio-/0.0.0.0-8020-exec-8] PsManagedObjectServiceImpl#delete ~ Deleting MO(type : "NetworkDevice", ip : "192.168.0.45", domain : "BTIM", moKey : "2f4e0b44-cbd4-4db5-ab4f-b38784f688fc")
      14:37:03,703 INFO  [http-bio-/0.0.0.0-8020-exec-8] EngineServiceImpl#revokeFrom ~ Revoking MO(type : "NetworkDevice", moKey : "2f4e0b44-cbd4-4db5-ab4f-b38784f688fc") from Engine(20.0.9.111)
      14:37:03,937 INFO  [http-bio-/0.0.0.0-8020-exec-8] EngineServiceImpl#revokeFrom ~ Revoked MO(type : "NetworkDevice", moKey : "2f4e0b44-cbd4-4db5-ab4f-b38784f688fc") from Engine(20.0.9.111)
      14:37:03,938 INFO  [http-bio-/0.0.0.0-8020-exec-8] PsManagedObjectServiceImpl#delete ~ Deleted MO(type : "NetworkDevice", ip : "192.168.0.45", domain : "BTIM", moKey : "2f4e0b44-cbd4-4db5-ab4f-b38784f688fc")
      14:37:03,939 ERROR [http-bio-/0.0.0.0-8020-exec-8] PsManagedObjectsController#delete ~ Deleted MO(moKey : "2f4e0b44-cbd4-4db5-ab4f-b38784f688fc")
    LOG
    contents["se_commander.log"] = <<-LOG
      14:37:03,765 DEBUG [RMI TCP Connection(26)-20.0.9.111] CommanderManager#revoke ~ Revoking MO(moKey : "2f4e0b44-cbd4-4db5-ab4f-b38784f688fc")
      14:37:03,796 INFO  [RMI TCP Connection(26)-20.0.9.111] SeManagedObjectServiceImpl#revoke ~ Deleting MO(type : "NetworkDevice", ip : "192.168.0.90", domain : "BTIM", moKey : "2f4e0b44-cbd4-4db5-ab4f-b38784f688fc") from local se db
      14:37:03,874 INFO  [RMI TCP Connection(26)-20.0.9.111] SeManagedObjectServiceImpl#revoke ~ Deleted MO(type : "NetworkDevice", ip : "192.168.0.90", domain : "BTIM", moKey : "2f4e0b44-cbd4-4db5-ab4f-b38784f688fc") from local se db
      14:37:03,937 DEBUG [RMI TCP Connection(26)-20.0.9.111] CommanderManager#revoke ~ Revoked MO(moKey : "2f4e0b44-cbd4-4db5-ab4f-b38784f688fc")
    LOG
    contents["se_sampling.log"] = <<-LOG
    LOG
  end

  it "should find out all the user tasks and log records" do
    tasks = Analysis::Engine.analysis(@files) do |task|
      task.output_as_csv
    end
    tasks.should have(1).items
    tasks.first.should have(10).log_records
  end
end