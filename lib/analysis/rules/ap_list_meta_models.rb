# encoding: utf-8
# @author yuan, Date: 2012-03-27
require "analysis/engine"

Analysis::Engine.configure do

  # Configure log rule for ps_adminpane
  if_file_like(adminpane_pattern) do
    if_content_like(/show\sthe\slist\sof\smanagedclass:\s([^\s]+)\sstart/) do
      original_task_as('管理员查看类型为(#{$1})的元模型')
      title_will_be('开始查看类型为(#{$1})的元模型')
      identified_by('ap-list-meta-models-#{$1}')
    end

    if_content_like(/show\sthe\slist\sof\smanagedclass:\s([^\s]+)\send/) do
      title_will_be('完成查看类型为(#{$1})的元模型')
      identified_by('ap-list-meta-models-#{$1}')
    end
  end

end
