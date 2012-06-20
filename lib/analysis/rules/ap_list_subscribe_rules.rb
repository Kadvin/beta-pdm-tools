# encoding: utf-8
# @author yuan, Date: 2012-03-27
require "analysis/engine"

Analysis::Engine.configure do

  # Configure log rule for ps_adminpane
  if_file_like(adminpane_pattern) do
    if_content_like(/enter\sSubscribeRules\sindex\spage,\sruleType\s:\s(\w+)/) do
      original_task_as('管理员查看(#{$1})类型订阅规则列表')
      title_will_be('开始查看(#{$1})类型订阅规则列表')
      identified_by('ap-list-subscribe-rules-#{$1}')
    end

    if_content_like(/exit\sSubscribeRules\sindex\spage,\sruleType\s:\s(\w+)/) do
      title_will_be('完成查看(#{$1})类型订阅规则列表')
      identified_by('ap-list-subscribe-rules-#{$1}')
    end
  end

end
