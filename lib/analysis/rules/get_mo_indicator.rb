# encoding: utf-8
# @author yuan, Date: 2012-03-08
require "analysis/engine"

Analysis::Engine.configure do

  if_file_like(userpane_pattern) do

    if_content_like(/Reading #{mo_simple_ptn} \/ #{indicator_ptn}, #{param_ptn}/) do
      title_will_be('采集MO(#{$1})的指标(#{$2})')
      original_task_as(:title)
      identified_by('get-indicator-#{$1}-#{$2}')
    end

    if_content_like(/Reading #{mo_ptn} \/ #{indicator_ptn} from #{engine_ptn}/) do
      title_will_be('用引擎(#{$6}):采集#{$4}的指标#{$5}')
      identified_by('get-indicator-#{$4}-#{$5}')
    end

    if_content_like(/Read #{mo_ptn} \/ #{indicator_ptn} from #{engine_ptn}/) do
      title_will_be('从引擎(#{$6}):采集到#{$4}-#{$5}')
      identified_by('get-indicator-#{$4}-#{$5}')
    end

    if_content_like(/Return forbidden result for #{mo_ptn} \/ #{indicator_ptn}/) do
      title_will_be('发现MO(#{$1})被禁采')
      identified_by('get-indicator-#{$4}-#{$5}')
    end
  end

  if_file_like(commander_pattern) do
    if_content_like(/Reading #{mo_simple_ptn} \/ #{indicator_ptn}/) do
      title_will_be('采集MO(#{$1})的指标(#{$2})')
      identified_by('sampling-#{$1}-#{$2}')
      identified_by('get-indicator-#{$1}-#{$2}')
    end
    if_content_like(/Read #{mo_simple_ptn} \/ #{indicator_ptn}/) do
      title_will_be('采集到MO(#{$1})的指标(#{$2})')
      identified_by('get-indicator-#{$1}-#{$2}')
    end
    if_content_like(/Return forbidden result for #{mo_ptn} \/ #{indicator_ptn} /) do
      title_will_be('发现MO(#{$4})被禁采')
      identified_by('get-indicator-#{$4}-#{$5}')
    end
  end

end
require 'analysis/rules/sample'
