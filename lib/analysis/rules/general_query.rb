# encoding: utf-8
# @author yuan, Date: 2012-03-10
require "analysis/engine"

Analysis::Engine.configure do

  if_file_like(userpane_pattern) do
    if_content_like(/(Index|Sum) #{query_mos_ptn}/) do
      title_will_be('开始查询(#{$1})')
      original_task_as(:title)
      identified_by('query-mos-#{$1}')
    end

    if_content_like(/End\sof\s(sum|index)\smos/) do
      title_will_be('完成查询(#{$1})')
      identified_by('query-mos-#{$1}')
    end

  end
end
