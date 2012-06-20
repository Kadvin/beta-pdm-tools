# encoding: utf-8
# @author yuan, Date: 2012-03-27
require "analysis/engine"

Analysis::Engine.configure do

  # Configure log rule for ps_adminpane
  if_file_like(adminpane_pattern) do
    if_content_like(/Show\sassign_rules,Start/) do
      original_task_as('管理员查看分配规则列表')
      title_will_be('开始查看分配规则列表')
      identified_by('ap-list-assign-rules')
    end

    if_content_like(/Show\sassign_rules,End/) do
      title_will_be('完成查看分配规则列表')
      identified_by('ap-list-assign-rules')
    end
  end

end
