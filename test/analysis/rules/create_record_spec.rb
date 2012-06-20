# encoding: utf-8
# @author Kadvin, Date: 12-1-5
require File.join(File.dirname(__FILE__), "../", "prepare")
require "analysis/engine"
require "analysis/initializer"
require "analysis/rules/create_record"
describe "Analysis the log of create record" do

  before(:each) do
    @files = %W{ps_userpane.log se_commander.log se_scheduler.log}
    contents = {}
    File.stub(:open) do |file|
      contents[file].split("\n").map(&:strip)
    end
    contents["ps_userpane.log"] = <<-LOG
      14:24:11,629 DEBUG [http-bio-/0.0.0.0-8020-exec-9] RecordRulesController#getJsonFromBody ~ get json from body as {"name"=>"测试记录规则-1-63", "stopOn"=>"2012-12-31", "schedulePlan"=>{"includes"=>[{"days_of_week"=>"1-5", "times"=>"8:30-12:00,14:00-17:30", "months"=>"1,2,3"}, {"days_of_month"=>"1-30", "times"=>"9:00-12:30,14:30-18:00", "months"=>"4,5,6,7,8,9,10"}], "excludes"=>[{"days_of_month"=>"1-7", "months"=>"10"}, {"days_of_week"=>"1", "months"=>"1"}, {"days_of_month"=>"1", "months"=>"5"}]}, "notification"=>{"data"=>[{"destinationName"=>"BTIM.JMColor", "type"=>"poll", "description"=>"如保留个数等其他信息将在程序的配置中, 而不是存于规则中"}, {"destinationName"=>"BTIM.Alert", "type"=>"poll"}, {"destinationName"=>"http://127.0.0.1:1099/pushEvent", "type"=>"push"}, {"destinationName"=>"Nanri", "type"=>"jms", "description"=>"如jms地址端口等其他信息将在程序的配置中, 而不是存于规则中,暂时不支持"}, {"destinationName"=>"xxxx", "type"=>"jms", "description"=>"如jms地址端口等其他信息将在程序的配置中, 而不是存于规则中，暂时不支持"}, {"destinationName"=>"yyy", "type"=>"db", "description"=>"如jdbc的url等其他信息将在程序的配置中, 而不是存于规则中，暂时不支持"}], "packagingInterval"=>60}, "creator"=>"PDM-PTS-CREATE-RECORD", "startOn"=>"2012-01-10", "indicator"=>{"expectedInterval"=>5000, "name"=>"RemotePing", "arguments"=>[{"a1"=>"executing-host"}, {"a2"=>23}, {"a2"=>{"SentPacketsSize"=>300, "SentPacketsNum"=>20, "dstIP"=>"10.11.12.13", "Timeout"=>2000, "Delay"=>2000, "@type"=>"RemotingPingParameter"}}]}, "version"=>1, "recorder"=>{"@type"=>"select", "select"=>{"projection"=>{"function"=>"Count", "field"=>"ProcessMEM"}, "when"=>{"value"=>"betasoft.pdm.*", "operator"=>"like", "field"=>"ProcessName"}}}, "description"=>"这是我用来做测试的", "source"=>"PDM-UP", "status"=>true, "managedObject"=>"moKey = 'd3c1e837-f1f8-4306-958c-1aa1b32625dd'"}
      14:24:11,645 INFO  [http-bio-/0.0.0.0-8020-exec-9] RecordRulesController#create ~ Creating RecordRule(name : `测试记录规则-1-63`).
      14:24:11,645 INFO  [http-bio-/0.0.0.0-8020-exec-9] SubscribeRule#createFromJson ~ Creating PsRecordRule(id:`null`, key:`null`, name:`测试记录规则-1-63`) for MO(moKey : "d3c1e837-f1f8-4306-958c-1aa1b32625dd")
      14:24:11,645 INFO  [http-bio-/0.0.0.0-8020-exec-9] System#raiseEvent ~ Dispatching {"arguments":"{ \"@Type\":\"fixedRate\", \"startOn\":\"2012-01-10\", \"endOn\":\"2012-12-31\", \"interval\":5000, \"activeTimes\":{\"includes\":[{\"days_of_week\":\"1-5\",\"times\":\"8:30-12:00,14:00-17:30\",\"months\":\"1,2,3\"},{\"days_of_month\":\"1-30\",\"times\":\"9:00-12:30,14:30-18:00\",\"months\":\"4,5,6,7,8,9,10\"}],\"excludes\":[{\"days_of_month\":\"1-7\",\"months\":\"10\"},{\"days_of_week\":\"1\",\"months\":\"1\"},{\"days_of_month\":\"1\",\"months\":\"5\"}]}}","channel":"ruleEvent","created_at":"Jan 16, 2012 2:24:11 PM","creator":"PDM-PTS-CREATE-RECORD","description":"这是我用来做测试的","eventType":"create","id":227,"indicator":"RemotePing","indicator_arguments":"{}","managed_object_id":64,"name":"测试记录规则-1-63","parent_id":99,"parent_type":"recordRule","rule_key":"caba36f6-b559-4942-b6c1-754c4b2e8185","source":"PDM-UP","source_version":0,"status":1,"style":"fixedRate","table":"schedulable_rules","updated_at":"Jan 16, 2012 2:24:11 PM"} to Engine(20.0.8.110)
      14:24:11,661 INFO  [http-bio-/0.0.0.0-8020-exec-9] System#raiseEvent ~ Dispatched {"arguments":"{ \"@Type\":\"fixedRate\", \"startOn\":\"2012-01-10\", \"endOn\":\"2012-12-31\", \"interval\":5000, \"activeTimes\":{\"includes\":[{\"days_of_week\":\"1-5\",\"times\":\"8:30-12:00,14:00-17:30\",\"months\":\"1,2,3\"},{\"days_of_month\":\"1-30\",\"times\":\"9:00-12:30,14:30-18:00\",\"months\":\"4,5,6,7,8,9,10\"}],\"excludes\":[{\"days_of_month\":\"1-7\",\"months\":\"10\"},{\"days_of_week\":\"1\",\"months\":\"1\"},{\"days_of_month\":\"1\",\"months\":\"5\"}]}}","channel":"ruleEvent","created_at":"Jan 16, 2012 2:24:11 PM","creator":"PDM-PTS-CREATE-RECORD","description":"这是我用来做测试的","eventType":"create","id":227,"indicator":"RemotePing","indicator_arguments":"{}","managed_object_id":64,"name":"测试记录规则-1-63","parent_id":99,"parent_type":"recordRule","rule_key":"caba36f6-b559-4942-b6c1-754c4b2e8185","source":"PDM-UP","source_version":0,"status":1,"style":"fixedRate","table":"schedulable_rules","updated_at":"Jan 16, 2012 2:24:11 PM"} to Engine(20.0.8.110)
      14:24:11,661 INFO  [http-bio-/0.0.0.0-8020-exec-9] SubscribeRule#createFromJson ~ Created PsRecordRule(id:`99`, key:`caba36f6-b559-4942-b6c1-754c4b2e8185`, name:`测试记录规则-1-63`) for MO(moKey : "d3c1e837-f1f8-4306-958c-1aa1b32625dd")
      14:24:11,661 INFO  [http-bio-/0.0.0.0-8020-exec-9] RecordRulesController#create ~ Created RecordRule(name : `测试记录规则-1-63`).
      14:24:11,707 DEBUG [http-bio-/0.0.0.0-8020-exec-9] RecordRulesController#getJsonFromBody ~ get json from body as {"name"=>"测试记录规则-1-64", "stopOn"=>"2012-12-31", "schedulePlan"=>{"includes"=>[{"days_of_week"=>"1-5", "times"=>"8:30-12:00,14:00-17:30", "months"=>"1,2,3"}, {"days_of_month"=>"1-30", "times"=>"9:00-12:30,14:30-18:00", "months"=>"4,5,6,7,8,9,10"}], "excludes"=>[{"days_of_month"=>"1-7", "months"=>"10"}, {"days_of_week"=>"1", "months"=>"1"}, {"days_of_month"=>"1", "months"=>"5"}]}, "notification"=>{"data"=>[{"destinationName"=>"BTIM.JMColor", "type"=>"poll", "description"=>"如保留个数等其他信息将在程序的配置中, 而不是存于规则中"}, {"destinationName"=>"BTIM.Alert", "type"=>"poll"}, {"destinationName"=>"http://127.0.0.1:1099/pushEvent", "type"=>"push"}, {"destinationName"=>"Nanri", "type"=>"jms", "description"=>"如jms地址端口等其他信息将在程序的配置中, 而不是存于规则中,暂时不支持"}, {"destinationName"=>"xxxx", "type"=>"jms", "description"=>"如jms地址端口等其他信息将在程序的配置中, 而不是存于规则中，暂时不支持"}, {"destinationName"=>"yyy", "type"=>"db", "description"=>"如jdbc的url等其他信息将在程序的配置中, 而不是存于规则中，暂时不支持"}], "packagingInterval"=>60}, "creator"=>"PDM-PTS-CREATE-RECORD", "startOn"=>"2012-01-10", "indicator"=>{"expectedInterval"=>5000, "name"=>"RemotePing", "arguments"=>[{"a1"=>"executing-host"}, {"a2"=>23}, {"a2"=>{"SentPacketsSize"=>300, "SentPacketsNum"=>20, "dstIP"=>"10.11.12.13", "Timeout"=>2000, "Delay"=>2000, "@type"=>"RemotingPingParameter"}}]}, "version"=>1, "recorder"=>{"@type"=>"select", "select"=>{"projection"=>{"function"=>"Count", "field"=>"ProcessMEM"}, "when"=>{"value"=>"betasoft.pdm.*", "operator"=>"like", "field"=>"ProcessName"}}}, "description"=>"这是我用来做测试的", "source"=>"PDM-UP", "status"=>true, "managedObject"=>"moKey = 'b2b64102-5bec-4d4d-ac48-785ab0e3622b'"}
      14:24:11,707 INFO  [http-bio-/0.0.0.0-8020-exec-9] RecordRulesController#create ~ Creating RecordRule(name : `测试记录规则-1-64`).
      14:24:11,707 INFO  [http-bio-/0.0.0.0-8020-exec-9] SubscribeRule#createFromJson ~ Creating PsRecordRule(id:`null`, key:`null`, name:`测试记录规则-1-64`) for MO(moKey : "b2b64102-5bec-4d4d-ac48-785ab0e3622b")
      14:24:11,739 INFO  [http-bio-/0.0.0.0-8020-exec-9] System#raiseEvent ~ Dispatching {"arguments":"{ \"@Type\":\"fixedRate\", \"startOn\":\"2012-01-10\", \"endOn\":\"2012-12-31\", \"interval\":5000, \"activeTimes\":{\"includes\":[{\"days_of_week\":\"1-5\",\"times\":\"8:30-12:00,14:00-17:30\",\"months\":\"1,2,3\"},{\"days_of_month\":\"1-30\",\"times\":\"9:00-12:30,14:30-18:00\",\"months\":\"4,5,6,7,8,9,10\"}],\"excludes\":[{\"days_of_month\":\"1-7\",\"months\":\"10\"},{\"days_of_week\":\"1\",\"months\":\"1\"},{\"days_of_month\":\"1\",\"months\":\"5\"}]}}","channel":"ruleEvent","created_at":"Jan 16, 2012 2:24:11 PM","creator":"PDM-PTS-CREATE-RECORD","description":"这是我用来做测试的","eventType":"create","id":228,"indicator":"RemotePing","indicator_arguments":"{}","managed_object_id":65,"name":"测试记录规则-1-64","parent_id":100,"parent_type":"recordRule","rule_key":"e14c90ec-c49a-4499-b757-adcce0fe21a5","source":"PDM-UP","source_version":0,"status":1,"style":"fixedRate","table":"schedulable_rules","updated_at":"Jan 16, 2012 2:24:11 PM"} to Engine(20.0.8.110)
      14:24:11,754 INFO  [http-bio-/0.0.0.0-8020-exec-9] System#raiseEvent ~ Dispatched {"arguments":"{ \"@Type\":\"fixedRate\", \"startOn\":\"2012-01-10\", \"endOn\":\"2012-12-31\", \"interval\":5000, \"activeTimes\":{\"includes\":[{\"days_of_week\":\"1-5\",\"times\":\"8:30-12:00,14:00-17:30\",\"months\":\"1,2,3\"},{\"days_of_month\":\"1-30\",\"times\":\"9:00-12:30,14:30-18:00\",\"months\":\"4,5,6,7,8,9,10\"}],\"excludes\":[{\"days_of_month\":\"1-7\",\"months\":\"10\"},{\"days_of_week\":\"1\",\"months\":\"1\"},{\"days_of_month\":\"1\",\"months\":\"5\"}]}}","channel":"ruleEvent","created_at":"Jan 16, 2012 2:24:11 PM","creator":"PDM-PTS-CREATE-RECORD","description":"这是我用来做测试的","eventType":"create","id":228,"indicator":"RemotePing","indicator_arguments":"{}","managed_object_id":65,"name":"测试记录规则-1-64","parent_id":100,"parent_type":"recordRule","rule_key":"e14c90ec-c49a-4499-b757-adcce0fe21a5","source":"PDM-UP","source_version":0,"status":1,"style":"fixedRate","table":"schedulable_rules","updated_at":"Jan 16, 2012 2:24:11 PM"} to Engine(20.0.8.110)
      14:24:11,754 INFO  [http-bio-/0.0.0.0-8020-exec-9] SubscribeRule#createFromJson ~ Created PsRecordRule(id:`100`, key:`e14c90ec-c49a-4499-b757-adcce0fe21a5`, name:`测试记录规则-1-64`) for MO(moKey : "b2b64102-5bec-4d4d-ac48-785ab0e3622b")
      14:24:11,754 INFO  [http-bio-/0.0.0.0-8020-exec-9] RecordRulesController#create ~ Created RecordRule(name : `测试记录规则-1-64`).
    LOG
    contents["se_commander.log"] = <<-LOG
      14:24:11,661 INFO  [RMI TCP Connection(76)-20.0.8.110] MapMessageListener#onApplicationEvent ~ Receive '{"arguments":"{ \"@Type\":\"fixedRate\", \"startOn\":\"2012-01-10\", \"endOn\":\"2012-12-31\", \"interval\":5000, \"activeTimes\":{\"includes\":[{\"days_of_week\":\"1-5\",\"times\":\"8:30-12:00,14:00-17:30\",\"months\":\"1,2,3\"},{\"days_of_month\":\"1-30\",\"times\":\"9:00-12:30,14:30-18:00\",\"months\":\"4,5,6,7,8,9,10\"}],\"excludes\":[{\"days_of_month\":\"1-7\",\"months\":\"10\"},{\"days_of_week\":\"1\",\"months\":\"1\"},{\"days_of_month\":\"1\",\"months\":\"5\"}]}}","channel":"ruleEvent","created_at":"Jan 16, 2012 2:24:11 PM","creator":"PDM-PTS-CREATE-RECORD","description":"这是我用来做测试的","eventType":"create","id":227,"indicator":"RemotePing","indicator_arguments":"{}","managed_object_id":64,"name":"测试记录规则-1-63","parent_id":99,"parent_type":"recordRule","rule_key":"caba36f6-b559-4942-b6c1-754c4b2e8185","source":"PDM-UP","source_version":0,"status":1,"style":"fixedRate","table":"schedulable_rules","updated_at":"Jan 16, 2012 2:24:11 PM"}'
      14:24:11,661 INFO  [RMI TCP Connection(76)-20.0.8.110] EventBridge#onEvent ~ Publish '{"arguments":"{ \"@Type\":\"fixedRate\", \"startOn\":\"2012-01-10\", \"endOn\":\"2012-12-31\", \"interval\":5000, \"activeTimes\":{\"includes\":[{\"days_of_week\":\"1-5\",\"times\":\"8:30-12:00,14:00-17:30\",\"months\":\"1,2,3\"},{\"days_of_month\":\"1-30\",\"times\":\"9:00-12:30,14:30-18:00\",\"months\":\"4,5,6,7,8,9,10\"}],\"excludes\":[{\"days_of_month\":\"1-7\",\"months\":\"10\"},{\"days_of_week\":\"1\",\"months\":\"1\"},{\"days_of_month\":\"1\",\"months\":\"5\"}]}}","channel":"ruleEvent","created_at":"Jan 16, 2012 2:24:11 PM","creator":"PDM-PTS-CREATE-RECORD","description":"这是我用来做测试的","eventType":"create","id":227,"indicator":"RemotePing","indicator_arguments":"{}","managed_object_id":64,"name":"测试记录规则-1-63","parent_id":99,"parent_type":"recordRule","rule_key":"caba36f6-b559-4942-b6c1-754c4b2e8185","source":"PDM-UP","source_version":0,"status":1,"style":"fixedRate","table":"schedulable_rules","updated_at":"Jan 16, 2012 2:24:11 PM"}' to 'ruleEvent'
      14:24:11,661 INFO  [RMI TCP Connection(76)-20.0.8.110] MapMessageListener#onApplicationEvent ~ Process '{"arguments":"{ \"@Type\":\"fixedRate\", \"startOn\":\"2012-01-10\", \"endOn\":\"2012-12-31\", \"interval\":5000, \"activeTimes\":{\"includes\":[{\"days_of_week\":\"1-5\",\"times\":\"8:30-12:00,14:00-17:30\",\"months\":\"1,2,3\"},{\"days_of_month\":\"1-30\",\"times\":\"9:00-12:30,14:30-18:00\",\"months\":\"4,5,6,7,8,9,10\"}],\"excludes\":[{\"days_of_month\":\"1-7\",\"months\":\"10\"},{\"days_of_week\":\"1\",\"months\":\"1\"},{\"days_of_month\":\"1\",\"months\":\"5\"}]}}","channel":"ruleEvent","created_at":"Jan 16, 2012 2:24:11 PM","creator":"PDM-PTS-CREATE-RECORD","description":"这是我用来做测试的","eventType":"create","id":227,"indicator":"RemotePing","indicator_arguments":"{}","managed_object_id":64,"name":"测试记录规则-1-63","parent_id":99,"parent_type":"recordRule","rule_key":"caba36f6-b559-4942-b6c1-754c4b2e8185","source":"PDM-UP","source_version":0,"status":1,"style":"fixedRate","table":"schedulable_rules","updated_at":"Jan 16, 2012 2:24:11 PM"}' success
      14:24:11,739 INFO  [RMI TCP Connection(78)-20.0.8.110] MapMessageListener#onApplicationEvent ~ Receive '{"arguments":"{ \"@Type\":\"fixedRate\", \"startOn\":\"2012-01-10\", \"endOn\":\"2012-12-31\", \"interval\":5000, \"activeTimes\":{\"includes\":[{\"days_of_week\":\"1-5\",\"times\":\"8:30-12:00,14:00-17:30\",\"months\":\"1,2,3\"},{\"days_of_month\":\"1-30\",\"times\":\"9:00-12:30,14:30-18:00\",\"months\":\"4,5,6,7,8,9,10\"}],\"excludes\":[{\"days_of_month\":\"1-7\",\"months\":\"10\"},{\"days_of_week\":\"1\",\"months\":\"1\"},{\"days_of_month\":\"1\",\"months\":\"5\"}]}}","channel":"ruleEvent","created_at":"Jan 16, 2012 2:24:11 PM","creator":"PDM-PTS-CREATE-RECORD","description":"这是我用来做测试的","eventType":"create","id":228,"indicator":"RemotePing","indicator_arguments":"{}","managed_object_id":65,"name":"测试记录规则-1-64","parent_id":100,"parent_type":"recordRule","rule_key":"e14c90ec-c49a-4499-b757-adcce0fe21a5","source":"PDM-UP","source_version":0,"status":1,"style":"fixedRate","table":"schedulable_rules","updated_at":"Jan 16, 2012 2:24:11 PM"}'
      14:24:11,754 INFO  [RMI TCP Connection(78)-20.0.8.110] EventBridge#onEvent ~ Publish '{"arguments":"{ \"@Type\":\"fixedRate\", \"startOn\":\"2012-01-10\", \"endOn\":\"2012-12-31\", \"interval\":5000, \"activeTimes\":{\"includes\":[{\"days_of_week\":\"1-5\",\"times\":\"8:30-12:00,14:00-17:30\",\"months\":\"1,2,3\"},{\"days_of_month\":\"1-30\",\"times\":\"9:00-12:30,14:30-18:00\",\"months\":\"4,5,6,7,8,9,10\"}],\"excludes\":[{\"days_of_month\":\"1-7\",\"months\":\"10\"},{\"days_of_week\":\"1\",\"months\":\"1\"},{\"days_of_month\":\"1\",\"months\":\"5\"}]}}","channel":"ruleEvent","created_at":"Jan 16, 2012 2:24:11 PM","creator":"PDM-PTS-CREATE-RECORD","description":"这是我用来做测试的","eventType":"create","id":228,"indicator":"RemotePing","indicator_arguments":"{}","managed_object_id":65,"name":"测试记录规则-1-64","parent_id":100,"parent_type":"recordRule","rule_key":"e14c90ec-c49a-4499-b757-adcce0fe21a5","source":"PDM-UP","source_version":0,"status":1,"style":"fixedRate","table":"schedulable_rules","updated_at":"Jan 16, 2012 2:24:11 PM"}' to 'ruleEvent'
      14:24:11,754 INFO  [RMI TCP Connection(78)-20.0.8.110] MapMessageListener#onApplicationEvent ~ Process '{"arguments":"{ \"@Type\":\"fixedRate\", \"startOn\":\"2012-01-10\", \"endOn\":\"2012-12-31\", \"interval\":5000, \"activeTimes\":{\"includes\":[{\"days_of_week\":\"1-5\",\"times\":\"8:30-12:00,14:00-17:30\",\"months\":\"1,2,3\"},{\"days_of_month\":\"1-30\",\"times\":\"9:00-12:30,14:30-18:00\",\"months\":\"4,5,6,7,8,9,10\"}],\"excludes\":[{\"days_of_month\":\"1-7\",\"months\":\"10\"},{\"days_of_week\":\"1\",\"months\":\"1\"},{\"days_of_month\":\"1\",\"months\":\"5\"}]}}","channel":"ruleEvent","created_at":"Jan 16, 2012 2:24:11 PM","creator":"PDM-PTS-CREATE-RECORD","description":"这是我用来做测试的","eventType":"create","id":228,"indicator":"RemotePing","indicator_arguments":"{}","managed_object_id":65,"name":"测试记录规则-1-64","parent_id":100,"parent_type":"recordRule","rule_key":"e14c90ec-c49a-4499-b757-adcce0fe21a5","source":"PDM-UP","source_version":0,"status":1,"style":"fixedRate","table":"schedulable_rules","updated_at":"Jan 16, 2012 2:24:11 PM"}' success
     LOG
    contents["se_scheduler.log"] = <<-LOG
      14:24:13,111 INFO  [redis_queue_ruleEvent] Topic#onEvent ~ Receive 'cn.com.betasoft.pubsub.JsonMessageEvent[{"arguments":"{ \"@Type\":\"fixedRate\", \"startOn\":\"2012-01-10\", \"endOn\":\"2012-12-31\", \"interval\":5000, \"activeTimes\":{\"includes\":[{\"days_of_week\":\"1-5\",\"times\":\"8:30-12:00,14:00-17:30\",\"months\":\"1,2,3\"},{\"days_of_month\":\"1-30\",\"times\":\"9:00-12:30,14:30-18:00\",\"months\":\"4,5,6,7,8,9,10\"}],\"excludes\":[{\"days_of_month\":\"1-7\",\"months\":\"10\"},{\"days_of_week\":\"1\",\"months\":\"1\"},{\"days_of_month\":\"1\",\"months\":\"5\"}]}}","channel":"ruleEvent","created_at":"Jan 16, 2012 2:24:11 PM","creator":"PDM-PTS-CREATE-RECORD","description":"这是我用来做测试的","eventType":"create","id":227,"indicator":"RemotePing","indicator_arguments":"{}","managed_object_id":64,"name":"测试记录规则-1-63","parent_id":99,"parent_type":"recordRule","rule_key":"caba36f6-b559-4942-b6c1-754c4b2e8185","source":"PDM-UP","source_version":0,"status":1,"style":"fixedRate","table":"schedulable_rules","updated_at":"Jan 16, 2012 2:24:11 PM"}]' from 'ruleEvent'
      14:24:13,111 INFO  [redis_queue_ruleEvent] RecordManager#startRule ~ Starting 'SeRecordRule(id:`99`, key:`caba36f6-b559-4942-b6c1-754c4b2e8185`, name:`测试记录规则-1-63`)'.
      14:24:13,111 WARN  [redis_queue_ruleEvent] ExecutorBase#initialize ~ Start SeRecordRule(id:`227`, key:`caba36f6-b559-4942-b6c1-754c4b2e8185`, name:`测试记录规则-1-63`) failed, because of: Can't find [MO(moKey : "d3c1e837-f1f8-4306-958c-1aa1b32625dd"), '64'] ManagedObject instance from database.
      14:24:13,111 WARN  [redis_queue_ruleEvent] ExecutorBase#start ~ Start SeRecordRule(id:`227`, key:`caba36f6-b559-4942-b6c1-754c4b2e8185`, name:`测试记录规则-1-63`) failed, because of: Can't find [MO(moKey : "d3c1e837-f1f8-4306-958c-1aa1b32625dd"), '64'] ManagedObject instance from database.
      14:24:13,111 INFO  [redis_queue_ruleEvent] RecordManager#startRule ~ Started 'SeRecordRule(id:`99`, key:`caba36f6-b559-4942-b6c1-754c4b2e8185`, name:`测试记录规则-1-63`)' done.
      14:24:13,111 INFO  [redis_queue_ruleEvent] Topic#onEvent ~ Receive 'cn.com.betasoft.pubsub.JsonMessageEvent[{"arguments":"{ \"@Type\":\"fixedRate\", \"startOn\":\"2012-01-10\", \"endOn\":\"2012-12-31\", \"interval\":5000, \"activeTimes\":{\"includes\":[{\"days_of_week\":\"1-5\",\"times\":\"8:30-12:00,14:00-17:30\",\"months\":\"1,2,3\"},{\"days_of_month\":\"1-30\",\"times\":\"9:00-12:30,14:30-18:00\",\"months\":\"4,5,6,7,8,9,10\"}],\"excludes\":[{\"days_of_month\":\"1-7\",\"months\":\"10\"},{\"days_of_week\":\"1\",\"months\":\"1\"},{\"days_of_month\":\"1\",\"months\":\"5\"}]}}","channel":"ruleEvent","created_at":"Jan 16, 2012 2:24:11 PM","creator":"PDM-PTS-CREATE-RECORD","description":"这是我用来做测试的","eventType":"create","id":228,"indicator":"RemotePing","indicator_arguments":"{}","managed_object_id":65,"name":"测试记录规则-1-64","parent_id":100,"parent_type":"recordRule","rule_key":"e14c90ec-c49a-4499-b757-adcce0fe21a5","source":"PDM-UP","source_version":0,"status":1,"style":"fixedRate","table":"schedulable_rules","updated_at":"Jan 16, 2012 2:24:11 PM"}]' from 'ruleEvent'
      14:24:13,127 INFO  [redis_queue_ruleEvent] RecordManager#startRule ~ Starting 'SeRecordRule(id:`100`, key:`e14c90ec-c49a-4499-b757-adcce0fe21a5`, name:`测试记录规则-1-64`)'.
      14:24:13,127 WARN  [redis_queue_ruleEvent] ExecutorBase#initialize ~ Start SeRecordRule(id:`228`, key:`e14c90ec-c49a-4499-b757-adcce0fe21a5`, name:`测试记录规则-1-64`) failed, because of: Can't find [MO(moKey : "b2b64102-5bec-4d4d-ac48-785ab0e3622b"), '65'] ManagedObject instance from database.
      14:24:13,127 WARN  [redis_queue_ruleEvent] ExecutorBase#start ~ Start SeRecordRule(id:`228`, key:`e14c90ec-c49a-4499-b757-adcce0fe21a5`, name:`测试记录规则-1-64`) failed, because of: Can't find [MO(moKey : "b2b64102-5bec-4d4d-ac48-785ab0e3622b"), '65'] ManagedObject instance from database.
      14:24:13,127 INFO  [redis_queue_ruleEvent] RecordManager#startRule ~ Started 'SeRecordRule(id:`100`, key:`e14c90ec-c49a-4499-b757-adcce0fe21a5`, name:`测试记录规则-1-64`)' done.
    LOG
  end

  it "should find out all the user tasks and log records" do
    tasks = Analysis::Engine.analysis(@files) do |task|
      $stderr.puts
      task.output_as_csv $stderr
    end
    tasks.should have(2).items
    tasks.first.should have(14).log_records
  end
end