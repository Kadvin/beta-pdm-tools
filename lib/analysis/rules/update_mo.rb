# encoding: utf-8
# @author yuan, Date: 2012-03-10
require "analysis/engine"

Analysis::Engine.configure do

  if_file_like(userpane_pattern) do
    if_content_like(/Updating\s#{mo_ptn}/) do
      title_will_be('开始更新MO(#{$4})')
      original_task_as(:title)
      identified_by('update-mo-#{$4}')
    end

    if_content_like(/Updated\s#{mo_ptn}/) do
      title_will_be('完成更新MO(#{$4})')
      identified_by('update-mo-#{$4}')
    end
  end

end
