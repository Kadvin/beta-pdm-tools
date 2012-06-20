# encoding: utf-8
# @author Kadvin, Date: 11-12-22

require "analysis/engine"

Analysis::Engine.configure do

  # Configure log rule for ps_userpane
  if_file_like(userpane_pattern) do
    # For Sample MO's Indicator
    if_content_like(/Reading #{mo_simple_ptn} \/ #{indicator_ptn}, #{param_ptn}/) do
      title_will_be('采集MO(#{$1})的指标(#{$2})')
      original_task_as(:title)
      identified_by('read-indicator-#{$1}-#{$2}')
    end
    if_content_like(/Reading #{mo_ptn} \/ #{indicator_ptn} from #{engine_ptn}/) do
      title_will_be('用引擎(#{$6}):采集#{$4}的指标#{$5}')
      identified_by('read-indicator-#{$4}-#{$5}')
    end
    if_content_like(/Read #{mo_ptn} \/ #{indicator_ptn} from #{engine_ptn}/) do
      title_will_be('从引擎(#{$6}):采集到#{$4}-#{$5}')
      identified_by('read-indicator-#{$4}-#{$5}')
    end
    if_content_like(/Return forbidden result for #{mo_ptn} \/ #{indicator_ptn}/) do
      title_will_be('发现MO(#{$1})被禁采')
      identified_by('read-indicator-#{$4}-#{$5}')
    end
  end

  if_file_like(commander_pattern) do
    # ==Connector Node
    # 这里拥有足够的上下文去和通用采集场景对接，所以，在这里设定一个与通用采集场景相同的id，即可达成对接
    if_content_like(/Reading #{mo_simple_ptn} \/ #{indicator_ptn}/) do
      title_will_be('采集MO(#{$1})的指标(#{$2})')
      identified_by('read-indicator-#{$1}-#{$2}')
      identified_by('sampling-#{$1}-#{$2}')
    end
    if_content_like(/Read #{mo_simple_ptn} \/ #{indicator_ptn}/) do
      title_will_be('采集到MO(#{$1})的指标(#{$2})')
      identified_by('read-indicator-#{$1}-#{$2}')
    end
    if_content_like(/Return forbidden result for #{mo_ptn} \/ #{indicator_ptn} /) do
      title_will_be('发现MO(#{$4})被禁采')
      identified_by('read-indicator-#{$4}-#{$5}')
    end
  end
end
require "analysis/rules/sample"
