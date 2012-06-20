# encoding: utf-8
# @author Kadvin, Date: 12-1-5
require File.join(File.dirname(__FILE__), "../", "prepare")
require "analysis/engine"
require "analysis/initializer"
require "analysis/rules/sample_mo"

describe "Analysis the log of sample mo" do

  before(:each) do
    @files = %W{ps_userpane.log se_commander.log se_sampling.log}
    contents = {}
    File.stub(:open) do |file|
      contents[file].split("\n").map(&:strip)
    end
    contents["ps_userpane.log"] = <<-LOG
      10:10:50,000 INFO  [http-bio-/0.0.0.0-8020-exec-4] PsManagedObjectsController#getIndicatorValue ~ Reading MO(moKey : "ed668522-2f65-45ee-892a-95accaa31034") / Indicator(TCP_CONNECTION), Parameter(fresh : -1, force : false, timeout : 30)
      10:10:50,015 INFO  [pool-2-thread-1] PsManagedObjectServiceImpl#getIndicatorValue ~ Reading MO(type : "NetworkDevice", ip : "192.168.0.31", domain : "BTIM", moKey : "ed668522-2f65-45ee-892a-95accaa31034") / Indicator(TCP_CONNECTION) from Engine(20.0.8.167)
      16:48:34,950 INFO  [http-bio-/0.0.0.0-8020-exec-9] PsManagedObjectsController#getIndicatorValue ~ Reading MO(moKey : "711f6d48-2f6b-45af-9a0a-469d295efb46") / Indicator(SystemInfo), Parameter(fresh : -1, force : false, timeout : 30)
      16:48:35,278 INFO  [pool-2-thread-1] PsManagedObjectServiceImpl#getIndicatorValue ~ Reading MO(type : "NetworkDevice", ip : "192.168.0.84", domain : "BTIM", moKey : "711f6d48-2f6b-45af-9a0a-469d295efb46") / Indicator(SYSTEMINFO) from Engine(20.0.9.111)
      17:48:39,770 DEBUG [pool-2-thread-1] PsManagedObjectServiceImpl#getIndicatorValue ~ Read MO(type : "NetworkDevice", ip : "192.168.0.84", domain : "BTIM", moKey : "711f6d48-2f6b-45af-9a0a-469d295efb46") / Indicator(SYSTEMINFO) from Engine(20.0.9.111)
    LOG
    contents["se_commander.log"] = <<-LOG
      16:48:38,647 INFO  [RMI TCP Connection(26)-20.0.9.111] CommanderManager#getIndicatorValue ~ Reading MO(moKey : "711f6d48-2f6b-45af-9a0a-469d295efb46") / Indicator(SystemInfo)
      16:48:38,678 INFO  [RMI TCP Connection(26)-20.0.9.111] SeManagedObjectServiceImpl#getIndicatorValue ~ Reading(directly) Indicator(SYSTEMINFO) for MO(type : "NetworkDevice", ip : "192.168.0.84", domain : "BTIM", moKey : "711f6d48-2f6b-45af-9a0a-469d295efb46")
      16:48:38,725 INFO  [RMI TCP Connection(26)-20.0.9.111] ResultServiceImpl#getResult ~ Reading Indicator(SYSTEMINFO) for MO(type : "NetworkDevice", ip : "192.168.0.84", domain : "BTIM", moKey : "711f6d48-2f6b-45af-9a0a-469d295efb46") cause by Indicator(SYSTEMINFO)
      16:48:38,769 DEBUG [RMI TCP Connection(26)-20.0.9.111] ResultServiceImpl#getResult ~   Get Result for MO(type: "NetworkDevice", ip : "192.168.0.84", moKey : "711f6d48-2f6b-45af-9a0a-469d295efb46") / Indicator(SystemInfo) from cache: Result{value='{
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
      16:48:38,730 INFO  [pool-3-thread-2] Task#waitForResult ~ Create Task(moKey : "711f6d48-2f6b-45af-9a0a-469d295efb46", actionName : "SystemInfo", uuid : "5d7e46de-032b-483a-8b24-0848331515aa") for Property(DeviceName) order as 1: , timeout: 6000
      16:48:39,730 INFO  [pool-3-thread-2] Task#waitForResult ~ Wait Task(moKey : "711f6d48-2f6b-45af-9a0a-469d295efb46", actionName : "SystemInfo", uuid : "5d7e46de-032b-483a-8b24-0848331515aa") for Property(DeviceName) order as 1: , timeout: 6000
      16:48:38,741 DEBUG [RMI TCP Connection(26)-20.0.9.111] CommanderManager#getIndicatorValue ~ Read MO(moKey : "711f6d48-2f6b-45af-9a0a-469d295efb46") / Indicator(SYSTEMINFO)
    LOG
    contents["se_sampling.log"] = <<-LOG
      17:01:05,180 INFO  [redis_queue_Task] TaskManager#push ~                 Assigned Task(moKey : "711f6d48-2f6b-45af-9a0a-469d295efb46", actionName : "SystemInfo", uuid : "5d7e46de-032b-483a-8b24-0848331515aa")
      17:01:05,185 INFO  [TaskEngineManage] TaskManager#xxxx ~                 Queuing Task(moKey : "711f6d48-2f6b-45af-9a0a-469d295efb46", actionName : "SystemInfo", uuid : "5d7e46de-032b-483a-8b24-0848331515aa")
      17:01:05,189 INFO  [pool-4-thread-1] TaskManager#yyyy ~                  Executing Task(moKey : "711f6d48-2f6b-45af-9a0a-469d295efb46", actionName : "SystemInfo", uuid : "5d7e46de-032b-483a-8b24-0848331515aa")
      17:01:05,200 INFO  [pool-4-thread-1] TaskExecutor#aaa ~                  Choose Probe(CPU01.NetworkDevice) for Task(moKey : "711f6d48-2f6b-45af-9a0a-469d295efb46", actionName : "SystemInfo", uuid : "5d7e46de-032b-483a-8b24-0848331515aa")
      17:01:06,100 INFO  [pool-4-thread-1] TaskExecutor#aaa ~                  Succeed Task(moKey : "711f6d48-2f6b-45af-9a0a-469d295efb46", actionName : "SystemInfo", uuid : "5d7e46de-032b-483a-8b24-0848331515aa") : /value/
    LOG
  end

  it "should find out all the user tasks and log records" do
    tasks = Analysis::Engine.analysis(@files) do |task|
      task.output_as_csv
    end
    tasks.should have(2).items
    tasks.first.should have(2).log_records
    tasks.last.should have(14).log_records
  end
end