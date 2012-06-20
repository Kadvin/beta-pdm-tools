# encoding: utf-8
# @author Kadvin, Date: 12-5-14
require File.join(File.dirname(__FILE__), "../env")
require File.join(File.dirname(__FILE__), "../../lib/spi")
require File.join(File.dirname(__FILE__), "http_mock_ext")

describe "Threshold Rule SPI" do

  it "can find all rules" do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/v1/threshold_rules.json", {}, "[%s,%s]" % [@rule_str_1, @rule_str_2], 200, @apache_headers
    end
    rules = Spi::ThresholdRule.find(:all)
    rules.should have(2).items
  end

  it "can find the rule" do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/v1/threshold_rules/the-first-rule-key.json", {}, @rule_str_1, 200, @apache_headers
    end
    mo = Spi::ThresholdRule.find("the-first-rule-key")
    mo.id.should == "the-first-rule-key"
  end

  it "can create the rule" do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.post "/v1/threshold_rules.json", {}, "[%s,%s]" % [@rule_str_1, @rule_str_2], 200, @apache_headers
    end
    rules = Spi::ThresholdRule.create(JSON.parse(@new_rule_str))
    rules.should have(2).items
  end

  it "can update the rule" do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/v1/threshold_rules/the-second-rule-key.json", {}, @rule_str_2, 200, @apache_headers
      mock.put "/v1/threshold_rules/the-second-rule-key.json", {}, @rule_str_2, 200, @apache_headers
    end
    rule = Spi::ThresholdRule.find("the-second-rule-key")
    rule.update_attributes JSON.parse(@updated_rule_str)
  end

  it "can delete the rule" do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/v1/threshold_rules/the-first-rule-key.json", {}, @rule_str_1, 200, @apache_headers
      mock.delete "/v1/threshold_rules/the-first-rule-key.json", {}, @rule_str_1, 200, @apache_headers
    end
    rule = Spi::ThresholdRule.find("the-first-rule-key")
    rule.destroy
  end

  before(:all) do
    Spi::ThresholdRule.site = "http://localhost:8020/v1/"
    @apache_headers = {}
    @rule_str_1 = <<-RULE_STR
      {
            "key"  : "the-first-rule-key",
            "name" : "threshold-rule-01",
            "eventType" : "rule.broken",
            "status" : "enabled",
            "startOn" : "2012-01-10",
            "stopOn" : "2012-12-31",
            "description" : "it's a test'",
            "creator" : "PDM-PTS-CREATE-THRESHOLD",
            "source" : "PDM-UP",
            "version" : 1,
            "managedObject" : "moKey == \\'127e0d3d-9125-47d0-a3a0-80196a6f764f\\'",
            "indicator" :
            {
                "name" : "RemotePing",
                "expectedInterval" : 5000,
                "arguments" :
                        [
                            {
                                "a1" : "executing-host"
                            },
                            {
                                "a2" : 23
                            },
                            {
                                "a2" :
                                {
                                    "@type" : "RemotingPingParameter",
                                    "dstIP" : "10.11.12.13",
                                    "SentPacketsNum" : 20,
                                    "SentPacketsSize" : 300,
                                    "Delay" : 2000,
                                    "Timeout" : 2000
                                }
                            }
                        ]
            },
            "trigger" :
            {
                "@type" : "switch",
                "Select" :
                {
                    "projection" :
                    {
                        "field" : "ProcessMEM",
                        "function" : "Count"
                    },
                    "when" :
                    {
                        "field" : "ProcessName",
                        "operator" : "like",
                        "value" : "betasoft.pdm.*"
                    }
                },
                "condition" :
                        [
                            {
                                "description" : "desc",
                                "label" : "Low",
                                "operator" : "<",
                                "value" : "30"
                            },
                            {
                                "description" : "desc",
                                "label" : "Middle",
                                "operator" : "<",
                                "value" : "50"
                            },
                            {
                                "description" : "desc",
                                "label" : "High",
                                "operator" : "<",
                                "value" : "80"
                            }
                        ]
            },
            "notification" :
            {
                "repeatCount" : 3,
                "data" :
                        [
                            {
                                "type" : "poll",
                                "destinationName" : "BTIM.JMColor",
                                "description" : "slslsls"
                            },
                            {
                                "type" : "poll",
                                "destinationName" : "BTIM.Alert"
                            },
                            {
                                "type" : "push",
                                "destinationName" : "http://127.0.0.1:1099/pushEvent"
                            },
                            {
                                "type" : "jms",
                                "destinationName" : "Nanri",
                                "description" : "xxxxx"
                            },
                            {
                                "type" : "jms",
                                "destinationName" : "xxxx",
                                "description" : "xxxx"
                            },
                            {
                                "type" : "db",
                                "destinationName" : "yyy",
                                "description" : "yyy"
                            }
                        ]
            },
            "schedulePlan" :
            {
                "includes" :
                        [
                            {
                                "times" : "8:30-17:30",
                                "days_of_week" : "1-5",
                                "months" : "1,2,3"
                            },
                            {
                                "times" : "9:00-18:00",
                                "days_of_month" : "1-30",
                                "months" : "4,5,6,7,8,9,10,11,12"
                            }
                        ],
                "excludes" :
                        [
                            {
                                "days_of_month" : "1-7",
                                "months" : "10"
                            },
                            {
                                "days_of_week" : "1",
                                "months" : "1"
                            },
                            {
                                "days_of_month" : "1",
                                "months" : "5"
                            }
                        ]
            }
        }
    RULE_STR
    @rule_str_2 = <<-RULE_STR
      {
            "key"  : "the-second-rule-key",
            "name" : "threshold-rule-02",
            "eventType" : "rule.broken",
            "status" : "enabled",
            "startOn" : "2012-01-10",
            "stopOn" : "2012-12-31",
            "description" : "it's a test'",
            "creator" : "PDM-PTS-CREATE-THRESHOLD",
            "source" : "PDM-UP",
            "version" : 1,
            "managedObject" : "moKey == \\'127e0d3d-9125-47d0-a3a0-80196a6f764f\\'",
            "indicator" :
            {
                "name" : "RemotePing",
                "expectedInterval" : 5000,
                "arguments" :
                        [
                            {
                                "a1" : "executing-host"
                            },
                            {
                                "a2" : 23
                            },
                            {
                                "a2" :
                                {
                                    "@type" : "RemotingPingParameter",
                                    "dstIP" : "10.11.12.13",
                                    "SentPacketsNum" : 20,
                                    "SentPacketsSize" : 300,
                                    "Delay" : 2000,
                                    "Timeout" : 2000
                                }
                            }
                        ]
            },
            "trigger" :
            {
                "@type" : "switch",
                "Select" :
                {
                    "projection" :
                    {
                        "field" : "ProcessMEM",
                        "function" : "Count"
                    },
                    "when" :
                    {
                        "field" : "ProcessName",
                        "operator" : "like",
                        "value" : "betasoft.pdm.*"
                    }
                },
                "condition" :
                        [
                            {
                                "description" : "desc",
                                "label" : "Low",
                                "operator" : "<",
                                "value" : "30"
                            },
                            {
                                "description" : "desc",
                                "label" : "Middle",
                                "operator" : "<",
                                "value" : "50"
                            },
                            {
                                "description" : "desc",
                                "label" : "High",
                                "operator" : "<",
                                "value" : "80"
                            }
                        ]
            },
            "notification" :
            {
                "repeatCount" : 3,
                "data" :
                        [
                            {
                                "type" : "poll",
                                "destinationName" : "BTIM.JMColor",
                                "description" : "slslsls"
                            },
                            {
                                "type" : "poll",
                                "destinationName" : "BTIM.Alert"
                            },
                            {
                                "type" : "push",
                                "destinationName" : "http://127.0.0.1:1099/pushEvent"
                            },
                            {
                                "type" : "jms",
                                "destinationName" : "Nanri",
                                "description" : "xxxxx"
                            },
                            {
                                "type" : "jms",
                                "destinationName" : "xxxx",
                                "description" : "xxxx"
                            },
                            {
                                "type" : "db",
                                "destinationName" : "yyy",
                                "description" : "yyy"
                            }
                        ]
            },
            "schedulePlan" :
            {
                "includes" :
                        [
                            {
                                "times" : "8:30-17:30",
                                "days_of_week" : "1-5",
                                "months" : "1,2,3"
                            },
                            {
                                "times" : "9:00-18:00",
                                "days_of_month" : "1-30",
                                "months" : "4,5,6,7,8,9,10,11,12"
                            }
                        ],
                "excludes" :
                        [
                            {
                                "days_of_month" : "1-7",
                                "months" : "10"
                            },
                            {
                                "days_of_week" : "1",
                                "months" : "1"
                            },
                            {
                                "days_of_month" : "1",
                                "months" : "5"
                            }
                        ]
            }
        }
    RULE_STR
    @new_rule_str = <<-RULE_STR
      {
            "name" : "threshold-rule-03",
            "eventType" : "rule.broken",
            "status" : "enabled",
            "startOn" : "2012-01-10",
            "stopOn" : "2012-12-31",
            "description" : "it's a test'",
            "creator" : "PDM-PTS-CREATE-THRESHOLD",
            "source" : "PDM-UP",
            "version" : 1,
            "managedObject" : "moKey == \\'127e0d3d-9125-47d0-a3a0-80196a6f764f\\'",
            "indicator" :
            {
                "name" : "RemotePing",
                "expectedInterval" : 5000,
                "arguments" :
                        [
                            {
                                "a1" : "executing-host"
                            },
                            {
                                "a2" : 23
                            },
                            {
                                "a2" :
                                {
                                    "@type" : "RemotingPingParameter",
                                    "dstIP" : "10.11.12.13",
                                    "SentPacketsNum" : 20,
                                    "SentPacketsSize" : 300,
                                    "Delay" : 2000,
                                    "Timeout" : 2000
                                }
                            }
                        ]
            },
            "trigger" :
            {
                "@type" : "switch",
                "select" :
                {
                    "projection" :
                    {
                        "field" : "ProcessMEM",
                        "function" : "Count"
                    },
                    "when" :
                    {
                        "field" : "ProcessName",
                        "operator" : "like",
                        "value" : "betasoft.pdm.*"
                    }
                },
                "condition" :
                        [
                            {
                                "description" : "desc",
                                "label" : "Low",
                                "operator" : "<",
                                "value" : "30"
                            },
                            {
                                "description" : "desc",
                                "label" : "Middle",
                                "operator" : "<",
                                "value" : "50"
                            },
                            {
                                "description" : "desc",
                                "label" : "High",
                                "operator" : "<",
                                "value" : "80"
                            }
                        ]
            },
            "notification" :
            {
                "repeatCount" : 3,
                "data" :
                        [
                            {
                                "type" : "poll",
                                "destinationName" : "BTIM.JMColor",
                                "description" : "slslsls"
                            },
                            {
                                "type" : "poll",
                                "destinationName" : "BTIM.Alert"
                            },
                            {
                                "type" : "push",
                                "destinationName" : "http://127.0.0.1:1099/pushEvent"
                            },
                            {
                                "type" : "jms",
                                "destinationName" : "Nanri",
                                "description" : "xxxxx"
                            },
                            {
                                "type" : "jms",
                                "destinationName" : "xxxx",
                                "description" : "xxxx"
                            },
                            {
                                "type" : "db",
                                "destinationName" : "yyy",
                                "description" : "yyy"
                            }
                        ]
            },
            "schedulePlan" :
            {
                "includes" :
                        [
                            {
                                "times" : "8:30-17:30",
                                "days_of_week" : "1-5",
                                "months" : "1,2,3"
                            },
                            {
                                "times" : "9:00-18:00",
                                "days_of_month" : "1-30",
                                "months" : "4,5,6,7,8,9,10,11,12"
                            }
                        ],
                "excludes" :
                        [
                            {
                                "days_of_month" : "1-7",
                                "months" : "10"
                            },
                            {
                                "days_of_week" : "1",
                                "months" : "1"
                            },
                            {
                                "days_of_month" : "1",
                                "months" : "5"
                            }
                        ]
            }
        }
    RULE_STR
    @updated_rule_str = <<-RULE_STR
      {
            "name"      : "a new name",
            "eventType" : "updated-rule-broken",
            "status" : "disabled",
            "startOn" : "2012-01-10",
            "stopOn" : "2012-12-31",
            "description" : "it's a test'"
      }
    RULE_STR
  end
end