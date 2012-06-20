# encoding: utf-8
# @author yuan, Date: 2012-03-15
require "analysis/engine"

Analysis::Engine.configure do
  if_file_like(userpane_pattern) do
    if_content_like(/enter\sdelete\sRecords-\s([^\/]+)\/(.+)/x) do
      identified_by('delete-file-#{$1}-#{$2}')
      title_will_be('开始删除文件(#{$1}/#{$2})')
      original_task_as(:title)
    end

    if_content_like(/exit\sdelete\sRecords-\s([^\/]+)\/(.+)/x) do
      identified_by('delete-file-#{$1}-#{$2}')
      title_will_be('完成删除文件(#{$1}/#{$2})')
    end
  end
end
