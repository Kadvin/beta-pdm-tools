# encoding: utf-8
# @author Kadvin, Date: 11-12-22

require "analysis/engine"
require "analysis/rules/create_mo"

Analysis::Engine.configure do


  # Configure log rule for se_scheduler
  if_file_like(scheduler_pattern) do

    if_content_like(/#{executor_ptn}\s-\sCreating\stask\s.*/) do
      identified_by('execute-subscribe-#{$3}')
      identified_by('sampling-#{$1}-#{$2}')      # 对接sampling流程
      title_will_be('执行订阅规则(#{$3})')
      original_task_as(:title)
    end
    if_content_like(/#{executor_ptn}\s-\s.*/) do
      identified_by('execute-subscribe-#{$3}')
      identified_by('sampling-#{$1}-#{$2}')      # 对接sampling流程
      title_will_be('执行订阅规则(#{$3})')
    end
    if_content_like(/#{executor_empty_rule_ptn}\s-\s.*/) do
      identified_by('sampling-#{$1}-#{$2}')      # 对接sampling流程
      title_will_be('接收到采集结果(#{$1}-#{$2})')
    end
  end

end