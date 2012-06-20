# encoding: utf-8
# @author yuan, Date: 2012-03-27
require "analysis/engine"

Analysis::Engine.configure do

  # Configure log rule for ps_adminpane
  if_file_like(adminpane_pattern) do
    if_content_like(/enter\sSubscribeRules\sshow\spage,\sid\s:\s(\d+)/) do
      original_task_as('管理员查看订阅规则(#{$1})')
      title_will_be('开始查看订阅规则(#{$1})')
      identified_by('ap-show-subscribe-rule-#{$1}')
    end

    if_content_like(/exit\sSubscribeRules\sshow\spage,\sid\s:\s(\d+)/) do
      title_will_be('完成查看订阅规则(#{$1})')
      identified_by('ap-show-subscribe-rule-#{$1}')
    end
  end

end
