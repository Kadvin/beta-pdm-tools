# encoding: utf-8
# @author yuan, Date: 2012-03-26
require "analysis/engine"

Analysis::Engine.configure do

  # Configure log rule for ps_adminpane
  if_file_like(adminpane_pattern) do
    if_content_like(/Show\sengines,Starting/) do
      original_task_as('管理员查看引擎列表')
      title_will_be('开始列出引擎')
      identified_by('ap-list-engines')
    end

    if_content_like(/Show\sengines\sSuccess/) do
      title_will_be('完成列出引擎')
      identified_by('ap-list-engines')
    end
  end

end
