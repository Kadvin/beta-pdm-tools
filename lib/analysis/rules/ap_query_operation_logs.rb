# encoding: utf-8
# @author yuan, Date: 2012-03-27
require "analysis/engine"

Analysis::Engine.configure do

  # Configure log rule for ps_adminpane
  if_file_like(adminpane_pattern) do
    if_content_like(/Inquire\soperation\slog\sstart/) do
      original_task_as('管理员查询操作日志')
      title_will_be('开始查询操作日志')
      identified_by('ap-query-operation-logs')
    end

    if_content_like(/Inquire\soperation\slog\send/) do
      title_will_be('完成查询操作日志')
      identified_by('ap-query-operation-logs')
    end
  end

end
