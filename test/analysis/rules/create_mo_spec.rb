# encoding: utf-8
# @author Kadvin, Date: 12-1-5
require File.join(File.dirname(__FILE__), "../", "prepare")
require "analysis/engine"
require "analysis/initializer"
require "analysis/rules/create_mo"

describe "Analysis the log of create mo" do

  before(:each) do
    @files = %W{ps_userpane.log se_commander.log se_sampling.log}
    contents = {}
    File.stub(:open) do |file|
      contents[file].split("\n").map(&:strip)
    end
    contents["ps_userpane.log"] = <<-LOG
        12:01:05,001 INFO  [http-bio-/0.0.0.0-8020-exec-1] PsManagedObjectsController#create ~ Create MO(type : "NetworkDevice", ip : "120.0.0.1", moKey : null)
        12:01:05,099 INFO  [http-bio-/0.0.0.0-8020-exec-1] AllocateEngineForMo#afterCreate ~   Assigning MO(type: "NetworkDevice", ip : "120.0.0.1", moKey : "1271e6c4-0309-4185-9952-9a677aa92a0e") to Engine(192.168.0.1)
        12:01:08,701 INFO  [http-bio-/0.0.0.0-8020-exec-1] AllocateEngineForMo#afterCreate ~   Save MO(type: "NetworkDevice", ip : "120.0.0.1", moKey : "1271e6c4-0309-4185-9952-9a677aa92a0e") after retrieving
        12:01:05,101 INFO  [http-bio-/0.0.0.0-8020-exec-2] PsManagedObjectsController#create ~ Create MO(type : "NetworkDevice", ip : "120.0.0.2", moKey : null)
        12:01:05,199 INFO  [http-bio-/0.0.0.0-8020-exec-2] AllocateEngineForMo#afterCreate ~   Assigning MO(type: "NetworkDevice", ip : "120.0.0.2", moKey : "1271e6c4-0309-4185-9952-9a677aa92a22") to Engine(192.168.0.1)
        12:01:08,901 INFO  [http-bio-/0.0.0.0-8020-exec-2] AllocateEngineForMo#afterCreate ~   Save MO(type: "NetworkDevice", ip : "120.0.0.2", moKey : "1271e6c4-0309-4185-9952-9a677aa92a22") after retrieving
    LOG
    contents["se_commander.log"] = <<-LOG
        12:01:05,123 INFO  [RMI TCP Connection(2)-20.0.8.174] CommanderManager#assign ~        Assigned MO(type: "NetworkDevice", ip : "120.0.0.1", moKey : "1271e6c4-0309-4185-9952-9a677aa92a0e")
        12:01:05,130 INFO  [RMI TCP Connection(2)-20.0.8.174] CommanderManager#retrieve ~      Retrieving MO(type: "NetworkDevice", ip : "120.0.0.1", moKey : "1271e6c4-0309-4185-9952-9a677aa92a0e")
        12:01:05,140 INFO  [pool-3-thread-1] GetProperty#perform ~                             Reading Property(DeviceName) -> Indicator(SystemInfo) for MO(type: "NetworkDevice", ip : "120.0.0.1", moKey : "1271e6c4-0309-4185-9952-9a677aa92a0e")
        12:01:05,168 INFO  [RMI TCP Connection(25)-20.0.9.111] ResultServiceImpl#getResult ~   Reading Indicator(SystemInfo) for MO(type: "NetworkDevice", ip : "120.0.0.1", moKey : "1271e6c4-0309-4185-9952-9a677aa92a0e") cause by Property(DeviceName)
        12:01:05,170 INFO  [pool-3-thread-2] Task#waitForResult ~                              Create Task(moKey : "1271e6c4-0309-4185-9952-9a677aa92a0e", actionName : "SystemInfo", uuid : "5d7e46de-032b-483a-8b24-0848331515aa") for Property(DeviceName) order as 1: , timeout: 6000
        12:01:05,170 INFO  [pool-3-thread-2] Task#waitForResult ~                              Wait Task(moKey : "1271e6c4-0309-4185-9952-9a677aa92a0e", actionName : "SystemInfo", uuid : "5d7e46de-032b-483a-8b24-0848331515aa") for Property(DeviceName) order as 1: , timeout: 6000
        12:01:05,140 INFO  [pool-3-thread-1] GetProperty#perform ~                             Reading Property(vlans) -> Indicator(Vlan) for MO(type: "NetworkDevice", ip : "120.0.0.2", moKey : "1271e6c4-0309-4185-9952-9a677aa92a22")
        12:01:05,168 INFO  [RMI TCP Connection(26)-20.0.9.111] ResultServiceImpl#getResult ~   Reading Indicator(Vlan) for MO(type: "NetworkDevice", ip : "120.0.0.2", moKey : "1271e6c4-0309-4185-9952-9a677aa92a22") cause by Property(vlans)
        12:01:05,169 DEBUG [RMI TCP Connection(26)-20.0.9.111] ResultServiceImpl#getResult ~   Get Result for MO(type: "NetworkDevice", ip : "120.0.0.2", moKey : "1271e6c4-0309-4185-9952-9a677aa92a22") / Indicator(Vlan) from cache: Result{value='{
          "Descr":"设备描述",
          "Oid":"1.3.6.1.4.1.9.19.620",
          "Manufacturer":"思科",
          "Name":"Cisco",
          "Services":1,
          "DeviceType":"sr",
          "Contact":"ghost",
          "Location":"beta",
          "UpTime":86400
        }', errors=null}
        12:01:05,170 INFO  [pool-3-thread-2] Task#waitForResult ~                              Create Task(moKey : "1271e6c4-0309-4185-9952-9a677aa92a22", actionName : "Vlan", uuid : "5d7e46de-032b-483a-8b24-0848331515aa") for Property(vlans) order as 1: , timeout: 6000
        12:01:05,176 INFO  [pool-3-thread-3] ResultServiceImpl#findTask ~                      Reuse Task(moKey : "1271e6c4-0309-4185-9952-9a677aa92a0e", actionName : "SystemInfo", uuid : "5d7e46de-032b-483a-8b24-0848331515aa") for Property(DeviceName)
        12:01:06,810 INFO  [pool-3-thread-2] ResultServiceImpl#getResult ~                     Read Indicator(SystemInfo) for MO(type: "NetworkDevice", ip : "120.0.0.1", moKey : "1271e6c4-0309-4185-9952-9a677aa92a0e"): {...}
        12:01:08,430 INFO  [pool-3-thread-2] GetProperty#perform ~                             Read Property(DeviceName) <- Indicator(SystemInfo) for MO(type: "NetworkDevice", ip : "120.0.0.1", moKey : "1271e6c4-0309-4185-9952-9a677aa92a0e"): {...}
        12:01:08,522 INFO  [RMI TCP Connection(2)-20.0.8.174] CommanderManager#retrieve ~      Save MO(type: "NetworkDevice", ip : "120.0.0.1", moKey : "1271e6c4-0309-4185-9952-9a677aa92a0e") after retrieving
    LOG
    contents["se_sampling.log"] = <<-LOG
        12:01:05,180 INFO  [redis_queue_Task] TaskManager#push ~                 Assigned Task(moKey : "1271e6c4-0309-4185-9952-9a677aa92a0e", actionName : "SystemInfo", uuid : "5d7e46de-032b-483a-8b24-0848331515aa")
        12:01:05,185 INFO  [TaskEngineManage] TaskManager#xxxx ~                 Queuing Task(moKey : "1271e6c4-0309-4185-9952-9a677aa92a0e", actionName : "SystemInfo", uuid : "5d7e46de-032b-483a-8b24-0848331515aa")
        12:01:05,189 INFO  [pool-4-thread-1] TaskManager#yyyy ~                  Executing Task(moKey : "1271e6c4-0309-4185-9952-9a677aa92a0e", actionName : "SystemInfo", uuid : "5d7e46de-032b-483a-8b24-0848331515aa")
        12:01:05,200 INFO  [pool-4-thread-1] TaskExecutor#aaa ~                  Choose Probe(CPU01.NetworkDevice) for Task(moKey : "1271e6c4-0309-4185-9952-9a677aa92a0e", actionName : "SystemInfo", uuid : "5d7e46de-032b-483a-8b24-0848331515aa")
        12:01:05,900 INFO  [pool-4-thread-1] TaskExecutor#aaa ~                  Failed Task(moKey : "1271e6c4-0309-4185-9952-9a677aa92a0e", actionName : "SystemInfo", uuid : "5d7e46de-032b-483a-8b24-0848331515aa"): /reason/
        12:01:06,100 INFO  [pool-4-thread-1] TaskExecutor#aaa ~                  Succeed Task(moKey : "1271e6c4-0309-4185-9952-9a677aa92a22", actionName : "Vlan", uuid : "5d7e46de-032b-483a-8b24-0848331515aa") : /value/
        12:01:08,210 INFO  [pool-4-thread-1] TaskExecutor#zzzzz ~                Not found any Probe for Task(moKey : "1271e6c4-0309-4185-9952-9a677aa92a22", actionName : "Vlan", uuid : "5d7e46de-032b-483a-8b24-dddddddddddd")
    LOG
  end

  it "should find out all the user tasks and log records" do
    tasks = Analysis::Engine.analysis(@files) do |task|
      $stderr.puts
      task.output_as_csv $stderr
    end
    tasks.should have(2).items
    tasks.first.should have(18).log_records
    tasks.last.should have(9).log_records
  end
end