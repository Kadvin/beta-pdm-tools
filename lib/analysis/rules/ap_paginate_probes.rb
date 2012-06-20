# encoding: utf-8
# @author yuan, Date: 2012-03-27
require "analysis/engine"

Analysis::Engine.configure do

  # Configure log rule for ps_adminpane
  if_file_like(adminpane_pattern) do
    if_content_like(/index\spackages\sstart/) do
      original_task_as('管理员查看探针包列表')
      title_will_be('开始查看探针包列表')
      identified_by('ap-paginate-probes')
    end

    if_content_like(/index\spackages\send/) do
      title_will_be('完成查看探针包列表')
      identified_by('ap-paginate-probes')
    end
  end

end
