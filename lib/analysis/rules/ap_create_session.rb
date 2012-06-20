# encoding: utf-8
# @author yuan, Date: 2012-03-26
require "analysis/engine"

Analysis::Engine.configure do

  # Configure log rule for ps_adminpane
  if_file_like(adminpane_pattern) do
    if_content_like(/login\sstart/) do
      original_task_as('管理员登录AP面板')
      title_will_be('开始登录')
      identified_by('ap-login')
    end

    if_content_like(/login\send/) do
      title_will_be('登录完成')
      identified_by('ap-login')
    end
  end

end
