# encoding: utf-8
# @author yuan, Date: 2012-03-26
require "analysis/engine"

Analysis::Engine.configure do

  # Configure log rule for ps_adminpane
  if_file_like(adminpane_pattern) do
    if_content_like(/loginOut\sstart/) do
      original_task_as('管理员从AP面板注销')
      title_will_be('开始注销')
      identified_by('ap-logout')
    end

    if_content_like(/loginOut\send/) do
      title_will_be('注销完成')
      identified_by('ap-logout')
    end
  end

end
