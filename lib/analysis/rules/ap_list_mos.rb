# encoding: utf-8
# @author yuan, Date: 2012-03-26
require "analysis/engine"

Analysis::Engine.configure do

  # Configure log rule for ps_adminpane
  if_file_like(adminpane_pattern) do
    if_content_like(/Listing\smos\swith\scategoryId\s:\s`(\w+)`/) do
      original_task_as('管理员查看(#{$1})MO列表')
      title_will_be('开始列出(#{$1})类型的MO')
      identified_by('ap-list-#{$1}-mos')
    end

    if_content_like(/Listed\smos\swith\scategoryId\s:\s`(\w+)`/) do
      title_will_be('完成列出(#{$1})类型的MO')
      identified_by('ap-list-#{$1}-mos')
    end
  end

end
