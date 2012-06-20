# encoding: utf-8
# @author yuan, Date: 2012-03-26
require "analysis/engine"

Analysis::Engine.configure do

  # Configure log rule for ps_adminpane
  if_file_like(adminpane_pattern) do
    if_content_like(/Show\sengine\swith\sid\s:\s(\d+)\s,Starting/) do
      original_task_as('管理员查看引擎(#{$1})')
      title_will_be('开始查看引擎(#{$1})')
      identified_by('ap-get-engine-#{$1}')
    end

    if_content_like(/Show\sengine\swith\sid\s:\s(\d+)\sSuccess/) do
      title_will_be('完成查看引擎(#{$1})')
      identified_by('ap-get-engine-#{$1}')
    end
  end

end
