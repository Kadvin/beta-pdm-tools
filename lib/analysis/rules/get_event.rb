# encoding: utf-8
# @author yuan, Date: 2012-03-14
require "analysis/engine"

Analysis::Engine.configure do
  if_file_like(userpane_pattern) do
    if_content_like(/enter\slist\sUpEvent\s\-\s([^\n]+)/x) do
      identified_by('list-record-rule-#{$1}')
      title_will_be('开始获取事件(#{$1})')
      original_task_as(:title)
    end

    if_content_like(/exit\slist\sUpEvent\s\-\s(.+)/x) do
      identified_by('list-record-rule-#{$1}')
      title_will_be('完成获取事件(#{$1})')
    end
  end
end
