# encoding: utf-8
# @author Kadvin, Date: 11-12-22

require "analysis/engine"

module Analysis
  Engine.configure do
    # Define common patterns for log file names
    define_pattern :userpane, /ps_userpane\.log(?:\.(\d)+)?/
    define_pattern :adminpane, /ps_adminpane\.log(?:\.(\d)+)?/
    define_pattern :hub, /ps_hub\.log(?:\.(\d)+)?/
    define_pattern :commander, /se_commander\.log(?:\.(\d)+)?/
    define_pattern :sampling, /se_sampling\.log(?:\.(\d)+)?/
    define_pattern :scheduler, /se_scheduler\.log(?:\.(\d)+)?/
    define_pattern :executor, /\{taskId=`([^\`\/]*)\/([^\`\/]*)\/[^\`]*`,\srule=`.*?key:`([^\`]*)`,.*?`\}/
    define_pattern :executor_empty_rule, /\{taskId=`([^\`\/]*)\/([^\`\/]*)\/[^\`]*`,\srule=``\}/
    define_pattern :threshold_rule, /\w{0,2}ThresholdRule\(.*name\s*:\s*`([^\`@]*)(?:\s+@>\s+[^\`]*)?`\)/
    define_pattern :threshold_rule_by_key, /\w{0,2}ThresholdRule\(.*?key\s*:\s*`([^\`]*)`.*?\)/
    define_pattern :create_threshold_event, /.*?\"eventType\":\"create\".*?\"name\"\s*:\s*\"([^\"]*)(?:\s@>\s[^\"]*)?\".*?\"parent_type\":\"thresholdRule\".*?/
    define_pattern :delete_threshold_event, /.*?\"eventType\":\"delete\".*?\"parent_type\":\"thresholdRule\".*?\"rule_key\":\"([^\"]*)\".*?/
    define_pattern :update_threshold_rule_event, /.*?\"eventType\":\"update\".*?\"name\"\s*:\s*\"([^\"]*)\".*?\"parent_type\":\"thresholdRule\".*?\"rule_key\":\"([^\"]*)\".*?/

    define_pattern :record_rule, /\w{0,2}RecordRule\(.*name\s*:\s*`([^\`@]*)(?:\s+@>\s+[^\`]*)?`\)/
    define_pattern :record_rule_by_key, /\w{0,2}RecordRule\(.*?key\s*:\s*`([^\`]*)`.*?\)/
    define_pattern :create_record_event, /.*?\"eventType\":\"create\".*?\"name\"\s*:\s*\"([^\"]*)(?:\s@>\s[^\"]*)?\".*?\"parent_type\":\"recordRule\".*?/
    define_pattern :delete_record_event, /.*?\"eventType\":\"delete\".*?\"parent_type\":\"recordRule\".*?\"rule_key\":\"([^\"]*)\".*?/
    define_pattern :update_record_rule_event, /.*?\"eventType\":\"update\".*?\"name\"\s*:\s*\"([^\"]*)\".*?\"parent_type\":\"recordRule\".*?\"rule_key\":\"([^\"]*)\".*?/

    # Define general log line pattern, it's should be align with log4j.properties|log4j.xml
    define_pattern :line, /([^ ]+)\s+(\w{4,5})\s+\[([^\]]+)\] ([^#]+)#([^ ]+)\s~\s+(.*)/m
    # Define common patterns for Models
    define_pattern :mo, /MO\((?:type\s*:\s*\"([^\"]+)\")
                        (?:
                          (?:,\s*ip\s*:\s*\"([^\"]+)\") |
                          (?:,\s*domain\s*:\s*\"([^\"]+)\") |
                          (?:,\s*moKey\s*:\s*(?:\"([^\"]+)\"|null))
                        )*
                      \)/x
    define_pattern :mo_simple, /MO\((?:\s*moKey\s*:\s*\"([^\"]+)\"\s*)\)/x
    define_pattern :engine, /Engine\(([^\)]+)\)/
    define_pattern :property, /Property\(([^\)]+)\)/
    define_pattern :indicator, /Indicator\(([^\)]+)\)/
    define_pattern :operation, /Operation\(([^\)]+)\)/
    define_pattern :member, /(?:Operation|Property|Indicator)\(([^\)]+)\)/
    define_pattern :probe, /Probe\(([^\)]+)\)/
    define_pattern :task, /Task\((?:moKey\s*:\s*[\"|\']([^\"|\']+)[\"|\'])
                      (?:
                        (?:,\s*actionName\s*:\s*[\"|\']([^\"|\']+)[\"|\']) |
                        (?:,\s*uuid\s*:\s*([\"|\']([^\"|\']+)[\"|\']))
                      )*
                    \)/x
    define_pattern :param, /Parameter\(([^\)]+)\)/
    define_pattern :query_mos, /mos\s*with\s*like\s*:\s*`([^`]+)`,\s*offset\s*:\s*`([^`]+)`,\s*limit\s*:\s*`([^`]+)`/x

    # Configure a global log pattern and record recognize proc
    log_should_like(line_ptn) do |line|
      LogRecord.new(:record_at => line[1],
                    :level => line[2],
                    :thread_name => line[3],
                    :class_name => line[4],
                    :method_name => line[5],
                    :file => line.file,
                    :file_no => line.file_no,
                    :line_no => line.line_no) do |record|

        record.line = line[0]
        record.content = line[6]
      end
    end
  end
end

# load the rules by analyst specified
#Dir[File.join(File.dirname(__FILE__), "rules", "/*.rb")].each{|rules| require rules}
