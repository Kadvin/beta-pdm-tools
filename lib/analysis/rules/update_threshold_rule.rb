# encoding: utf-8
# @author yuan, Date: 2012-03-13
require "analysis/engine"

Analysis::Engine.configure do
  if_file_like(userpane_pattern) do
    if_content_like(/Updating\s#{threshold_rule_by_key_ptn}/) do
      identified_by('update-threshold-rule-#{$1}')
      title_will_be('开始更新记录规则(#{$1})')
      original_task_as(:title)
    end

    if_content_like(/Dispatching\s#{update_threshold_rule_event_ptn}/) do
      identified_by('update-threshold-rule-#{$2}')
      title_will_be('向Engine分配更新记录规则(#{$2})的任务')
    end

    if_content_like(/Dispatched\s#{update_threshold_rule_event_ptn}/) do
      identified_by('update-threshold-rule-#{$2}')
      title_will_be('成功的向Engine分配更新记录规则(#{$2})的任务')
    end

    if_content_like(/Updated\s#{threshold_rule_by_key_ptn}/) do
      identified_by('update-threshold-rule-#{$1}')
      title_will_be('完成更新记录规则(#{$1})')
    end
  end
end
