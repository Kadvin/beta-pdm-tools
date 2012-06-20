# encoding: utf-8
# @author yuan, Date: 2012-03-08
require "analysis/engine"

Analysis::Engine.configure do

  if_file_like(userpane_pattern) do
    if_content_like(/Retrieve #{mo_ptn}/) do
      title_will_be('开始刷新MO(#{$4})')
      original_task_as(:title)
      identified_by('retrieve-mo-#{$4}')
    end

    if_content_like(/Retrieved #{mo_ptn}/) do
      title_will_be('完成刷新MO(#{$4})')
      identified_by('retrieve-mo-#{$4}')
    end
  end

  if_file_like(commander_pattern) do
    if_content_like(/Retrieving #{mo_ptn}/) do
      title_will_be('开始刷新:#{$1}(#{$2})')
      identified_by('retrieve-mo-#{$2}')
    end

    if_content_like(/Reading #{property_ptn} -> #{indicator_ptn} for #{mo_ptn}/, "Reading-Property") do
      title_will_be('读取:#{$2}(#{$3})的属性(#{$1})')
      identified_by('retrieve-mo-#{$6}')
      identified_by('sampling-#{$6}-#{$2}')
    end

    if_content_like(/Read #{property_ptn} <- #{indicator_ptn} for #{mo_ptn}/) do
      title_will_be('读到:#{$3}(#{$4})的属性(#{$1})')
      identified_by('retrieve-mo-#{$6}')
    end
  end

end
require 'analysis/rules/sample'
